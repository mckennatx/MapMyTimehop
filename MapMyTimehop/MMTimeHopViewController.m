//
//  MMTimeHopViewController.m
//  MapMyTimehop
//
//  Created by Lauren Mckenna on 7/20/15.
//
//

#import "MMTimeHopViewController.h"
#import "AppDelegate.h"
#import "UALoginViewController.h"
#import "TableHeaderView.h"
#import "LoadingView.h"
#import "SettingsViewController.h"
#import "Conversions.h"
#import "WorkoutCell.h"
#import "SettingsModel.h"

static const NSInteger maxLoad = 4;

@interface MMTimeHopViewController ()

@property (nonatomic, copy) NSArray *tableHeaders;
@property (nonatomic, copy) NSArray *sectionColors;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, assign) NSInteger numLoaded;
@property (nonatomic, copy) UAWorkoutListRef *workoutListRef;
@property (nonatomic, assign) BOOL pullToRefresh;
@property (nonatomic, assign) BOOL allWorkoutsLoaded;
@property (nonatomic, strong) WorkoutToDisplay *oneMonth;
@property (nonatomic, strong) WorkoutToDisplay *oneYear;
@property (nonatomic, strong) WorkoutToDisplay *twoYear;
@property (nonatomic, strong) WorkoutToDisplay *threeYear;

@property (nonatomic, retain) NSMutableArray *workouts;
@property (nonatomic, retain) NSMutableArray *allWorkouts;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation MMTimeHopViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	//ask someone in graphics to make a mapmytimehop or mapmyhistory logo
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
	self.view.backgroundColor = RGBACOLOR(227, 227, 227, 1.0);
	
	if(!self.allWorkoutsLoaded)
		[LoadingView showModalLoadingViewWithText:@"loading workouts..."];
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	self.refreshControl.backgroundColor = RGBACOLOR(227, 227, 227, 1.0);

	self.refreshControl.tintColor = [UIColor whiteColor];
	[self.refreshControl addTarget:self
							action:@selector(updateWorkouts)
				  forControlEvents:UIControlEventValueChanged];
	[self.tableView addSubview:self.refreshControl];
	
	if(!self.allWorkoutsLoaded) {
		NSDate *date = [self previousDate:kOneMonth];
		self.oneMonth = [[WorkoutToDisplay alloc] initWithFilterDate:date];
		date = [self previousDate:kOneYear];
		self.oneYear = [[WorkoutToDisplay alloc] initWithFilterDate:date];
		date = [self previousDate:kTwoYear];
		self.twoYear = [[WorkoutToDisplay alloc] initWithFilterDate:date];
		date = [self previousDate:kThreeYear];
		self.threeYear = [[WorkoutToDisplay alloc] initWithFilterDate:date];
	}
	
	[self fetchUser];
	
	self.workouts = [[NSMutableArray alloc] init];
	self.allWorkouts = [[NSMutableArray alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTable) name:@"reloadTable" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedOut) name:@"loggedOut" object:nil];
}

- (void)updateWorkouts {
	self.pullToRefresh = YES;
	self.allWorkoutsLoaded = NO;
	self.numLoaded = 0;
	[self.workouts removeAllObjects];
	[self.oneMonth refresh];
	[self.oneYear refresh];
	[self.twoYear refresh];
	[self.threeYear refresh];
}

- (void)loggedOut {
	NSLog(@"logged out");
	self.oneMonth = nil;
	self.oneYear = nil;
	self.twoYear = nil;
	self.threeYear = nil;
	self.numLoaded = 0;
	self.allWorkoutsLoaded = NO;
	[self.tableView reloadData];
}

- (void)settingsView {

	SettingsViewController *svc = [[SettingsViewController alloc] init];
	svc.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
	[self presentViewController:svc animated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	

	[self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
	[self.view removeFromSuperview];
}

- (void)updateTable {
	++self.numLoaded;
	if(self.numLoaded == maxLoad-1) {
		[self.workouts addObject:self.oneMonth];
		[self.workouts addObject:self.oneYear];
		[self.workouts addObject:self.twoYear];
		[self.workouts addObject:self.threeYear];

		self.allWorkoutsLoaded = YES;
		[LoadingView dismissModalLoadingView];
		if(self.pullToRefresh)
			[self.refreshControl endRefreshing];
	}
	
	[self.tableView reloadData];
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
	NSDate *date = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
	
	return date;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	NSLog(@"memory warning received");
	// Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width/2, 24)];
	label.layer.cornerRadius = 5;
	label.clipsToBounds = YES;
	[label setFont:[Conversions regularFontWithSize:17]];
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
	
	if(self.allWorkoutsLoaded)
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
	
	if(self.allWorkoutsLoaded) {
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
	
	if(self.allWorkoutsLoaded) {
		if([[self.workouts objectAtIndex:indexPath.section] hasPastWorkoutFromTodaysDate]) {
			[cell setWorkout:[[[self.workouts objectAtIndex:indexPath.section] pastWorkoutsFromDate] objectAtIndex:indexPath.row]];
		}
		else
			[cell setNoWorkout];
	}
	return cell;
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

- (void)fetchUser {
	[[[UA sharedInstance] userManager] fetchAuthenticatedUser:^(UAUser *user, NSError *error) {
		if(!error) {
			[[SettingsModel sharedInstance] setUser:user];
			
			///self.name.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
			
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:@"yyyy"];
			NSString *dateString = [formatter stringFromDate:user.dateJoined];
			
			//self.member.text = [NSString stringWithFormat:@"Member since %@", dateString];
			//self.location.text = [NSString stringWithFormat:@"%@, %@", user.locality, user.region];
			
			//[self.avatar setImageWithURL:user.userProfilePhoto.largeImageUrl placeholderImage:[UIImage imageNamed:@"anon"]];
			//self.finishedLoading = YES;
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
//				[self setTotalCalories:@([Conversions convertJoulesToCalories:[lifetimeSummary.energy doubleValue]])];
//				[self setTotalDistance:lifetimeSummary.distance];
//				if(self.user.displayMeasurementSystem == UADisplayMeasurementMetric) {
//					self.milesKey.text = @"TOTAL KILOMETERS: ";
//				}
			}
		}
	}];
}


@end
