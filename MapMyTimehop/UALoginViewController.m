/*
 * UALoginViewController.m
 *
 * Copyright (c) 2015 Under Armour. All rights reserved.
 *
 */


#import "UALoginViewController.h"

@import UASDK;

@interface UALoginViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

// Login is required for the sample app, so there is no way to cancel out of the login webview.
@implementation UALoginViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
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

@end
