//
//  LocalNotificationManager.h
//  iMapMy3
//
//  Created by Lauren Mckenna on 7/8/15.
//  Copyright (c) 2015 MapMyFitness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationModel.h"
#import "LocalNotificationView.h"

@protocol LocalNotificationObserver <NSObject>
@optional
- (void)notificationWillDisplayWithMessageType;
- (void)notificationDidDisplayWithMessageType;
- (void)notificationWillDismissWithMessageType;
- (void)notificationDidDismissWithMessageType;
@end


@interface LocalNotificationController : UIViewController

@property (nonatomic, strong) NSTimer *dissolveTimer;
@property (nonatomic, strong) LocalNotificationView *currentNotificationView;
@property (nonatomic, strong) NSMutableArray *queue;
@property (nonatomic, weak) UIWindow *overlayWindow;

+ (LocalNotificationController *)sharedInstance;
- (void)displayNotification:(NotificationModel *)notification;
- (void)addObserver:(id<LocalNotificationObserver>)observer;
- (void)removeObserver:(id<LocalNotificationObserver>)observer;

@end
