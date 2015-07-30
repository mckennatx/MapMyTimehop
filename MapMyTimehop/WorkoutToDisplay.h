//
//  WorkoutToDisplay.h
//  MapMyTimehop
//
//  Created by Lauren Mckenna on 7/22/15.
//
//

#import <Foundation/Foundation.h>
#import "MMTimeHopViewController.h"

@import UASDK;

@interface WorkoutToDisplay : NSObject

@property (nonatomic, assign) BOOL hasPastWorkoutFromTodaysDate;
@property (nonatomic, retain) NSMutableArray *pastWorkoutsFromDate;

- (instancetype)initWithFilterDate:(NSDate *)filter adjust:(BOOL)adjustDate;
- (instancetype)refresh;
- (CGFloat)totalCalories;

@end
