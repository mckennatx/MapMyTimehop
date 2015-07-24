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

static const NSInteger maxLoad = 4;

@interface MMTimeHopViewController ()
- (IBAction)logout:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *profileIcon;
@property (nonatomic, strong) UAWorkoutListRef *nextReference;
@property (nonatomic, assign) BOOL pullToRefresh;
@property (nonatomic, assign) BOOL allWorkoutsLoaded;
@property (nonatomic, assign) BOOL reloadingFailed;
@property (nonatomic, assign) BOOL saving;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

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
	
	self.tableHeaders = [self buildTableHeaders];
	self.tableView.sectionHeaderHeight = [TableHeaderView defaultHeight];
	self.tableView.rowHeight = 70;
	self.tableView.separatorColor = [UIColor clearColor];
	self.tableView.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = RGBACOLOR(227, 227, 227, 1.0);

	
	if(!self.allWorkoutsLoaded)
		[LoadingView showModalLoadingViewWithText:@"loading workouts..."];
	
	NSDate *date = [self previousDate:kOneMonth];
	
	self.oneMonth = [[WorkoutToDisplay alloc] initWithFilterDate:date];
	date = [self previousDate:kOneYear];
	self.oneYear = [[WorkoutToDisplay alloc] initWithFilterDate:date];
	date = [self previousDate:kTwoYear];
	self.twoYear = [[WorkoutToDisplay alloc] initWithFilterDate:date];
	date = [self previousDate:kThreeYear];
	self.threeYear = [[WorkoutToDisplay alloc] initWithFilterDate:date];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTable) name:@"reloadTable" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedOut) name:@"loggedOut" object:nil];

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
	//refresh table
	[self.tableView reloadData];
}

- (void)updateTable {
	++self.numLoaded;
	if(self.numLoaded == maxLoad) {
		NSLog(@"good good");
		self.allWorkoutsLoaded = YES;
		[LoadingView dismissModalLoadingView];
	}
	
	[self.tableView reloadData];
}

//This method should be called when setting up future notifications
//add completion block
- (void)pullWorkoutsWithBlock:(void (^)())complete
{
	NSDate *date = [self previousDate:kOneMonth];
	_listArray = [NSMutableArray array];
	_workoutListRef = [UAWorkoutListRef workoutListRefWithUserReference:[[UA sharedInstance] authenticatedUserRef] createdBefore:date];
	
	UAWorkoutManager *workoutManager = [[UA sharedInstance] workoutManager];

	__block void (^requestBlock)(void);
	
	void(^responseBlock)(UAWorkoutList *list) = ^(UAWorkoutList *list){
		BOOL nextPageAvailable = list.nextRef != nil;
		
		[_listArray addObject:list];
		
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
										response:^(id object, NSError *error) {
			if (!error) {
				responseBlock((UAWorkoutList *)object);
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
	
	// Present the login view if there is no currently authed
	// user
	if ([[UA sharedInstance] isAuthenticated] == NO)
		[self showLogin:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	NSLog(@"memory warning received");
	// Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [self.tableHeaders objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.tableHeaders count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger count=1;
	switch (section)
	{
		case 0:
			if(self.oneMonth.hasPastWorkoutFromTodaysDate)
				count = [self.oneMonth.pastWorkoutsFromDate count];
			break;
		case 1:
			if(self.oneYear.hasPastWorkoutFromTodaysDate)
				count = [self.oneYear.pastWorkoutsFromDate count];
			break;
		case 2:
			if(self.twoYear.hasPastWorkoutFromTodaysDate)
				count = [self.twoYear.pastWorkoutsFromDate count];
			break;
		case 3:
			if(self.threeYear.hasPastWorkoutFromTodaysDate)
				count = [self.threeYear.pastWorkoutsFromDate count];
			break;
		default:
			break;
	}
	
	return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(!cell) {
		cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.rowHeight)];
	}
	
	if(self.allWorkoutsLoaded) {
		switch(indexPath.section) {
			case 0:
				if(self.oneMonth.hasPastWorkoutFromTodaysDate) {
					cell.textLabel.text = [self.oneMonth.pastWorkoutsFromDate[indexPath.row] workoutName];
					UAWorkoutAggregate *agg = (UAWorkoutAggregate *)[self.oneMonth.pastWorkoutsFromDate[indexPath.row] aggregate];
					NSLog(@"distance: %@", [agg distanceTotal]);
				}
				break;
			case 1:
				if(self.oneYear.hasPastWorkoutFromTodaysDate)
					cell.textLabel.text = [self.oneYear.pastWorkoutsFromDate[indexPath.row] workoutName];
				break;
			case 2:
				if(self.twoYear.hasPastWorkoutFromTodaysDate)
					cell.textLabel.text = [self.twoYear.pastWorkoutsFromDate[indexPath.row] workoutName];
				break;
			case 3:
				if(self.threeYear.hasPastWorkoutFromTodaysDate)
					cell.textLabel.text = [self.threeYear.pastWorkoutsFromDate[indexPath.row] workoutName];
				break;
			default:
				break;
		}
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
@end
