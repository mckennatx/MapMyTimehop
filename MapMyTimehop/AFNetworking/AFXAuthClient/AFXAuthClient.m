//
// AFXAuthClient.m
// AFXAuthClient
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Based on AFOAuth1Client, copyright (c) 2011 Mattt Thompson (http://mattt.me/)
// and TwitterXAuth, copyright (c) 2010 Eric Johnson (https://github.com/ericjohnson)
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "AFXAuthClient.h"
#import "AFHTTPRequestOperation.h"

#import "AFXAuthRequestSerializer.h"
#import <objc/message.h>

NSString *const AFXAuthModeClient = @"client_auth";
NSString *const AFXAuthModeAnon = @"anon_auth";
NSString *const AFXAuthModeReverse = @"reverse_auth";


#pragma mark -

@interface AFXAuthClient ()<AFXAuthRequestSerializerTokenProvider>
@property (copy, nonatomic, readonly) NSString *username;
@property (copy, nonatomic, readonly) NSString *password;

@end


@implementation AFXAuthClient

- (id)initWithBaseURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret
{
    self = [super initWithBaseURL:url];
    if (self) {
        self.requestSerializer=[[AFXAuthRequestSerializer alloc] initWithKey:key secret:secret tokenProvider:self];
        self.responseSerializer=[AFHTTPResponseSerializer new];
    }
    return self;
}



- (void)authorizeUsingXAuthWithAccessTokenPath:(NSString *)accessTokenPath
                                  accessMethod:(NSString *)accessMethod
                                      username:(NSString *)username
                                      password:(NSString *)password
                                       success:(void (^)(AFXAuthToken *accessToken))success
                                       failure:(void (^)(NSError *error))failure
{
    [self authorizeUsingXAuthWithAccessTokenPath:accessTokenPath accessMethod:accessMethod mode:AFXAuthModeClient username:username password:password success:success failure:failure];
}

- (void)authorizeUsingXAuthWithAccessTokenPath:(NSString *)accessTokenPath
                                  accessMethod:(NSString *)accessMethod
                                          mode:(NSString *)mode
                                      username:(NSString *)username
                                      password:(NSString *)password
                                       success:(void (^)(AFXAuthToken *))success
                                       failure:(void (^)(NSError *))failure
{
    NSDictionary *parameters = @{@"x_auth_mode": mode,
                                 @"x_auth_password": password,
                                 @"x_auth_username": username};

    id successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *queryString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if (success)
            success([[AFXAuthToken alloc] initWithQueryString:queryString]);
    };
    
    id failureBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure)
            failure(error);
    };
    
    //ensure valid access method
    NSArray* httpVerbs=@[@"PUT",@"GET",@"POST",@"HEAD",@"PATCH",@"DELETE"];
    NSAssert(([httpVerbs containsObject:accessMethod]), @"Invalid access method");
    
    //perform selector proper for access method
    SEL selector=NSSelectorFromString([accessMethod stringByAppendingString:@":parameters:success:failure:"]);
    
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
    [inv setSelector:selector];
    [inv setTarget:self];
    [inv setArgument:&(accessTokenPath) atIndex:2];
    [inv setArgument:&(parameters) atIndex:3];
    [inv setArgument:&(successBlock) atIndex:4];
    [inv setArgument:&(failureBlock) atIndex:5];
    
    [inv invoke];
}


@end



#pragma mark -

@interface AFXAuthToken ()
@property (readwrite, nonatomic, copy) NSString *key;
@property (readwrite, nonatomic, copy) NSString *secret;
@end

@implementation AFXAuthToken
@synthesize key = _key;
@synthesize secret = _secret;

- (id)initWithQueryString:(NSString *)queryString
{
    if (!queryString || [queryString length] == 0) {
        return nil;
    }

    NSDictionary *attributes = AFParametersFromQueryString(queryString);
    return [self initWithKey:[attributes objectForKey:@"oauth_token"] secret:[attributes objectForKey:@"oauth_token_secret"]];
}

- (id)initWithKey:(NSString *)key
           secret:(NSString *)secret
{
    NSParameterAssert(key);
    NSParameterAssert(secret);

    self = [super init];
    if (!self) {
        return nil;
    }

    self.key = key;
    self.secret = secret;

    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.key forKey:@"AFXAuthClientKey"];
    [coder encodeObject:self.secret forKey:@"AFXAuthClientSecret"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];

    if (self) {
        self.key = [coder decodeObjectForKey:@"AFXAuthClientKey"];
        self.secret = [coder decodeObjectForKey:@"AFXAuthClientSecret"];
    }

    return self;
}

@end
