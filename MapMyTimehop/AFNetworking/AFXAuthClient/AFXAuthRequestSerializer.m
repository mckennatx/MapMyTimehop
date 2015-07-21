//
//  AFXAuthRequestSerializer.m
//  PlayingWithXAuth
//
//  Created by Michal Zygar on 15.10.2013.
//
//

#import "AFXAuthRequestSerializer.h"

#import <CommonCrypto/CommonHMAC.h>

static NSString * const kAFCharactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";

static NSString * AFPercentEscapedQueryStringKeyFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    static NSString * const kAFCharactersToLeaveUnescapedInQueryStringPairKey = @"[].";
    
	return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, (__bridge CFStringRef)kAFCharactersToLeaveUnescapedInQueryStringPairKey, (__bridge CFStringRef)kAFCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}
static NSString * AFQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding)
{
    NSMutableArray* queryParts=[NSMutableArray array];
    for (NSString* key in parameters) {
        NSString* value=parameters[key];
        [queryParts addObject:[NSString stringWithFormat:@"%@=%@",AFPercentEscapedQueryStringKeyFromStringWithEncoding([key description], stringEncoding),AFPercentEscapedQueryStringKeyFromStringWithEncoding([value description], stringEncoding)]];
    }
    return [queryParts componentsJoinedByString:@"&"];
}

static NSString * AFEncodeBase64WithData(NSData *data)
{
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}

static NSString * RFC3986EscapedStringWithEncoding(NSString *string, NSStringEncoding encoding)
{
	// Validate the input string to ensure we dont return nil.
	string = string ?: @"";
	
	// Escape per RFC 3986 standards as required by OAuth. Previously, not
	// escaping asterisks (*) causes passwords with * to fail in
	// Instapaper authentication
	static NSString * const kAFCharactersToBeEscaped = @":/?#[]@!$&'()*+,;=";
    static NSString * const kAFCharactersToLeaveUnescaped = @"-._~";
    
	return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, (__bridge CFStringRef)kAFCharactersToLeaveUnescaped, (__bridge CFStringRef)kAFCharactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(encoding));
}

NSDictionary * AFParametersFromQueryString(NSString *queryString)
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (queryString) {
        NSScanner *parameterScanner = [[NSScanner alloc] initWithString:queryString];
        NSString *name = nil;
        NSString *value = nil;
        
        while (![parameterScanner isAtEnd]) {
            name = nil;
            [parameterScanner scanUpToString:@"=" intoString:&name];
            [parameterScanner scanString:@"=" intoString:NULL];
            
            value = nil;
            [parameterScanner scanUpToString:@"&" intoString:&value];
            [parameterScanner scanString:@"&" intoString:NULL];
            
            if (name && value) {
                [parameters setValue:[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
        }
    }
    
    return parameters;
}


static inline NSString * AFHMACSHA1Signature(NSString *baseString, NSString *consumerSecret, NSString *tokenSecret)
{
    NSString *secret = tokenSecret ? tokenSecret : @"";
    NSString *secretString = [NSString stringWithFormat:@"%@&%@", consumerSecret, secret];
    NSData *secretData = [secretString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *baseData = [baseString dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[20] = {0};
    CCHmac(kCCHmacAlgSHA1, secretData.bytes, secretData.length, baseData.bytes, baseData.length, digest);
    NSData *signatureData = [NSData dataWithBytes:digest length:20];
    return AFEncodeBase64WithData(signatureData);
}


@interface AFXAuthRequestSerializer ()
{
    NSString *_nonce;
    NSString *_timestamp;
}
@property (copy, nonatomic, readonly) NSString *consumerKey;
@property (copy, nonatomic, readonly) NSString *consumerSecret;
@property (weak, nonatomic) id<AFXAuthRequestSerializerTokenProvider>tokenProvider;
@end


@implementation AFXAuthRequestSerializer


-(instancetype)initWithKey:(NSString *)key secret:(NSString *)secret tokenProvider:(id<AFXAuthRequestSerializerTokenProvider>)provider
{
    self=[super init];
    if (self) {
        _consumerKey=key;
        _consumerSecret=secret;
        _tokenProvider=provider;
    }
    return self;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(id)parameters
                                     error:(NSError * __autoreleasing *)error
{
    _nonce = [NSString stringWithFormat:@"%d", arc4random()];
    _timestamp = [NSString stringWithFormat:@"%d", (int)ceil((float)[[NSDate date] timeIntervalSince1970])];
    
    NSMutableURLRequest *request = [super requestWithMethod:method URLString:URLString parameters:parameters error:error];
    NSMutableDictionary *authorizationHeader = [self authorizationHeaderWithRequest:request parameters:parameters];
    
    [request setValue:[self authorizationHeaderForParameters:authorizationHeader] forHTTPHeaderField:@"Authorization"];
    [request setHTTPShouldHandleCookies:NO];
    
    return request;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(NSDictionary *)parameters
{
    _nonce = [NSString stringWithFormat:@"%d", arc4random()];
    _timestamp = [NSString stringWithFormat:@"%d", (int)ceil((float)[[NSDate date] timeIntervalSince1970])];
    
    NSMutableURLRequest *request = [super requestWithMethod:method URLString:URLString parameters:parameters];
    NSMutableDictionary *authorizationHeader = [self authorizationHeaderWithRequest:request parameters:parameters];
    
    [request setValue:[self authorizationHeaderForParameters:authorizationHeader] forHTTPHeaderField:@"Authorization"];
    [request setHTTPShouldHandleCookies:NO];
    
    return request;
}

-(NSMutableURLRequest *)multipartFormRequestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block
{
    _nonce = [NSString stringWithFormat:@"%d", arc4random()];
    _timestamp = [NSString stringWithFormat:@"%d", (int)ceil((float)[[NSDate date] timeIntervalSince1970])];
    
    NSMutableURLRequest *request = [super multipartFormRequestWithMethod:method URLString:URLString parameters:parameters constructingBodyWithBlock:block];
    NSMutableDictionary *authorizationHeader = [self authorizationHeaderWithRequest:request parameters:parameters];
    
    [request setValue:[self authorizationHeaderForParameters:authorizationHeader] forHTTPHeaderField:@"Authorization"];
    [request setHTTPShouldHandleCookies:NO];
    return request;
}



- (NSMutableDictionary *)authorizationHeaderWithRequest:(NSURLRequest *)request parameters:(NSDictionary *)parameters
{
    AFXAuthToken* token=[self.tokenProvider token];
    NSMutableDictionary *authorizationHeader = [[NSMutableDictionary alloc] initWithDictionary:@{@"oauth_nonce": _nonce,
                             @"oauth_signature_method": @"HMAC-SHA1",
                             @"oauth_timestamp": _timestamp,
                             @"oauth_consumer_key": self.consumerKey,
                             @"oauth_signature": AFHMACSHA1Signature([self baseStringWithRequest:request parameters:parameters], _consumerSecret, token.secret),
                             @"oauth_version": @"1.0"}];
    if (token)
        [authorizationHeader setObject:RFC3986EscapedStringWithEncoding(token.key, NSUTF8StringEncoding) forKey:@"oauth_token"];
    
    return authorizationHeader;
}

- (NSString *)authorizationHeaderForParameters:(NSDictionary *)parameters
{
    static NSString * const kAFOAuth1AuthorizationFormatString = @"OAuth %@";
    
    if (!parameters) {
        return nil;
    }
    
    NSArray *sortedComponents = [[AFQueryStringFromParametersWithEncoding(parameters, self.stringEncoding) componentsSeparatedByString:@"&"] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSMutableArray *mutableComponents = [NSMutableArray array];
    for (NSString *component in sortedComponents) {
        NSArray *subcomponents = [component componentsSeparatedByString:@"="];
        [mutableComponents addObject:[NSString stringWithFormat:@"%@=\"%@\"", [subcomponents objectAtIndex:0], [subcomponents objectAtIndex:1]]];
    }
    
    return [NSString stringWithFormat:kAFOAuth1AuthorizationFormatString, [mutableComponents componentsJoinedByString:@", "]];
}

- (NSString *)baseStringWithRequest:(NSURLRequest *)request parameters:(NSDictionary *)parameters
{
    AFXAuthToken* token=[self.tokenProvider token];
    
    NSString *oauth_consumer_key = RFC3986EscapedStringWithEncoding(self.consumerKey, NSUTF8StringEncoding);
    NSString *oauth_nonce = RFC3986EscapedStringWithEncoding(_nonce, NSUTF8StringEncoding);
    NSString *oauth_signature_method = RFC3986EscapedStringWithEncoding(@"HMAC-SHA1", NSUTF8StringEncoding);
    NSString *oauth_timestamp = RFC3986EscapedStringWithEncoding(_timestamp, NSUTF8StringEncoding);
    NSString *oauth_version = RFC3986EscapedStringWithEncoding(@"1.0", NSUTF8StringEncoding);
    
    NSArray *params = @[[NSString stringWithFormat:@"%@%%3D%@", @"oauth_consumer_key", oauth_consumer_key],
                        [NSString stringWithFormat:@"%@%%3D%@", @"oauth_nonce", oauth_nonce],
                        [NSString stringWithFormat:@"%@%%3D%@", @"oauth_signature_method", oauth_signature_method],
                        [NSString stringWithFormat:@"%@%%3D%@", @"oauth_timestamp", oauth_timestamp],
                        [NSString stringWithFormat:@"%@%%3D%@", @"oauth_version", oauth_version]];
    
    for (NSString *key in parameters) {
        NSString *param = RFC3986EscapedStringWithEncoding([parameters objectForKey:key], NSUTF8StringEncoding);
        param = RFC3986EscapedStringWithEncoding(param, NSUTF8StringEncoding);
        params = [params arrayByAddingObjectsFromArray:@[[NSString stringWithFormat:@"%@%%3D%@", key, param]]];
    }
    if (token)
        params = [params arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@%%3D%@", @"oauth_token", RFC3986EscapedStringWithEncoding(token.key, NSUTF8StringEncoding)], nil]];
    
    
    params = [params sortedArrayUsingSelector:@selector(compare:)];
    NSString *baseString = [@[request.HTTPMethod,
                              RFC3986EscapedStringWithEncoding([[request.URL.absoluteString componentsSeparatedByString:@"?"] objectAtIndex:0], NSUTF8StringEncoding),
                              [params componentsJoinedByString:@"%26"]] componentsJoinedByString:@"&"];
    return baseString;
}


@end
