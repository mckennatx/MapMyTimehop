//
//  MMTimeHopViewController.h
//  MapMyTimehop
//
//  Created by Lauren Mckenna on 7/20/15.
//
//

#import <UIKit/UIKit.h>
@import UASDK;

typedef enum {
	kOneMonth = 0,
	kOneYear,
	kTwoYear,
	kThreeYear
} timeDiff;

@interface MMTimeHopViewController : UIViewController
@property (nonatomic, copy) NSArray *tableHeaders;
@property (nonatomic, copy) NSArray *tableData;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *listArray;

@property (nonatomic, copy) UAWorkoutListRef *workoutListRef;


- (void)refreshLoginState;

@end
