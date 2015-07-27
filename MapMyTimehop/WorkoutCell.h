//
//  WorkoutCell.h
//  MapMyTimeHop
//
//  Created by Lauren Mckenna on 7/24/15.
//  Copyright (c) 2015 Lauren Mckenna. All rights reserved.
//

#import <UIKit/UIKit.h>
@import UASDK;
typedef enum {
	kDog = 0,
	kWalk,
	kRun,
	kHike,
	kBike,
	kOther
} icon;

@interface WorkoutCell : UITableViewCell

@property (nonatomic, assign) UAActivityTypeReference *ref;

@property (nonatomic, copy) NSMutableArray *iconImages;

@property (weak, nonatomic) IBOutlet UILabel *workoutName;
@property (weak, nonatomic) IBOutlet UILabel *distanceVal;
@property (weak, nonatomic) IBOutlet UILabel *activityType;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet UIImageView *background;

- (void)setWorkout:(UAWorkout *)workout;
- (void)setNoWorkout;
+ (CGFloat)cellHeight;

@end
