//
//  WorkoutCell.m
//  MapMyTimeHop
//
//  Created by Lauren Mckenna on 7/24/15.
//  Copyright (c) 2015 Lauren Mckenna. All rights reserved.
//

#import "WorkoutCell.h"
#import "UIImageView+AFNetworking.h"
#import "UICustomColors.h"
#import "Conversions.h"
#import "SettingsModel.h"

static NSString* const kBikePath = @"bike.png";
static NSString*const kRodePath = @"road.png";
static NSString* const kWalkPath = @"walk.png";
static NSString* const kRunPath = @"run.png";
static NSString* const kDogPath = @"dogwalk.png";
static NSString* const kHikePath = @"hike.png";

@interface WorkoutCell ()

@property (nonatomic, retain) UAWorkout *exercise;

@end

@implementation WorkoutCell

- (void)awakeFromNib {
	self.backgroundColor = [UICustomColors backgroundGray];
	
	self.background.layer.cornerRadius = self.background.frame.size.width /2;
	self.background.layer.masksToBounds = YES;
	
	[self.workoutName setFont:[UIFont boldSystemFontOfSize:18]];
	self.workoutName.textColor = [UIColor colorWithRed:0.12 green:0.15 blue:0.20 alpha:1.0];
	
	[self.activityType setFont:[UIFont italicSystemFontOfSize:12]];
	[self.distanceVal setFont:[UIFont italicSystemFontOfSize:12]];
	[self.distanceLabel setFont:[UIFont systemFontOfSize:12]];
	[self.activityLabel setFont:[UIFont systemFontOfSize:12]];

	self.iconImages = [self setIconImageArray];
	
	[self.workoutName setHidden:YES];
	[self.activityType setHidden:YES];
	[self.distanceVal setHidden:YES];
	[self.distanceLabel setHidden:YES];
	[self.activityLabel setHidden:YES];
	[self.background setHidden:YES];
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setWorkout:(UAWorkout *)workout {
	self.exercise = workout;
	self.ref = [workout activityTypeRef];
	
	[self activitiesToDisplayWithBlock: ^ {
		
	}];
	
	self.workoutName.text = [workout workoutName];
	
	[self.workoutName setHidden:NO];
	[self.distanceVal setHidden:NO];
	[self.distanceLabel setHidden:NO];
	[self.activityLabel setHidden:NO];
	
}

- (void)setNoWorkout {
	UIImageView *noWorkoutImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 20, 20)];
	[noWorkoutImg setImage:[UIImage imageNamed:@"noactivity.png"]];
	[self addSubview:noWorkoutImg];

	self.workoutName.text = @"NO WORKOUTS WERE FOUND";
	[self.workoutName setFont:[UIFont systemFontOfSize:14]];
	self.workoutName.textColor = [UIColor grayColor];
	self.workoutName.textColor = [UIColor colorWithRed:0.63 green:0.64 blue:0.60 alpha:1.0];
	[self.workoutName setHidden:NO];
}

- (void)activitiesToDisplayWithBlock:(void (^)())complete{
	[[[UA sharedInstance] activityTypeManager] fetchActivityTypeWithRef:(UAActivityTypeReference *)self.ref
														withCachePolicy:UACacheElseNetwork
															   response:^(UAActivityType *type, NSError *error){
																   if (!error) {
																	   self.activityType.text = [type name];

																	   icon index = [self parseImageURL:[type iconURL]];
																	   
																	   [self.background setImage:[self.iconImages objectAtIndex:index]];
																	   self.background.contentMode = UIViewContentModeScaleAspectFit;

																	   if(index == kOther) {
																		   UAWorkoutAggregate *agg = (UAWorkoutAggregate *)[self.exercise aggregate];
																		   self.distanceLabel.text = @"Total Duration: ";
																		   NSInteger seconds = [[agg activeTimeTotal] integerValue];
																		   self.distanceVal.text = [Conversions secondsToHMS:seconds];
																	   } else {
																		   self.distanceLabel.text = @"Total Distance: ";
																		   UAWorkoutAggregate *agg = (UAWorkoutAggregate *)[self.exercise aggregate];
																		   NSNumber *distance = @([Conversions distanceInUserUnits:[[agg distanceTotal] doubleValue] measurement:[SettingsModel sharedInstance].user.displayMeasurementSystem]);
																		   NSString *distanceLabel = @"miles";
																		   if([SettingsModel sharedInstance].user.displayMeasurementSystem == UADisplayMeasurementMetric) {
																			   distanceLabel = @"kilometers";
																		   }
																		   self.distanceVal.text = [NSString stringWithFormat:@"%@ %@", [Conversions rollupStringForNumber:distance], distanceLabel];
																	   }
																	   [self.background setHidden:NO];
																	   [self.activityType setHidden:NO];
																   }
																   complete();
															   }];
	
}

- (icon)parseImageURL:(NSURL *)url {
	NSString *parseUrl = url.path;
	NSArray *fields = [parseUrl componentsSeparatedByString:@"/"];
	NSString *imageURL = [fields objectAtIndex:[fields count]-1];
	if([imageURL isEqualToString:kBikePath] || [imageURL isEqualToString:kRodePath])
		return kBike;
	else if([imageURL isEqualToString:kRunPath])
		return kRun;
	else if([imageURL isEqualToString:kHikePath])
		return kHike;
	else if([imageURL isEqualToString:kWalkPath])
		return kWalk;
	else if([imageURL isEqualToString:kDogPath])
		return kDog;
	return kOther;
}

- (NSMutableArray *)setIconImageArray {
	UIImage *dog, *walk, *run, *hike, *bike, *other;
	dog = [UIImage imageNamed:@"dog.png"];
	walk = [UIImage imageNamed:@"walk.png"];
	run = [UIImage imageNamed:@"run.png"];
	hike = [UIImage imageNamed:@"hike.png"];
	bike = [UIImage imageNamed:@"bike.png"];
	other = [UIImage imageNamed:@"fitness.png"];
	return [@[
			  dog,
			  walk,
			  run,
			  hike,
			  bike,
			  other
			  ] mutableCopy];
}

+ (CGFloat)cellHeight {
	return 70;
}

@end
