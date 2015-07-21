//
//  AFXAuthRequestSerializer.h
//  PlayingWithXAuth
//
//  Created by Michal Zygar on 15.10.2013.
//
//

#import "AFURLRequestSerialization.h"
#import "AFXAuthClient.h"

extern NSDictionary * AFParametersFromQueryString(NSString *queryString);

@protocol AFXAuthRequestSerializerTokenProvider <NSObject>
-(AFXAuthToken*)token;
@end

@interface AFXAuthRequestSerializer : AFHTTPRequestSerializer
-(instancetype)initWithKey:(NSString*)key
                    secret:(NSString *)secret
             tokenProvider:(id<AFXAuthRequestSerializerTokenProvider>)provider;


@end
