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
#import "LifetimeStatsCell.h"

@import UASDK;

@interface SettingsViewController ()

@property (nonatomic, strong) UINavigationBar* navigationBar;

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UIImageView *icons;

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *member;
@property (weak, nonatomic) IBOutlet UILabel *location;

@property (weak, nonatomic) IBOutlet UIButton *logout;
@property (weak, nonatomic) IBOutlet UIButton *doWorkout;

@property (nonatomic, retain) UAUser *user;

@property (nonatomic, assign) BOOL finishedLoading;

@property (weak, nonatomic) IBOutlet UITableView *statsTable;

@property (nonatomic, copy) NSArray	*descriptions;
@property (nonatomic, copy) NSArray *stats;
@property (nonatomic, copy) NSArray *images;

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

	self.descriptions = [self buildDescriptions];
	self.stats = [self buildStats];
	self.images = [self buildImages];
	
	self.view.backgroundColor = [UICustomColors backgroundGray];
	self.statsTable.backgroundColor = [UICustomColors backgroundGray];
	self.statsTable.rowHeight = [LifetimeStatsCell rowHeight];

	self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0,[[UIApplication sharedApplication] keyWindow].frame.size.width, 64)];
	self.navigationItem.title = @"Settings";
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"x"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissView)];
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
	[self.statsTable reloadData];
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

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.descriptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	static NSString *CellIdentifier = @"Cell";
	LifetimeStatsCell *cell = [self.statsTable dequeueReusableCellWithIdentifier:CellIdentifier];
	if(!cell) {
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LifetimeStatsCell" owner:self options:nil];
		cell = topLevelObjects[0];
		//cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	cell.title.text = self.descriptions[indexPath.row];
	cell.value.text = self.stats[indexPath.row];
	[cell.image setImage:self.images[indexPath.row]];


//	UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(7, 0, 115, 70)];
//	UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(125, 0, 220, 70)];
//	
//	cell.backgroundColor = [UICustomColors backgroundGray];
//	stats.font = [UIFont boldSystemFontOfSize:40];
//	stats.textAlignment = NSTextAlignmentCenter;
//	stats.textColor = [UIColor grayColor];
//	stats.adjustsFontSizeToFitWidth = YES;
//	stats.minimumScaleFactor = 5.0/[UIFont labelFontSize];
//	
//	description.font = [UIFont systemFontOfSize:15];
//	description.textColor = [UIColor grayColor];
//	
//	description.text = self.descriptions[indexPath.row];
//	stats.text = self.stats[indexPath.row];
//	
//	[cell addSubview:stats];
//	[cell addSubview:description];
	
	return cell;
}


#pragma mark - Memory Management
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	NSLog(@"memory warning received");
	// Dispose of any resources that can be recreated.
	self.descriptions = nil;
	self.stats = nil;
}

- (NSMutableArray *)buildDescriptions
{
	return [@[
			  @"COMPLETED ACTIVITIES",
			  @"TOTAL CALORIES BURNED",
			  @"TOTAL MILES",
			  @"TOTAL WORKOUT DURATION",
			  ] mutableCopy];
}

- (NSMutableArray *)buildImages
{
	UIImage *completedAct, *calories, *distance, *duration;
	completedAct = [UIImage imageNamed:@"challenge_type_steps"];
	calories = [UIImage imageNamed:@"challenge_type_calories"];
	distance = [UIImage imageNamed:@"challenge_type_distance"];
	duration = [UIImage imageNamed:@"challenge_type_time"];
	
	return [@[
			  completedAct,
			  calories,
			  distance,
			  duration] mutableCopy];
}

- (NSMutableArray *)buildStats
{
	UAUserStats *lifetimeSum = [SettingsModel sharedInstance].lifetimeSummary;
	NSString *activityCount, *calories, *distance, *duration;
	
	activityCount = [lifetimeSum.activityCount stringValue];
	calories = [Conversions rollupStringForNumber:@([Conversions convertJoulesToCalories:[lifetimeSum.energy doubleValue]])];
	distance = [Conversions rollupStringForNumber:@([Conversions distanceInUserUnits:[lifetimeSum.distance doubleValue] measurement:self.user.displayMeasurementSystem])];
	duration = [Conversions secondsToHMS:[lifetimeSum.duration integerValue]];
	
	return [@[
			  activityCount,
			  calories,
			  distance,
			  duration
			  ] mutableCopy];
}

@end
