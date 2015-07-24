//
//  MMTimeHopViewController.h
//  MapMyTimehop
//
//  Created by Lauren Mckenna on 7/20/15.
//
//

#import <UIKit/UIKit.h>
#import "WorkoutToDisplay.h"

@import UASDK;

typedef enum {
	kOneMonth = 0,
	kOneYear,
	kTwoYear,
	kThreeYear
} timeDiff;

@interface MMTimeHopViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, copy) NSArray *tableHeaders;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, assign) NSInteger numLoaded;
@property (nonatomic, copy) UAWorkoutListRef *workoutListRef;

@property (nonatomic, strong) WorkoutToDisplay *oneMonth;
@property (nonatomic, strong) WorkoutToDisplay *oneYear;
@property (nonatomic, strong) WorkoutToDisplay *twoYear;
@property (nonatomic, strong) WorkoutToDisplay *threeYear;

- (void)refreshLoginState;
- (void)showLogin:(BOOL)animated;
@end
