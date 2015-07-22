//
//  LocalNotificationView.h
//  iMapMy3
//
//  Created by Lauren Mckenna on 7/15/15.
//  Copyright (c) 2015 MapMyFitness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationModel.h"

@interface LocalNotificationView : UIView

@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, assign) BOOL dissolving;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, assign) LocalNotificationType notificationType;

- (id)initWithString:(NotificationModel *)notification target:(id)target swipeSelector:(SEL)swipe actionSelector:(SEL)action;
- (void)resetFramesWithHeight:(CGFloat)height;

@end
