//
//  SettingsViewController.m
//  MapMyTimehop
//
//  Created by Lauren Mckenna on 7/23/15.
//
//

#import "SettingsViewController.h"
#import "UALoginViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Conversions.h"
#import "UICustomColors.h"
#import "SettingsModel.h"

@import UASDK;

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIView *statsView;
@property (weak, nonatomic) IBOutlet UIView *aboutMeView;
@property (weak, nonatomic) IBOutlet UIView *aboutMeSubView;

@property (nonatomic, strong) UINavigationBar* navigationBar;

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UIImageView *icons;

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *member;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *distanceVal;
@property (weak, nonatomic) IBOutlet UILabel *caloriesVal;
@property (weak, nonatomic) IBOutlet UILabel *activitiesVal;

@property (weak, nonatomic) IBOutlet UIButton *logout;
@property (weak, nonatomic) IBOutlet UIButton *doWorkout;

@property (nonatomic, retain) UAUser *user;

@property (nonatomic, assign) BOOL finishedLoading;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Settings";
	self.logout.layer.cornerRadius = 10;
	self.logout.clipsToBounds = YES;
	self.icons.contentMode = UIViewContentModeScaleAspectFit;
	self.doWorkout.layer.cornerRadius = 10;
	self.doWorkout.clipsToBounds = YES;
	self.doWorkout.backgroundColor = [UIColor colorWithRed:0.16 green:0.48 blue:0.80 alpha:1.0];
	self.avatar.layer.cornerRadius = self.avatar.frame.size.width /2;
	self.avatar.layer.masksToBounds = YES;

	self.view.backgroundColor = [UICustomColors backgroundGray];
	self.statsView.backgroundColor = [UICustomColors backgroundGray];
	
	self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0,[[UIApplication sharedApplication] keyWindow].frame.size.width, 64)];
	self.navigationItem.title = @"Settings";
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"rsz_x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissView)];
	[self.view addSubview:_navigationBar];
	[self.navigationBar pushNavigationItem:self.navigationItem animated:NO];
	[self fetchUser];
}

- (void)viewDidDisappear:(BOOL)animated {
	[self.view removeFromSuperview];
}

- (void)dismissView {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)fetchUser {
	UAUser *user = [SettingsModel sharedInstance].user;
	self.name.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy"];
	NSString *dateString = [formatter stringFromDate:user.dateJoined];
	
	self.member.text = [NSString stringWithFormat:@"Member since %@", dateString];
	self.location.text = [NSString stringWithFormat:@"%@, %@", user.locality, user.region];
	
	[self.avatar setImageWithURL:user.userProfilePhoto.largeImageUrl placeholderImage:[UIImage imageNamed:@"anon"]];
	
	UAUserStats *lifetimeSum = [SettingsModel sharedInstance].lifetimeSummary;
	[self setTotalCalories:@([Conversions convertJoulesToCalories:[lifetimeSum.energy doubleValue]])];
	
	[self setTotalDistance:lifetimeSum.distance];
	
	self.activitiesVal.text = [lifetimeSum.activityCount stringValue];
}

- (void)setTotalDistance:(NSNumber*)meters
{
	NSNumber *distance = @([Conversions distanceInUserUnits:[meters doubleValue] measurement:self.user.displayMeasurementSystem]);
	self.distanceVal.text = [Conversions rollupStringForNumber:distance];
}

- (void)setTotalCalories:(NSNumber*)kCal
{
	self.caloriesVal.text = [Conversions rollupStringForNumber:kCal];
}


- (IBAction)logout:(id)sender {
	UIAlertAction *logOutAction;
	UIAlertAction *cancelAction;
	UIAlertController *alertController= [UIAlertController alertControllerWithTitle:@"Are you sure you want to log out?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	logOutAction = [UIAlertAction actionWithTitle:@"Log Out"
											 style:UIAlertActionStyleDestructive
										   handler:^(UIAlertAction *action) {
											   [[UA sharedInstance] logout:^(NSError *error) {
												   //erase everything
												   [SettingsModel sharedInstance].user = nil;
												   [SettingsModel sharedInstance].lifetimeSummary = nil;
												   [SettingsModel sharedInstance].allWorkoutsLoaded = NO;
												   [[NSNotificationCenter defaultCenter] postNotificationName:@"loggedOut" object:nil];
												   [self showLogin:YES];
											   }];
										   }];
	cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
										   style:UIAlertActionStyleCancel
										 handler:^(UIAlertAction *action) {
											 //cancel
										 }];
	
	[alertController addAction:logOutAction];
	[alertController addAction:cancelAction];
	alertController.view.tintColor = [UIColor grayColor];
	alertController.popoverPresentationController.sourceView = self.view;
	[self presentViewController:alertController animated:YES
					 completion:nil];
}

- (void)showLogin:(BOOL)animated
{
	if (self.presentedViewController == nil) {
		UALoginViewController *vc = [[UALoginViewController alloc] init];
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
		
		[self presentViewController:navigationController animated:animated completion:nil];
	}
}
- (void)refreshLoginState
{
	if ([[UA sharedInstance] isAuthenticated] == NO) {
		[self showLogin:YES];
	}
	else {
		[self dismissViewControllerAnimated:YES completion:NULL];
	}
}

- (IBAction)openApp:(id)sender {
	NSURL *url = [NSURL URLWithString:@"mmapps://"];
	if([[UIApplication sharedApplication] canOpenURL:url]) {
		[[UIApplication sharedApplication] openURL:url];
	} else {
		url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/map-my-fitness-gps-workout/id298903147?mt=8"];
		[[UIApplication sharedApplication] openURL:url];
	}
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	NSLog(@"memory warning received");
	// Dispose of any resources that can be recreated.
}

@end
