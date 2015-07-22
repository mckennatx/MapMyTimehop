//
//  LocalNotificationManager.m
//  iMapMy3
//
//  Created by Lauren Mckenna on 7/8/15.
//  Copyright (c) 2015 MapMyFitness. All rights reserved.
//
//	This class is responsible for all local push notifications that occur when the user is using the app
//

#import "LocalNotificationController.h"
#import "AppDelegate.h"

@import QuartzCore;

static NSString* const kNotificationWillDisplayWithMessageType = @"kNotificationWillDisplayWithMessageType";
static NSString* const kNotificationDidDisplayWithMessageType = @"kNotificationDidDisplayWithMessageType";
static NSString* const kNotificationWillDismissWithMessageType = @"kNotificationWillDismissWithMessageType";
static NSString* const kNotificationDidDismissWithMessageType = @"kNotificationDidDismissWithMessageType";

const CGFloat kNotificationHeight = 64;
static const NSTimeInterval kDefaultDuration = 5;
static const CGFloat kAnimationDuration = 0.4f;


@implementation LocalNotificationController

/**
 * Shared instance of LocalNotificationManager.
 * @return The singleton instance.
 */
+ (LocalNotificationController *)sharedInstance {
	static LocalNotificationController *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[LocalNotificationController alloc] init];
	});
	return sharedInstance;
}

- (id)init {
	self = [super init];
	if(self){
		self.queue = [[NSMutableArray alloc] init];
		self.overlayWindow = [[UIApplication sharedApplication] keyWindow];
		self.overlayWindow.rootViewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
	}
	return self;
}

/**
 * Method that is called when a notification is present. This is where the LocalNotificationManager will set up a view, add it to the queue and then display message.
 * @param notification NotificationModel that contains all the information that needs to be displayed in the notification view
 */
- (void)displayNotification:(NotificationModel *)notification {
	LocalNotificationView *view = [[LocalNotificationView alloc] initWithString:notification target:self swipeSelector:@selector(dissolveAction:) actionSelector:@selector(switchViewAction)];
	[self.queue addObject:view];
	self.currentNotificationView = (self.queue)[0];
	[self displayMessage];
}

#pragma mark - Private Methods
/** @name Private Methods */

/**
 * Causes Notification to fade into the view.
 */
- (void)displayMessage {
	dispatch_async(dispatch_get_main_queue(), ^{
		if(!self.currentNotificationView.isVisible) {
			LocalNotificationType messageType = self.currentNotificationView.notificationType;
			
			[self dispatchNotificationMessageWithName:kNotificationDidDismissWithMessageType object:@(messageType)];
			
			self.currentNotificationView.alpha = 0.0f;
			
			self.dissolveTimer = [NSTimer scheduledTimerWithTimeInterval:kDefaultDuration target:self selector:@selector(dissolve) userInfo:nil repeats:NO];
			
			[self.currentNotificationView resetFramesWithHeight:kNotificationHeight];
			
			[self.overlayWindow addSubview:self.currentNotificationView];
			[self.overlayWindow bringSubviewToFront:self.currentNotificationView];
			
			// Display notification.
			[UIView animateWithDuration:kAnimationDuration
								  delay:0
								options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
							 animations:^{
								 CGRect myRect = CGRectMake(self.currentNotificationView.frame.origin.x, self.currentNotificationView.frame.origin.y, self.currentNotificationView.frame.size.width, self.currentNotificationView.frame.size.height);
								 self.currentNotificationView.frame = myRect;
								 self.currentNotificationView.alpha = 1.0f;
							 }
							 completion:^(BOOL finished) {
								 self.currentNotificationView.isVisible = YES;
								 [self dispatchNotificationMessageWithName:kNotificationDidDismissWithMessageType object:@(messageType)];
							 }];
			
			[self.currentNotificationView setNeedsDisplay];
		}
	});
}


/**
 * Causes notification to fade out.
 */
- (void)dissolve {
	dispatch_async(dispatch_get_main_queue(), ^{
		if(self.currentNotificationView.isVisible && !self.currentNotificationView.dissolving) {
			LocalNotificationType messageType = self.currentNotificationView.notificationType;
			self.currentNotificationView.dissolving = YES;
			
			// Dissolve notification.
			[self dispatchNotificationMessageWithName:kNotificationWillDismissWithMessageType object:@(messageType)];
			
			[UIView animateWithDuration:kAnimationDuration
								  delay:0
								options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
							 animations:^{
								 
								 self.currentNotificationView.frame = CGRectMake(self.currentNotificationView.frame.origin.x,  - kNotificationHeight, self.currentNotificationView.frame.size.width, self.currentNotificationView.frame.size.height);
								 self.currentNotificationView.alpha = 0.0f;
							 }
							 completion:^(BOOL finishezd) {
								 [self.dissolveTimer invalidate];
								 self.dissolveTimer = nil;
								 
								 self.currentNotificationView.isVisible = NO;
								 self.currentNotificationView.dissolving = NO;
								 
								 [self dispatchNotificationMessageWithName:kNotificationDidDismissWithMessageType object:@(messageType)];
								 
								 [self.queue removeObjectAtIndex:0];
								 if([self.queue count] > 0) {
									 self.currentNotificationView = (self.queue)[0];
									 
									 [self displayMessage];
								 }
								 else {
									 [self.overlayWindow removeFromSuperview];
								 }
							 }];
			
			[self.currentNotificationView setNeedsDisplay];
		}
	});
}

- (void)dissolveAction:(UISwipeGestureRecognizer *)swipe {
	[self.dissolveTimer invalidate];
	self.dissolveTimer = nil;
	[self dissolve];
}

- (void)switchViewAction{
	[self.dissolveTimer invalidate];
	self.dissolveTimer = nil;
	AppDelegate *appDelegate = (AppDelegate	*)[UIApplication sharedApplication].delegate;
	
	//Need to do something for displayViewForURL when implementing notification system
	//[appDelegate displayViewForURL:self.currentNotificationView.url];
	
	[self dissolve];
}
- (void)dispatchNotificationMessageWithName:(NSString *)name object:(id)object
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:name object:object];
	});
}

- (void)addObserver:(id<LocalNotificationObserver>)observer {
	if ([observer respondsToSelector:@selector(notificationWillDisplayWithMessageType)]) {
		[[NSNotificationCenter defaultCenter] addObserver:observer
												 selector:@selector(notificationWillDisplayWithMessageType)
													 name:kNotificationWillDisplayWithMessageType
												   object:nil];
	}
	
	if ([observer respondsToSelector:@selector(notificationDidDisplayWithMessageType)]) {
		[[NSNotificationCenter defaultCenter] addObserver:observer
												 selector:@selector(notificationDidDisplayWithMessageType)
													 name:kNotificationDidDisplayWithMessageType
												   object:nil];
	}
	
	if ([observer respondsToSelector:@selector(notificationWillDismissWithMessageType)]) {
		[[NSNotificationCenter defaultCenter] addObserver:observer
												 selector:@selector(notificationWillDismissWithMessageType)
													 name:kNotificationWillDismissWithMessageType
												   object:nil];
	}
	
	if ([observer respondsToSelector:@selector(notificationDidDismissWithMessageType)]) {
		[[NSNotificationCenter defaultCenter] addObserver:observer
												 selector:@selector(notificationDidDismissWithMessageType)
													 name:kNotificationDidDismissWithMessageType
												   object:nil];
	}
	
}

- (void)removeObserver:(id<LocalNotificationObserver>)observer {
	if (observer) {
		[[NSNotificationCenter defaultCenter] removeObserver:observer name:kNotificationWillDisplayWithMessageType object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:observer name:kNotificationDidDisplayWithMessageType object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:observer name:kNotificationWillDismissWithMessageType object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:observer name:kNotificationDidDismissWithMessageType object:nil];
	}
}

@end
