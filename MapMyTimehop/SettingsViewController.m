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

@import UASDK;

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *name;

@property (weak, nonatomic) IBOutlet UILabel *member;
@property (weak, nonatomic) IBOutlet UIButton *logout;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *distanceVal;
@property (weak, nonatomic) IBOutlet UILabel *caloriesVal;
@property (weak, nonatomic) IBOutlet UILabel *milesKey;

@property (nonatomic, retain) UAUser *user;
@property (nonatomic, assign) BOOL finishedLoading;

@property (nonatomic, strong) UINavigationBar* navigationBar;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Settings";
	self.logout.layer.cornerRadius = 10;
	self.logout.clipsToBounds = YES;
	
	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0,[[UIApplication sharedApplication] keyWindow].frame.size.width, 64)];
	self.navigationItem.title = @"Settings";
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"rsz_x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissView)];
	[self.view addSubview:_navigationBar];
	[self.navigationBar pushNavigationItem:self.navigationItem animated:NO];
	
	
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
	[self fetchUser];
}

- (void)fetchUser {
	[[[UA sharedInstance] userManager] fetchAuthenticatedUser:^(UAUser *user, NSError *error) {
		if(!error) {
			self.user = user;
			self.name.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
			
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:@"yyyy"];
			NSString *dateString = [formatter stringFromDate:user.dateJoined];
			
			self.member.text = [NSString stringWithFormat:@"Member since %@", dateString];
			self.location.text = [NSString stringWithFormat:@"%@, %@", user.locality, user.region];
			
			//[self.avatar setImage:[UIImage imageNamed:@"anon.png"]];
			 //[self.avatar setImageWithURL:user.userProfilePhoto.mediumImageUrl];
			NSLog(@"%@", user.userProfilePhoto.mediumImageUrl);
			[self.avatar setImageWithURL:user.userProfilePhoto.mediumImageUrl placeholderImage:[UIImage imageNamed:@"anon"]];
			self.finishedLoading = YES;
			[self fetchAllTimeStats];
		}
	}];
}

- (void)fetchAllTimeStats
{
	UAUserRef *userRef = [UAUserRef userRefWithUserID:self.user.userID];
	UAUserStatsReportRef *userStatsReportRef = [UAUserStatsReportRef userStatsReportRefForUserRef:userRef dateRange:nil aggregationPeriod:UAAggregationPeriodTypeLifetime includeSummaryStats:YES];
	
	UAUserStatsManager *manager = [[UA sharedInstance] userStatsManager];
	[manager fetchUserStatsWithRef:userStatsReportRef response:^(id object, NSError *error) {
		UAUserStatsReport *response = (UAUserStatsReport*)object;
		if (error == nil) {
			if (response.summary.count > 0) {
				UAUserStats *lifetimeSummary = [response.summary firstObject];
				[self setTotalCalories:@([Conversions convertJoulesToCalories:[lifetimeSummary.energy doubleValue]])];
				[self setTotalDistance:lifetimeSummary.distance];
				if(self.user.displayMeasurementSystem == UADisplayMeasurementImperial) {
					self.milesKey.text = @"TOTAL MILES";
				}
			}
		}
	}];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	NSLog(@"memory warning received");
    // Dispose of any resources that can be recreated.
}
- (IBAction)logout:(id)sender {
	[[UA sharedInstance] logout:^(NSError *error) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"loggedOut" object:nil];
		[self showLogin:YES];
	}];
}

- (void)showLogin:(BOOL)animated
{
	if (self.presentedViewController == nil) {
		UALoginViewController *vc = [[UALoginViewController alloc] init];
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
		
		[self presentViewController:navigationController animated:animated completion:nil];
	}
}
- (void)dismissView {
	[self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
