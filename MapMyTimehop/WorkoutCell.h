//
//  WorkoutCell.h
//  MapMyTimeHop
//
//  Created by Lauren Mckenna on 7/24/15.
//  Copyright (c) 2015 Lauren Mckenna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@import UASDK;
typedef enum {
	kDog = 0,
	kWalk,
	kRun,
	kHike,
	kBike,
	kOther
} icon;

@interface WorkoutCell : UITableViewCell <MKMapViewDelegate>

@property (nonatomic, assign) UAActivityTypeReference *ref;

@property (nonatomic, copy) NSMutableArray *iconImages;

@property (weak, nonatomic) IBOutlet UILabel *workoutName;
//@property (weak, nonatomic) IBOutlet UILabel *distanceVal;
//@property (weak, nonatomic) IBOutlet UILabel *activityType;
//@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
//@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (retain, nonatomic)  UILabel *distanceVal;
@property (retain, nonatomic)  UILabel *activityType;
@property (retain, nonatomic)  UILabel *activityLabel;
@property (retain, nonatomic)  UILabel *distanceLabel;
@property (nonatomic, assign) BOOL resize;


@property (weak, nonatomic) IBOutlet UIImageView *background;

- (void)setWorkout:(UAWorkout *)workout;
- (void)setNoWorkout;
+ (CGFloat)cellHeight;
@end
