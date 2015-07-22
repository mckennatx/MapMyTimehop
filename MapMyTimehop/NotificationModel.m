//
//  NotificationModel.m
//  iMapMy3
//
//  Created by Lauren Mckenna on 6/23/15.
//  Copyright (c) 2015 MapMyFitness. All rights reserved.
//

#import "NotificationModel.h"

@implementation NotificationModel


- (instancetype)init
{
	self = [super init];
	if(self) {
		_title = @"";
		_notificationType = 0;
		_url = @"";
		_message = @"";
	}
	return self;
}

- (instancetype)initWithTitle:(NSString *)title notificationType:(LocalNotificationType)type URL:(NSString *)url message:(NSString *)message
{
	self = [super init];
	if(self) {
		_title = [title copy];
		_notificationType = type;
		_url = [url copy];
		_message = [message copy];
	}
	return self;
}

@end
