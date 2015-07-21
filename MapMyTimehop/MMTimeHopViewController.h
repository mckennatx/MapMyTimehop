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
	kWorkoutFooterLoading = 0,
	kWorkoutFooterAllLoaded,
	kWorkoutFooterFailure,
	kWorkoutFooterNoWorkouts
} FooterStyle;

@interface MMTimeHopViewController : UIViewController
@property (nonatomic, copy) NSArray *tableHeaders;
@property (nonatomic, copy) NSArray *tableData;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, strong) UAEntityListRef *nextRef;
@property (nonatomic, copy) void (^listResponseBlock)(UAEntityList *list);
@property (nonatomic, copy) void (^listResponseFailureBlock)(NSError *error);

- (void)refreshLoginState;
@end
