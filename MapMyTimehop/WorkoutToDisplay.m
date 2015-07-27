//
//  WorkoutToDisplay.m
//  MapMyTimehop
//
//  Created by Lauren Mckenna on 7/22/15.
//
//

#import "WorkoutToDisplay.h"
#import "Conversions.h"

@interface WorkoutToDisplay ()

@property (nonatomic, copy) UAWorkoutListRef *workoutListRef;
@property (nonatomic, copy)	NSArray *pastWorkoutsList;
@property (nonatomic, assign) BOOL loadedWorkouts;
@property (nonatomic, copy) UAActivityTypeReference *ref;

@end

@implementation WorkoutToDisplay

- (instancetype)initWithFilterDate:(NSDate *)filter {
	self = [super init];
	if(self) {
		_filterDate = filter;
		_hasPastWorkoutFromTodaysDate = NO;
		_pastWorkoutsFromDate = [[NSMutableArray alloc] init];
		[self workoutsToDisplayWithBlock:^{
			self.loadedWorkouts = YES;
			[self parseWorkouts];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:nil];

		}];
	}
	return self;
}

- (instancetype)refresh {
	[self workoutsToDisplayWithBlock:^{
		self.loadedWorkouts = YES;
		[self.pastWorkoutsFromDate removeAllObjects];
		[self parseWorkouts];
		NSLog(@"%@", self.pastWorkoutsFromDate);
		[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:nil];
	}];
	return self;
}
/* Method pulls the last 20 workouts done: 1 month ago, 1 year ago, 2 years ago
 * Store the list in an array associated with
 */
- (void)workoutsToDisplayWithBlock:(void (^)())complete {
	_workoutListRef = [UAWorkoutListRef workoutListRefWithUserReference:[[UA sharedInstance] authenticatedUserRef] createdBefore:_filterDate];
	UAWorkoutManager *workoutManager = [[UA sharedInstance] workoutManager];

	[workoutManager fetchWorkoutsWithListRef:_workoutListRef
									withCachePolicy:UACacheElseNetwork
									response:^(UAWorkoutList *object, NSError *error) {
										if (!error) {
											_pastWorkoutsList = object.objects;
											complete();
										}
										else {
											UALogError(@"Error retriving available workouts: %@", error);
										}
									}];
}

- (void)parseWorkouts {
	NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:_filterDate];
	NSInteger day = [components day];
	NSInteger month = [components month];
	NSInteger year = [components year];
	
	NSDate *compare;
	NSDateComponents *compareComponenets;
	
	for(UAWorkout *workout in _pastWorkoutsList) {
		compare = workout.startDatetime;
		compareComponenets = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:compare];
		
		if((day == [compareComponenets day]) && (month == [compareComponenets month]) && (year ==[compareComponenets year])) {
			[_pastWorkoutsFromDate addObject:workout];
			_hasPastWorkoutFromTodaysDate = YES;
		}
	}
}

- (CGFloat)totalCalories {
	CGFloat totalCal;
	for(UAWorkout *workout in _pastWorkoutsFromDate) {
		totalCal += [Conversions convertJoulesToCalories:[workout.aggregate.metabolicEnergyTotal doubleValue]];
	}
	return totalCal;
}

@end
