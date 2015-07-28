//
//  MMTimeHopViewController.m
//  MapMyTimehop
//
//  Created by Lauren Mckenna on 7/20/15.
//
//

#import <MapKit/MapKit.h>
#import "MMTimeHopViewController.h"
#import "AppDelegate.h"
#import "UALoginViewController.h"
#import "TableHeaderView.h"
#import "LoadingView.h"
#import "SettingsViewController.h"
#import "Conversions.h"
#import "UICustomColors.h"
#import "WorkoutCell.h"
#import "SettingsModel.h"

static const NSInteger maxLoad = 4;
static NSString *kWorkoutDetails = @"mmapps://workouts/details/?id=%@";

@interface MMTimeHopViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, copy) NSArray *tableHeaders;
@property (nonatomic, copy) NSArray *sectionColors;

@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, retain) NSMutableArray *workouts;

@property (nonatomic, copy) UAWorkoutListRef *workoutListRef;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, assign) NSInteger numLoaded;

@property (nonatomic, assign) BOOL pullToRefresh;
@property (nonatomic, assign) BOOL allWorkoutsLoaded;

@property (nonatomic, strong) WorkoutToDisplay *oneMonth;
@property (nonatomic, strong) WorkoutToDisplay *oneYear;
@property (nonatomic, strong) WorkoutToDisplay *twoYear;
@property (nonatomic, strong) WorkoutToDisplay *threeYear;

@end

@implementation MMTimeHopViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	UIImage *logo = [UIImage imageNamed:@"header_logo"];
	logo.isAccessibilityElement = YES;
	logo.accessibilityLabel = @"MapMyTimeHop";
	UIImageView *imView = [[UIImageView alloc] initWithImage:logo];
	imView.isAccessibilityElement = YES;
	imView.accessibilityLabel = @"Header Image";
	self.navigationItem.titleView = imView;
	imView.frame = CGRectMake(imView.frame.origin.x, imView.frame.origin.y, imView.frame.size.width, imView.frame.size.height);

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear.png"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsView)];

	self.tableView.rowHeight = [WorkoutCell cellHeight];
	self.tableHeaders = [self buildTableHeaders];
	self.sectionColors = [self buildSectionColors];
	self.tableView.sectionHeaderHeight = [TableHeaderView defaultHeight];
	self.tableView.separatorColor = [UIColor clearColor];
	self.tableView.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [UICustomColors backgroundGray];
	
	if(![SettingsModel sharedInstance].allWorkoutsLoaded)
		[LoadingView showModalLoadingViewWithText:@"loading workouts..."];
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	self.refreshControl.backgroundColor = [UICustomColors backgroundGray];
	self.refreshControl.tintColor = [UIColor whiteColor];

	[self.refreshControl addTarget:self
							action:@selector(updateWorkouts)
				  forControlEvents:UIControlEventValueChanged];
	[self.tableView addSubview:self.refreshControl];
	
	[self fetchUser];
	
	self.workouts = [[NSMutableArray alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTable) name:@"reloadTable" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedOut) name:@"loggedOut" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if(![SettingsModel sharedInstance].allWorkoutsLoaded) {
		NSDate *date = [self previousDate:kOneMonth];
		self.oneMonth = [[WorkoutToDisplay alloc] initWithFilterDate:date];
		date = [self previousDate:kOneYear];
		self.oneYear = [[WorkoutToDisplay alloc] initWithFilterDate:date];
		date = [self previousDate:kTwoYear];
		self.twoYear = [[WorkoutToDisplay alloc] initWithFilterDate:date];
		date = [self previousDate:kThreeYear];
		self.threeYear = [[WorkoutToDisplay alloc] initWithFilterDate:date];
		[self.tableView reloadData];
		
		[self fetchUser];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[self.view removeFromSuperview];
}

#pragma mark - NSNotification Observor Methods
- (void)loggedOut {
	NSLog(@"logged out");
	self.oneMonth = nil;
	self.oneYear = nil;
	self.twoYear = nil;
	self.threeYear = nil;
	self.numLoaded = 0;
	[self.workouts removeAllObjects];
	[SettingsModel sharedInstance].allWorkoutsLoaded = NO;
	[self.tableView reloadData];
}

- (void)updateTable {
	++self.numLoaded;
	if(self.numLoaded == maxLoad-1) {
		[self.workouts addObject:self.oneMonth];
		[self.workouts addObject:self.oneYear];
		[self.workouts addObject:self.twoYear];
		[self.workouts addObject:self.threeYear];

		[SettingsModel sharedInstance].allWorkoutsLoaded = YES;
		[LoadingView dismissModalLoadingView];
		if(self.pullToRefresh)
			[self.refreshControl endRefreshing];
	}
	
	[self.tableView reloadData];
}

- (void)updateWorkouts {
	self.pullToRefresh = YES;
	[SettingsModel sharedInstance].allWorkoutsLoaded = NO;
	self.numLoaded = 0;
	[self.workouts removeAllObjects];
	[self.oneMonth refresh];
	[self.oneYear refresh];
	[self.twoYear refresh];
	[self.threeYear refresh];
}

- (void)settingsView {
	SettingsViewController *svc = [[SettingsViewController alloc] init];
	svc.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
	[self presentViewController:svc animated:YES completion:nil];
}



#pragma mark - Table view data source
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width/2, 24)];
	label.layer.cornerRadius = 5;
	label.clipsToBounds = YES;
	[label setFont:[UIFont systemFontOfSize:17]];
	[label setTextColor:[UIColor whiteColor]];
	[label setTextAlignment:NSTextAlignmentCenter];
	[label setText:[[self.tableHeaders objectAtIndex:section] uppercaseString]];
	[label setBackgroundColor:[self.sectionColors objectAtIndex:section]];

	
	[view addSubview:label];
	
	return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 22)];
	[label setFont:[UIFont systemFontOfSize:13]];
	[label setTextColor:[UIColor grayColor]];
	[label setTextAlignment:NSTextAlignmentCenter];
	
	if([SettingsModel sharedInstance].allWorkoutsLoaded)
		label.text = [NSString stringWithFormat:@"TOTAL CALORIES BURNED: %d", (int) [[self.workouts objectAtIndex:section]totalCalories]];
	
	[view addSubview:label];
	
	return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:
(NSInteger)section{
	return 44.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:
(NSInteger)section{
	return 38.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.tableHeaders count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger count=1;
	
	if([SettingsModel sharedInstance].allWorkoutsLoaded) {
		if([[self.workouts objectAtIndex:section] hasPastWorkoutFromTodaysDate]) {
			count = [[[self.workouts objectAtIndex:section] pastWorkoutsFromDate] count];
		}
	}
	
	return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	
	WorkoutCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil) {
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"WorkoutCell" owner:self options:nil];
		cell = topLevelObjects[0];
	}
	
	if([SettingsModel sharedInstance].allWorkoutsLoaded) {
		if([[self.workouts objectAtIndex:indexPath.section] hasPastWorkoutFromTodaysDate]) {
			[cell setWorkout:[[[self.workouts objectAtIndex:indexPath.section] pastWorkoutsFromDate] objectAtIndex:indexPath.row]];
		}
		else
			[cell setNoWorkout];
	}
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if([[self.workouts objectAtIndex:indexPath.section] hasPastWorkoutFromTodaysDate]) {
		UAWorkout *workout = [[[self.workouts objectAtIndex:indexPath.section] pastWorkoutsFromDate] objectAtIndex:indexPath.row];

		NSString *stringURL = [NSString stringWithFormat:kWorkoutDetails, workout.ref.entityID];
		NSURL *url = [NSURL URLWithString:stringURL];
		if([[UIApplication sharedApplication] canOpenURL:url]) {
			[[UIApplication sharedApplication] openURL:url];
		} else {
			url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/map-my-fitness-gps-workout/id298903147?mt=8"];
			[[UIApplication sharedApplication] openURL:url];
		}
	} else {
		UIAlertAction *workout;
		UIAlertAction *cancelAction;
		NSString *message = [NSString stringWithFormat:@"No workouts recorded %@", self.tableHeaders[indexPath.section]];
		UIAlertController *alertController= [UIAlertController alertControllerWithTitle:@"No Workouts Found" message:message preferredStyle:UIAlertControllerStyleAlert];
		
		workout = [UIAlertAction actionWithTitle:@"Record a Workout"
										   style:UIAlertActionStyleDefault
										   handler:^(UIAlertAction *action) {
											   NSURL *url = [NSURL URLWithString:@"mmapps://"];
											   if([[UIApplication sharedApplication] canOpenURL:url]) {
												   [[UIApplication sharedApplication] openURL:url];
											   } else {
												   url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/map-my-fitness-gps-workout/id298903147?mt=8"];
												   [[UIApplication sharedApplication] openURL:url];
											   }
										   }];
		cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
												style:UIAlertActionStyleDestructive
											  handler:^(UIAlertAction *action) {
												  //cancel
											  }];
		
		[alertController addAction:workout];
		[alertController addAction:cancelAction];
		alertController.view.tintColor = [UIColor blueColor];
		
		[self presentViewController:alertController animated:YES completion:nil];
	}
}

#pragma mark - Menu Generation Methods
- (NSMutableArray *)buildTableHeaders
{
	return [@[
			  @"1 month ago",
			  @"1 year ago",
			  @"2 years ago",
			  @"3 years ago",
			  ] mutableCopy];
}

- (NSMutableArray *)buildSectionColors
{
	UIColor *color1, *color2, *color3, *color4;
	color1 = [UIColor colorWithRed:0.67 green:0.71 blue:0.89 alpha:1.0];
	color2 = [UIColor colorWithRed:0.88 green:0.55 blue:0.62 alpha:1.0];
	color3 = [UIColor colorWithRed:0.47 green:0.72 blue:0.58 alpha:1.0];
	color4 = [UIColor colorWithRed:0.25 green:0.46 blue:0.58 alpha:1.0];
	return [@[
			  color1,
			  color2,
			  color3,
			  color4] mutableCopy];
}

#pragma mark - Login Methods
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

#pragma mark - Fetch User Information and Activities and Helper Methods
/* Returns NSDate to previous month, year, etc.
 * @param diff is a timeDiff enum that is either 1 month, 1 year, 2 year, or 3 years ago
 */
- (NSDate *)previousDate:(timeDiff)diff {
	NSDate *today = [[NSDate alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
	if(diff == kOneMonth)
		[offsetComponents setMonth:-1]; // setting date to 1 month ago
	else
		[offsetComponents setYear:-diff]; // setting year to diff
	[offsetComponents setDay:+1];
	NSDate *date = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
	
	return date;
}

- (void)fetchUser {
	[[[UA sharedInstance] userManager] fetchAuthenticatedUser:^(UAUser *user, NSError *error) {
		if(!error) {
			[[SettingsModel sharedInstance] setUser:user];
			[self fetchAllTimeStats];
		}
	}];
}

- (void)fetchAllTimeStats
{
	UAUserRef *userRef = [UAUserRef userRefWithUserID:[SettingsModel sharedInstance].user.userID];
	UAUserStatsReportRef *userStatsReportRef = [UAUserStatsReportRef userStatsReportRefForUserRef:userRef dateRange:nil aggregationPeriod:UAAggregationPeriodTypeLifetime includeSummaryStats:YES];
	
	UAUserStatsManager *manager = [[UA sharedInstance] userStatsManager];
	[manager fetchUserStatsWithRef:userStatsReportRef response:^(id object, NSError *error) {
		UAUserStatsReport *response = (UAUserStatsReport*)object;
		if (error == nil) {
			if (response.summary.count > 0) {
				[[SettingsModel sharedInstance] setLifetimeSummary:[response.summary firstObject]];
			}
		}
	}];
}

//This method should be called when setting up future notifications
//add completion block
- (void)pullWorkoutsWithBlock:(void (^)())complete
{
	NSDate *date = [[NSDate alloc] init];
	_listArray = [NSMutableArray array];
	_workoutListRef = [UAWorkoutListRef workoutListRefWithUserReference:[[UA sharedInstance] authenticatedUserRef] createdBefore:date];
	
	UAWorkoutManager *workoutManager = [[UA sharedInstance] workoutManager];
	
	__block void (^requestBlock)(void);
	
	void(^responseBlock)(UAWorkoutList *list) = ^(UAWorkoutList *list){
		BOOL nextPageAvailable = list.nextRef != nil;
		
		[_listArray addObject:list.objects];
		
		if(nextPageAvailable) {
			_workoutListRef = list.nextRef;
			requestBlock();
		}
		else {
			NSLog(@"no more workouts");
			complete();
		}
	};
	
	requestBlock = ^{
		[workoutManager fetchWorkoutsWithListRef:_workoutListRef
								 withCachePolicy:UACacheElseNetwork
										response:^(UAWorkoutList *list, NSError *error) {
											if (!error) {
												responseBlock((UAWorkoutList *)list);
											}
											else {
												UALogError(@"Error retriving available workouts: %@", error);
											}
										}];
	};
	
	requestBlock();
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	NSLog(@"MMTIMEHOP: memory warning received");
	self.allWorkoutsLoaded = NO;
	self.oneMonth = nil;
	self.oneYear = nil;
	self.twoYear = nil;
	self.threeYear = nil;
	[self.workouts removeAllObjects];
}

@end
