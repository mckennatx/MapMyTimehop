/*
 * UALoginViewController.m
 *
 * Copyright (c) 2015 Under Armour. All rights reserved.
 *
 */


#import "UALoginViewController.h"
#import "SplashView.h"

@import UASDK;

@interface UALoginViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, retain) SplashView *svc;
@property (nonatomic, strong) UIWebView *webView;

@end

// Login is required for the sample app, so there is no way to cancel out of the login webview.
@implementation UALoginViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.svc = [[SplashView alloc] init];
	self.svc.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, [UIApplication sharedApplication].keyWindow.frame.size.height);
	[[UIApplication sharedApplication].keyWindow addSubview:self.svc.view];

	
	//ask someone in graphics to make a mapmytimehop or mapmyhistory logo
//	UIImage *logo = [UIImage imageNamed:@"header_logo"];
//	logo.isAccessibilityElement = YES;
//	logo.accessibilityLabel = @"MapMyTimeHop";
//	UIImageView *imView = [[UIImageView alloc] initWithImage:logo];
//	imView.isAccessibilityElement = YES;
//	imView.accessibilityLabel = @"Header Image";
//	self.navigationItem.titleView = imView;
//	imView.frame = CGRectMake(imView.frame.origin.x, imView.frame.origin.y, imView.frame.size.width, imView.frame.size.height);

	self.title = @"mapmytimehop";

	self.navigationController.hidesBarsOnTap = YES;
	
	// Clear any cookies before showing the webview since
	NSHTTPCookie *cookie;
	NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	for (cookie in [storage cookies]){
		[storage deleteCookie:cookie];
	}
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:self.webView];
	
	// Grab the auth URL from the UASDK and present it in a webview.
	NSURL *authUrl = [[UA sharedInstance] requestUserAuthorizationUrl];
	
	if (authUrl) {
		// Note that the completion will be handled via a callback to the app delegate: application:openURL:sourceApplication:annotation:
		NSURLRequest *request = [NSURLRequest requestWithURL:authUrl];
		[self.webView loadRequest:request];
	}
	
	
	// Add back/forward support
	UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backSwipe)];
	backSwipe.direction = UISwipeGestureRecognizerDirectionRight;
	backSwipe.delegate = self;
	[self.webView addGestureRecognizer:backSwipe];
	
	UISwipeGestureRecognizer *forwardSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backSwipe)];
	forwardSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
	forwardSwipe.delegate = self;
	[self.webView addGestureRecognizer:forwardSwipe];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"dismiss" object:nil];
}

#pragma mark Gesture Recognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

- (void)backSwipe
{
	[self.webView goBack];
}

- (void)forwardSwipe
{
	[self.webView goForward];
}

- (void)dismiss{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.svc.view removeFromSuperview];
	});
}

@end
