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
#import "LifeTimeCollectionCell.h"
#import "SelectedStatCell.h"

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

@property (strong, nonatomic) IBOutlet UICollectionView *statsCollection;

@property (nonatomic, copy) NSArray	*descriptions;
@property (nonatomic, copy) NSArray *stats;
@property (nonatomic, copy) NSArray *selectedStats;
@property (nonatomic, copy) NSArray *images;
@property (nonatomic, copy) NSArray *selectedCellTitle;

@property (nonatomic, assign) BOOL dontHighlight;

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

	self.descriptions = [self buildTitles:YES];
	self.stats = [self buildStats:YES];
	self.images = [self buildImages];
	self.selectedCellTitle = [self buildTitles:NO];
	self.selectedStats	= [self buildStats:NO];

	[self.statsCollection registerClass:[LifeTimeCollectionCell class] forCellWithReuseIdentifier:@"CollectionCell"];
	
	UINib *nib = [UINib nibWithNibName:@"LifeTimeCollectionCell" bundle:nil];
	[self.statsCollection registerNib:nib
	   forCellWithReuseIdentifier:@"CollectionCell"];
	
	nib = [UINib nibWithNibName:@"SelectedStatCell" bundle:nil];
	[self.statsCollection registerNib:nib
		   forCellWithReuseIdentifier:@"SelectedCell"];
	
	self.view.backgroundColor = [UICustomColors backgroundGray];
	self.statsCollection.backgroundColor = [UICustomColors backgroundGray];

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
}

- (IBAction)logout:(id)sender {
	UIAlertAction *logOutAction;
	UIAlertAction *cancelAction;
	UIAlertController *alertController= [UIAlertController alertControllerWithTitle:@"Are you sure you want to log out?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	logOutAction = [UIAlertAction actionWithTitle:@"Log Out"
											 style:UIAlertActionStyleDestructive
										   handler:^(UIAlertAction *action) {
											   [[UA sharedInstance] logout:^(NSError *error) {
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

#pragma mark - Collection view data source


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [self.stats count]/2;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
	return [self.stats count]/2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return CGSizeMake(160, 160);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"CollectionCell";

	LifeTimeCollectionCell *cell= (LifeTimeCollectionCell *)[self.statsCollection dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
	
	int index = 0;
	if(indexPath.section == 0 && indexPath.row == 1) {
		index = 1;
	}else if(indexPath.section == 1 && indexPath.row == 0) {
		index = 2;
	}else if(indexPath.section == 1 && indexPath.row == 1) {
		index = 3;
	}
	[cell.image setImage:self.images[index]];
	[cell.stats setText:self.stats[index]];
	[cell.title setText:self.descriptions[index]];
	cell.index = index;
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"CollectionCell";
	
	LifeTimeCollectionCell *statCell= [self.statsCollection dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
	
	LifeTimeCollectionCell* cell = (LifeTimeCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];

	statCell.title.text = self.selectedCellTitle[cell.index];
	statCell.stats.text = self.selectedStats[cell.index];
	[statCell.image setImage:self.images[cell.index]];
	
	statCell.title.adjustsFontSizeToFitWidth = YES;

	self.dontHighlight = YES;
	[UIView transitionFromView:cell.contentView
						toView:statCell.contentView
					  duration:.5
					   options:UIViewAnimationOptionTransitionFlipFromLeft
					completion:^(BOOL finished){
						double delayInSeconds = 2.0;
						dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
						dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
							[self reset:cell dismiss:statCell];
						});
					}];
}

- (void)reset:(UICollectionViewCell *)cell dismiss:(UICollectionViewCell *)dismissCell {
		[UIView transitionFromView:dismissCell.contentView
							toView:cell.contentView
						  duration:.5
						   options:UIViewAnimationOptionTransitionFlipFromLeft
						completion:^(BOOL finished){
							self.dontHighlight = NO;
						}];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	if(self.dontHighlight) {
		return false;
	}
	return true;
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	NSLog(@"memory warning received");
	// Dispose of any resources that can be recreated.
	self.descriptions = nil;
	self.stats = nil;
}

- (NSMutableArray *)buildTitles:(BOOL)lifetime
{
	NSString *distance;
	
	if(lifetime) {
		distance = @"total miles";
		if([SettingsModel sharedInstance].user.displayMeasurementSystem == UADisplayMeasurementMetric) {
			distance = @"total kilometers";
		}
		return [@[
				  @"completed activities",
				  @"total calories burned",
				  distance,
				  @"total workout duration",
				  ] mutableCopy];
	}
	
	distance = @"weekly miles";
	if([SettingsModel sharedInstance].user.displayMeasurementSystem == UADisplayMeasurementMetric) {
		distance = @"weekly kilometers";
	}
	
	return [@[
			  @"weekly completed activities",
			  @"weekly calories burned",
			  distance,
			  @"weekly workout duration",
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

- (NSMutableArray *)buildStats:(BOOL)lifetime
{
	UAUserStats *statsSum;
	if(lifetime)
		statsSum = [SettingsModel sharedInstance].lifetimeSummary;
	else
		statsSum = [SettingsModel sharedInstance].weeklySummary;

	NSString *activityCount, *calories, *distance, *duration;
	
	activityCount = [statsSum.activityCount stringValue];
	calories = [Conversions rollupStringForNumber:@([Conversions convertJoulesToCalories:[statsSum.energy doubleValue]])];
	distance = [Conversions rollupStringForNumber:@([Conversions distanceInUserUnits:[statsSum.distance doubleValue] measurement:[SettingsModel sharedInstance].user.displayMeasurementSystem])];
	
	duration = [Conversions secondsToHMS:[statsSum.duration integerValue]];
	
	return [@[
			  activityCount,
			  calories,
			  distance,
			  duration
			  ] mutableCopy];
}

@end
