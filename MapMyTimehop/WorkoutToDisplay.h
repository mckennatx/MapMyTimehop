//
//  WorkoutToDisplay.h
//  MapMyTimehop
//
//  Created by Lauren Mckenna on 7/22/15.
//
//

#import <Foundation/Foundation.h>
@import UASDK;

@interface WorkoutToDisplay : NSObject

@property (nonatomic, assign) BOOL hasPastWorkoutFromTodaysDate;
@property (nonatomic, copy) NSDate *filterDate;
@property (nonatomic, copy) NSMutableArray *pastWorkoutsFromDate;
- (instancetype)initWithFilterDate:(NSDate *)filter;
- (instancetype)refresh;
- (CGFloat)totalCalories;
@end
