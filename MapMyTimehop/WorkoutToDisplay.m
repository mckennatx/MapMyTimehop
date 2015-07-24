//
//  WorkoutToDisplay.m
//  MapMyTimehop
//
//  Created by Lauren Mckenna on 7/22/15.
//
//

#import "WorkoutToDisplay.h"


@interface WorkoutToDisplay ()

@property (nonatomic, copy) UAWorkoutListRef *workoutListRef;
@property (nonatomic, copy)	NSArray *pastWorkoutsList;
@property (nonatomic, assign) BOOL loadedWorkouts;

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

/* Method pulls the last 20 workouts done: 1 month ago, 1 year ago, 2 years ago
 * Store the list in an array associated with
 */
- (void)workoutsToDisplayWithBlock:(void (^)())complete {
	NSDate *date = _filterDate;
	_workoutListRef = [UAWorkoutListRef workoutListRefWithUserReference:[[UA sharedInstance] authenticatedUserRef] createdBefore:date];
	UAWorkoutManager *workoutManager = [[UA sharedInstance] workoutManager];

	[workoutManager fetchWorkoutsWithListRef:_workoutListRef
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
	
	NSLog(@"past workouts: %ld", [_pastWorkoutsFromDate count]);
}


@end
