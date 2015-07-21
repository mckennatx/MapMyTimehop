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
#import "AFNetworking/UIKit+AFNetworking/UIImageView+AFNetworking.h"

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

static BOOL reloading = NO;
static const NSUInteger kWorkoutFetchAmount = 20;

@implementation MMTimeHopViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.tableHeaders = [self buildTableHeaders];
	self.tableData = [self buildTableData];
	UAEntityListRef *ref = [self createNewListRef];

	NSLog(@"%@", ref);
	
//	NSURL *url = [NSURL URLWithString:[self avatarUrlForUserID:[UA sharedInstance].authenticatedUserRef.entityID]];
	//[self.profileIcon setImageWithURL:url];

	// Add a login block that will be called whenever
	// the API failes and requires authentication.
	[[UA sharedInstance] setUserAuthBlock:^(void) {
		[self showLogin:YES];
	}];
}



- (NSString *)avatarUrlForUserID:(NSString *)userID
{
	// append date to url to avoid cloudfront 302 redirect cache so that new avatar will be loaded when avatar is updated via edit profile
	//NSDate *date = [SettingsModel sharedInstance].avatarUpdatedDate;
	return [NSString stringWithFormat:@"https://drzetlglcbfx.cloudfront.net/profile/%@/picture?size=Medium", userID];
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
	// Dispose of any resources that can be recreated.
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

- (void)logout:(id)sender
{
	[[UA sharedInstance] logout:^(NSError *error) {
		[self showLogin:YES];
	}];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return [TableHeaderView defaultHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	TableHeaderView *view = [TableHeaderView headerWithTitle:self.tableHeaders[section]];
	return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.tableHeaders count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(!cell) {
		cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.rowHeight)];
	}
	
	NSDictionary *data = self.tableData[indexPath.section][indexPath.row];
	
	cell.textLabel.text = @"test";
	
	return cell;
}

- (UAEntityListRef *)createNewListRef {
	return [UAWorkoutListRef workoutListRefWithUserReference:[[UA sharedInstance] authenticatedUserRef]
											   createdBefore:[NSDate dateWithTimeIntervalSinceNow:60*60*24]];
	
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

- (NSMutableArray *)buildTableData
{
	return [@[
			  @"test1",
			  @"test2",
			  @"test3",
			  @"test4",
			  ] mutableCopy];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

//- (IBAction)logout:(id)sender {
//}
@end
