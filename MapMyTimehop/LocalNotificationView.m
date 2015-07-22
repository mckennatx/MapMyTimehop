//
//  LocalNotificationView.m
//  iMapMy3
//
//  Created by Lauren Mckenna on 7/15/15.
//  Copyright (c) 2015 MapMyFitness. All rights reserved.
//

#import "LocalNotificationView.h"
#import "LocalNotificationController.h"

const CGFloat kNotificationHeight = 64;

@interface LocalNotificationView()

@property (nonatomic, strong) UIButton *notificationAction;
@property (nonatomic, strong) UILabel *notificationLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) SEL swipeSelector;
@property (nonatomic, weak) id target;

@end

@implementation LocalNotificationView

/**
 * When a new notification model is created, LocalNotificationManager will create a new view with the following params:
 * @param message: the message that will be displayed on the UILabel.text field (ie: Juan Pelota sent you a friend request)
 * @param url: the url that will be used to redirect to another view if the notification is pressed (ie: mmapps://friends)
 * @param target: target id that notificationAction is set to
 * @param swipe: selector set for the UIGesture 
 * @param action: selector set for the notificationAction
 */

- (id)initWithString:(NotificationModel *)notification target:(id)target swipeSelector:(SEL)swipe actionSelector:(SEL)action {
	self = [super initWithFrame:CGRectMake(0, kNotificationHeight, 320, kNotificationHeight)];
	if (self != nil) {
		
		/* Setting up notificationLabel and imageView and notificationAction
		 */
		self.isVisible = NO;
		self.alpha = 0.0f;
		self.notificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(kNotificationHeight/2 + 20, 5, 300, kNotificationHeight-2)];
		self.notificationLabel.textColor = [UIColor whiteColor];
		self.notificationLabel.backgroundColor = [UIColor clearColor];
		self.notificationLabel.adjustsFontSizeToFitWidth = YES;
		self.notificationLabel.minimumScaleFactor = 8.0f/12.0f;
		self.notificationLabel.textAlignment = NSTextAlignmentLeft;
		self.notificationLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		self.notificationLabel.font = [UIFont systemFontOfSize:13.5];
		self.notificationLabel.numberOfLines = 2;
		self.notificationLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		
		self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, [UIApplication sharedApplication].statusBarFrame.size.height-1, kNotificationHeight/2, kNotificationHeight/2)];
		self.imageView.contentMode = UIViewContentModeScaleAspectFit;
		
		[self addSubview:self.imageView];
		
		self.layer.shadowOffset = CGSizeMake(0, 1);
		self.layer.shadowOpacity = 0.35f;
		self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
		self.layer.shadowRadius = 0.5;
		
		[self addSubview:self.notificationLabel];
		
		if(!self.notificationAction) {
			self.notificationAction = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, kNotificationHeight)];
			self.notificationAction.backgroundColor = [UIColor clearColor];
		}
		
		[self bringSubviewToFront:self.notificationAction];
		
		if(!self.notificationAction.superview) {
			[self addSubview:self.notificationAction];
		}
		
		/* Set the message, url, notificationType, and notificationLabel respectively.
		 */
		self.notificationLabel.text = notification.message;
		self.url = [[NSURL alloc] initWithString:notification.url];
		self.notificationType = notification.notificationType;
		/* Set the color of the UILabel and UIImage based on the target app and the notificationType
		 */
		UIColor *color;
#if defined(RIDE) || defined(RIDEPLUS)
		color = HEXCOLOR(0xBF2D22FF);
#elif defined(RUN) || defined(RUNPLUS)
		color = HEXCOLOR(0x0d7dc3FF);
#elif defined(FITNESS) || defined(FITNESSPLUS)
		color = HEXCOLOR(0x33568eFF);
#elif defined(HIKE) || defined(HIKEPLUS)
		color = HEXCOLOR(0x558e4bFF)
#elif defined(WALK) || defined(WALKPLUS)
		color = HEXCOLOR(0x854b90FF)
#elif DOGWALK
		color = HEXCOLOR(0xDD9100FF)
#endif
		
		//still TODO: set image for each messageType
		//Two ways to set the image:
		//1. image from a .png file: [_imageView setImage:[UIImage imageNamed:@"first_badge.png"]];
		//2. image from user id: [_imageView setImageWithURL:[NSURL URLWithString:[StringUtils avatarUrlForUserID:@"11626004"]]];
		switch(self.notificationType) {
			case kFeedStoryNotification:
				//TODO: set image
				//[_imageView setImage:[UIImage imageNamed:@"first_badge.png"]];
				break;
			case kFriendRequestNotification:
				//TODO: set image
				[self.imageView setImage:[UIImage imageNamed:@"add_friends_icon.png"]];
				break;
			case kLiveTrackNotification:
				//TODO: set image
				//[_imageView setImage:[UIImage imageNamed:@"add_friends_icon.png"]];
				break;
			case kWorkoutNotification:
				//TODO: set image
				//[_imageView setImage:[UIImage imageNamed:@"challenge_type_workouts.png"]];
				break;
			case kWorkoutCommentNotification:
				//TODO: set image
				//[_imageView setImage:[UIImage imageNamed:@"add_friends_icon.png"]];
				break;
			case kRouteNotification:
				//TODO: set image
				//[_imageView setImage:[UIImage imageNamed:@"add_friends_icon.png"]];
				break;
			case kCourseNotification:
				//TODO: set image
				//[_imageView setImage:[UIImage imageNamed:@"add_friends_icon.png"]];
				break;
			case kGoMVPNotification:
				//TODO: set image
				[self.imageView setImage:[UIImage imageNamed:@"flame.png"]];
				break;
		}
		
		self.backgroundColor = color;
	}
	
	/* Set the notificationAction targets for dismissing and tapping the notification
	 if the user swipes up on the notification view, it will be dismissed
	 if the user taps the notification view, the view notification is about will be loaded
	 */
	[self.notificationAction removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
	self.target = target;
	UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self.target
																					   action:swipe];
	swipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
	[self.notificationAction addGestureRecognizer:swipeGesture];
	[self.notificationAction addTarget:self.target action:action forControlEvents:UIControlEventTouchUpInside];

	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect frame = self.frame;
	frame.size.width = [[UIApplication sharedApplication] keyWindow].frame.size.width;
	
	self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height);
	
	self.notificationLabel.frame = CGRectMake(self.notificationLabel.frame.origin.x, self.notificationLabel.frame.origin.y, self.notificationLabel.frame.size.width, self.notificationLabel.frame.size.height);
	
	self.notificationAction.frame = CGRectMake(self.notificationAction.frame.origin.x, self.notificationAction.frame.origin.y, frame.size.width, self.notificationAction.frame.size.height);
	
	self.frame = frame;
}

- (void)resetFramesWithHeight:(CGFloat)height {
	self.frame = CGRectMake(self.frame.origin.x, -height, self.frame.size.width, height);
	
	self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height);
	
	self.notificationLabel.frame = CGRectMake(self.notificationLabel.frame.origin.x, self.notificationLabel.frame.origin.y, self.notificationLabel.frame.size.width, self.notificationLabel.frame.size.height);
	
	self.notificationAction.frame = CGRectMake(0, 0, self.frame.size.width, height);
}

@end
