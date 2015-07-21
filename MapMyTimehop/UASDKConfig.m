//
//  UASDKConfig.m
//  MapMyTimehop
//
//  Created by Lauren Mckenna on 7/20/15.
//
//

#import "UASDKConfig.h"
/**
 *  These should be defined externally.
 */
extern NSString * const kUASKAPIConsumerKey;
extern NSString * const kUASKAPISecret;
extern NSString * const kUASKAPIRecorderTypeKey;

@implementation UASDKConfig

+ (NSString *)apiKey {
	return kUASKAPIConsumerKey;
}

+ (NSString *)apiSecret {
	return kUASKAPISecret;
}

+ (NSString *)recorderTypeKey {
	return kUASKAPIRecorderTypeKey;
}

@end
