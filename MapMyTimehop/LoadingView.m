/*
 * LoadingView.m
 *
 * Adapted from the UASDK Tutorial App
 * Copyright (c) 2015 Under Armour. All rights reserved.
 *
 */


#import "LoadingView.h"

@interface LoadingView ()

@property (nonatomic, strong) UIView *loadingBackground;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorIndicatorView;
@property (nonatomic, strong) UILabel *label;

@end

@implementation LoadingView

static LoadingView *loadingView = nil;

+ (LoadingView *)sharedInstance {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		loadingView = [[LoadingView alloc] initWithFrame:[[[UIApplication sharedApplication] keyWindow] frame]];
	});
	return loadingView;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		CGSize loadingViewSize = CGSizeMake(170.0, 150.0);
		
		_loadingBackground = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - loadingViewSize.width) / 2.0, (frame.size.height - loadingViewSize.height) / 2.0, 170, 150)];
		_loadingBackground.backgroundColor = [UIColor colorWithWhite:0.25 alpha:0.75];
		_loadingBackground.clipsToBounds = YES;
		_loadingBackground.layer.cornerRadius = 5.0;
		
		_activityIndicatorIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_activityIndicatorIndicatorView.frame = CGRectMake(65, 40, _activityIndicatorIndicatorView.bounds.size.width, _activityIndicatorIndicatorView.bounds.size.height);
		[_loadingBackground addSubview:_activityIndicatorIndicatorView];
		[_activityIndicatorIndicatorView startAnimating];
		
		_label = [[UILabel alloc] initWithFrame:CGRectMake(20, 115, 130, 22)];
		_label.backgroundColor = [UIColor clearColor];
		_label.textColor = [UIColor whiteColor];
		_label.adjustsFontSizeToFitWidth = YES;
		_label.textAlignment = NSTextAlignmentCenter;
		_label.text = @"Loading...";
		_label.font = [UIFont boldSystemFontOfSize:15.0f];
		[_loadingBackground addSubview:_label];
		
		[self addSubview:_loadingBackground];
	}
	return self;
}

+ (void)showModalLoadingViewWithText:(NSString *)text {
	LoadingView *view = [self sharedInstance];
	view.label.text = text;
	
	[[[UIApplication sharedApplication] keyWindow] addSubview:view];
}

+ (void)dismissModalLoadingView {
	[[LoadingView sharedInstance] removeFromSuperview];
}

@end
