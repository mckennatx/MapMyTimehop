//
//  SettingsModel.m
//  MapMyTimeHop
//
//  Created by Lauren Mckenna on 7/27/15.
//  Copyright (c) 2015 Lauren Mckenna. All rights reserved.
//

#import "SettingsModel.h"

@implementation SettingsModel
/**
 * Shared instance of LocalNotificationManager.
 * @return The singleton instance.
 */
+ (SettingsModel *)sharedInstance {
	static SettingsModel *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[SettingsModel alloc] init];
	});
	return sharedInstance;
}

@end
