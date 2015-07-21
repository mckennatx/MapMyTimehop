//
// AFXAuthClient.h
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


//Switch between base class of AFXAuthClient. If true we are using NSURLSession mechanism introduced in iOS7
#define AFX_USING_NSURLSESSION 0

#if (AFX_USING_NSURLSESSION && \
( ( defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 1090) || \
( defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 ) ))
#import "AFHTTPSessionManager.h"
#else
#import "AFHTTPRequestOperationManager.h"
#endif


@class AFXAuthToken;

extern NSString *const AFXAuthModeClient;
extern NSString *const AFXAuthModeAnon;
extern NSString *const AFXAuthModeReverse;

@interface AFXAuthClient :
#if (AFX_USING_NSURLSESSION && \
( ( defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 1090) || \
( defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 ) ))
AFHTTPSessionManager
#else
AFHTTPRequestOperationManager
#endif

{
    NSString *_nonce;
    NSString *_timestamp;
}

///-----------------------------------
/// @name Managing OAuth Configuration
///-----------------------------------

/**

 */
@property (nonatomic, strong) AFXAuthToken* token;

///---------------------
/// @name Initialization
///---------------------

/**

 */
- (id)initWithBaseURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret;

///---------------------
/// @name Authenticating
///---------------------


/**
 Authorize user using x_auth_mode = client_auth
 */
- (void)authorizeUsingXAuthWithAccessTokenPath:(NSString *)accessTokenPath
                                  accessMethod:(NSString *)accessMethod
                                      username:(NSString *)username
                                      password:(NSString *)password
                                       success:(void (^)(AFXAuthToken *accessToken))success
                                       failure:(void (^)(NSError *error))failure;

/**
 Authorize user using any x_auth_mode 
 */
- (void)authorizeUsingXAuthWithAccessTokenPath:(NSString *)accessTokenPath
                                  accessMethod:(NSString *)accessMethod
                                          mode:(NSString *)mode
                                      username:(NSString *)username
                                      password:(NSString *)password
                                       success:(void (^)(AFXAuthToken *accessToken))success
                                       failure:(void (^)(NSError *error))failure;


@end

#pragma mark -

/**

 */
@interface AFXAuthToken : NSObject <NSCoding>

/**

 */
@property (readonly, nonatomic, copy) NSString *key;

/**

 */
@property (readonly, nonatomic, copy) NSString *secret;

/**

 */
- (id)initWithQueryString:(NSString *)queryString;

/**

 */
- (id)initWithKey:(NSString *)key
           secret:(NSString *)secret;

#pragma mark - NSCoding

/**
 
 */

- (void)encodeWithCoder:(NSCoder *)coder;

/**
 
 */
- (id)initWithCoder:(NSCoder *)coder;


@end