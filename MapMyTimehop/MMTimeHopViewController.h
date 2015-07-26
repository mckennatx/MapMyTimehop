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

- (void)refreshLoginState;

@end
