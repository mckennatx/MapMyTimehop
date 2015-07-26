//
//  AppDelegate.m
//  MapMyTimehop
//
//  Created by Lauren Mckenna on 7/20/15.
//
//

#import "AppDelegate.h"
#import "MMTimeHopViewController.h"
#import "UASDKConfig.h"
#import "UALoginViewController.h"
#import "Conversions.h"

@import UASDK;

/**
 *  Define the keys used for this app
 */
NSString * const kUASKAPIConsumerKey = @"haf8tyffyd9bc7nnbm62436ncg4b2umx";
NSString * const kUASKAPISecret = @"ggePJ2HUHVuNn4VvHANCfrngRKSDn5TKUZxB6Eaf7EY";
NSString * const kUASKAPIRecorderTypeKey = nil;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	[UA initializeWithApplicationConsumer:[UASDKConfig apiKey]
						applicationSecret:[UASDKConfig apiSecret]];
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	if([[UA sharedInstance] authenticatedUserRef] == nil) {
		UALoginViewController *vc = [[UALoginViewController alloc] init];
		self.navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
		self.window.rootViewController = self.navigationController;
	}
	
	else {
		self.timeHopViewController = [[MMTimeHopViewController alloc] init];
		self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.timeHopViewController];
		self.window.rootViewController = self.navigationController;
		
	}
	
	[self setAppearance];
	
	[self.window makeKeyAndVisible];
	
	
	return YES;
}

- (void)setAppearance
{
	self.window.tintColor = [UIColor whiteColor];
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
	
	//UIColor *barTint = [UIColor colorWithRed:0.90 green:0.45 blue:0.00 alpha:1.0];
	UIColor *barTint = [UIColor colorWithRed:0.16 green:0.81 blue:0.77 alpha:1.0];
	
	[[UINavigationBar appearance] setBarTintColor:barTint];
	[[UIToolbar appearance] setBarStyle:UIBarStyleBlackTranslucent];
	[[UIToolbar appearance] setBarTintColor:barTint];
	[[UIToolbar appearance] setTintColor:[UIColor whiteColor]];
	
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
	
	[[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
	[[UINavigationBar appearance] setTitleTextAttributes:@{
														   NSForegroundColorAttributeName : [UIColor whiteColor],
														   NSFontAttributeName      : [UIFont boldSystemFontOfSize:18]
														   }];
	
	[[UIBarButtonItem appearance] setTitleTextAttributes:@{ NSFontAttributeName : [UIFont boldSystemFontOfSize:14] } forState:UIControlStateNormal];
	[[UIBarButtonItem appearance] setTitleTextAttributes:@{ NSFontAttributeName : [UIFont boldSystemFontOfSize:14] } forState:UIControlStateHighlighted];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	if ([[UA sharedInstance] handleUrl:url
							  response:^(UAUser *user, NSError *error) {
								  [self.timeHopViewController refreshLoginState];
							  }])
	{
		return YES;
	}
	
	return NO;
}

@end
