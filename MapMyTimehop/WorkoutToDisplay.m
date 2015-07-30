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

@property (nonatomic, retain) UAWorkoutListRef *workoutListRef;
@property (nonatomic, copy) UAActivityTypeReference *ref;

@property (nonatomic, copy) NSDate *filterDate;

@property (nonatomic, assign) BOOL loadedWorkouts;

@property (nonatomic, copy) NSArray *pastWorkoutsList;


@end

@implementation WorkoutToDisplay

- (instancetype)initWithFilterDate:(NSDate *)filter{
	self = [super init];
	if(self) {
		self.filterDate = filter;
		self.hasPastWorkoutFromTodaysDate = NO;
		self.pastWorkoutsFromDate = [[NSMutableArray alloc] init];
		self.pastWorkoutsList = [[NSMutableArray alloc] init];
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
		[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:nil];
	}];
	return self;
}
/* Method pulls the last 20 workouts done: 1 month ago, 1 year ago, 2 years ago
 * Store the list in an array associated with
 */
- (void)workoutsToDisplayWithBlock:(void (^)())complete {
	NSDate *createdBefore = _filterDate;
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
	[offsetComponents setDay:+1];
	createdBefore = [gregorian dateByAddingComponents:offsetComponents toDate:createdBefore options:0];

	self.workoutListRef = [UAWorkoutListRef workoutListRefWithUserReference:[[UA sharedInstance] authenticatedUserRef] createdBefore:createdBefore];
	UAWorkoutManager *workoutManager = [[UA sharedInstance] workoutManager];

	[workoutManager fetchWorkoutsWithListRef:self.workoutListRef
									withCachePolicy:UACacheElseNetwork
									response:^(UAWorkoutList *object, NSError *error) {
										if (!error) {
											self.pastWorkoutsList = object.objects;
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

	for(UAWorkout *workout in self.pastWorkoutsList) {
		compare = workout.startDatetime;
		compareComponenets = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:compare];
		
		if((day == [compareComponenets day]) && (month == [compareComponenets month]) && (year ==[compareComponenets year])) {
			[self.pastWorkoutsFromDate addObject:workout];
			self.hasPastWorkoutFromTodaysDate = YES;
		}
	}
}

- (CGFloat)totalCalories {
	CGFloat totalCal;
	for(UAWorkout *workout in self.pastWorkoutsFromDate) {
		totalCal += [Conversions convertJoulesToCalories:[workout.aggregate.metabolicEnergyTotal doubleValue]];
	}
	return totalCal;
}

@end
