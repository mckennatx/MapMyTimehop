//
//  NotificationModel.h
//  iMapMy3
//
//  Created by Lauren Mckenna on 6/23/15.
//  Copyright (c) 2015 MapMyFitness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

typedef enum LocalNotificationType {
	kFriendRequestNotification,
	kLiveTrackNotification,
	kWorkoutNotification,
	kWorkoutCommentNotification,
	kFeedStoryNotification,
	kRouteNotification,
	kCourseNotification,
	kGoMVPNotification
} LocalNotificationType;

@interface NotificationModel : NSObject

@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) LocalNotificationType notificationType;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

- (instancetype)initWithTitle:(NSString *)title notificationType:(LocalNotificationType)type URL:(NSString *)url message:(NSString *)message;

@end
