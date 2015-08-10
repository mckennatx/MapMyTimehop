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
#import "SimpleMapAnnotation.h"
#import "MapAnnotationView.h"

static NSString* const kBikePath = @"bike.png";
static NSString* const kRodePath = @"road.png";
static NSString* const kWalkPath = @"walk.png";
static NSString* const kRunPath = @"run.png";
static NSString* const kDogPath = @"dogwalk.png";
static NSString* const kHikePath = @"hike.png";

@interface WorkoutCell ()

@property (nonatomic, retain) UAWorkout *exercise;
@property (nonatomic, retain) MKMapView *routeView;


@end

@implementation WorkoutCell

- (void)awakeFromNib {
	//self.backgroundColor = [UICustomColors backgroundGray];
	self.backgroundColor = [UIColor clearColor];
	
	self.background.layer.cornerRadius = self.background.frame.size.width /2;
	self.background.layer.masksToBounds = YES;
	
	[self.workoutName setFont:[UIFont boldSystemFontOfSize:18]];
	self.workoutName.textColor = [UIColor colorWithRed:0.12 green:0.15 blue:0.20 alpha:1.0];
	
	self.distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 30, 98, 15)];
	self.activityLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 45, 98, 15)];
	self.distanceVal = [[UILabel alloc] initWithFrame:CGRectMake(180, 30, 100, 15)];
	self.activityType = [[UILabel alloc] initWithFrame:CGRectMake(180, 45, 100, 15)];
	
	[self.activityType setFont:[UIFont italicSystemFontOfSize:12]];
	[self.distanceVal setFont:[UIFont italicSystemFontOfSize:12]];
	[self.distanceLabel setFont:[UIFont systemFontOfSize:12]];
	[self.activityLabel setFont:[UIFont systemFontOfSize:12]];

	self.iconImages = [self setIconImageArray];
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
	self.activityLabel.text = @"Activity Type: ";
	
	[self fetchRoute:^{
	}];
	
	[self addSubview:self.distanceLabel];
	[self addSubview:self.activityLabel];
	[self addSubview:self.distanceVal];
	[self addSubview:self.activityType];
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

#pragma mark - Route and Activity Fetcher
- (void)fetchRoute:(void (^)())complete {
	UARouteManager *manager = [UA sharedInstance].routeManager;
	[manager fetchRouteWithRef:self.exercise.routeRef withDetails:YES response:^(UARoute *object, NSError *error) {
		if (!error)
		{
			UARoute *route = object;
			if (route)
			{
				NSArray *points = route.points;
				self.resize = YES;
				
				[[NSNotificationCenter defaultCenter] postNotificationName:@"resize" object:nil];
				
				//add a mapview
				_routeView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 70, self.frame.size.width, 120)];
				_routeView.delegate = self;
				_routeView.scrollEnabled = NO;
				
				[self drawPointsOnMap:points];
				[self addSubview:_routeView];
				
			}
			complete();
		}
	}];
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
																	   [self.activityType setHidden:NO];
																	   [self.background setHidden:NO];
																   }
																   complete();
															   }];
	
}

#pragma mark - MapView
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
	if ([overlay isKindOfClass:[MKPolyline class]]) {
		MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
		polylineRenderer.fillColor = [UIColor redColor];
		polylineRenderer.alpha = 0.75f;
		polylineRenderer.strokeColor = [UIColor redColor];
		polylineRenderer.lineWidth = 4;
		
		return polylineRenderer;
	}
	else return nil;
}

-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[SimpleMapAnnotation class]]) {
		MapAnnotationView *annotationView;
		
		switch (((SimpleMapAnnotation *)annotation).annotationType) {
			case MapAnnotationTypeStartAnnotation: {
				annotationView = (MapAnnotationView *)[self.routeView dequeueReusableAnnotationViewWithIdentifier:@"Start"];
				if(!annotationView) {
					annotationView = [[MapAnnotationView alloc] initWithCoordinate:((SimpleMapAnnotation *)annotation).coordinate andAnnotationType:MapAnnotationTypeStartAnnotation];
					return annotationView;
				}
				break;
			}
			case MapAnnotationTypeStopAnnotation: {
				annotationView = (MapAnnotationView *)[self.routeView dequeueReusableAnnotationViewWithIdentifier:@"Stop"];
				if(!annotationView) {
					annotationView = [[MapAnnotationView alloc] initWithCoordinate:((SimpleMapAnnotation *)annotation).coordinate andAnnotationType:MapAnnotationTypeStopAnnotation];
					return annotationView;
				}
				break;
			}
			default: {
				return nil;
			}
		}
	}
	
	return nil;
}



#pragma mark - These following 4 methods were adapted from UA MMF
- (void)drawPointsOnMap:(NSArray *)points {
	[self setMapRegionWithPoints:points animated:NO];
	[self overlayRouteWithPoints:points];
	[self addAnnotationsWithPoints:points];
}

- (void)setMapRegionWithPoints:(NSArray *)points animated:(BOOL)animated {
	if(points && [points count] > 0){
		// determine the extents of the trip points that were passed in, and zoom in to that area.
		CLLocationDegrees maxLat = 0;
		CLLocationDegrees maxLon = 0;
		CLLocationDegrees minLat = 0;
		CLLocationDegrees minLon = 0;
		
		for(int idx = 0; idx < points.count; idx++) {
			CLLocation* currentLocation = points[idx];
			
			// If we're on the first point, set all bounded values to it.
			if(idx == 0){
				minLat = currentLocation.coordinate.latitude;
				maxLat = currentLocation.coordinate.latitude;
				minLon = currentLocation.coordinate.longitude;
				maxLon = currentLocation.coordinate.longitude;
			}
			
			if(currentLocation.coordinate.latitude > maxLat)
				maxLat = currentLocation.coordinate.latitude;
			if(currentLocation.coordinate.latitude < minLat)
				minLat = currentLocation.coordinate.latitude;
			if(currentLocation.coordinate.longitude > maxLon)
				maxLon = currentLocation.coordinate.longitude;
			if(currentLocation.coordinate.longitude < minLon)
				minLon = currentLocation.coordinate.longitude;
		}
		
		MKCoordinateRegion region;
		region.center.latitude = (maxLat + minLat) / 2;
		region.center.longitude = (maxLon + minLon) / 2;
		region.span.latitudeDelta = maxLat - minLat + .001;
		region.span.longitudeDelta = maxLon - minLon + .001;
		
		[self.routeView setRegion:region animated:animated];
	}
}

- (void)addAnnotationsWithPoints:(NSArray *)points {
	if(points && points.count) {
		CLLocation *firstPoint = [points firstObject];
		CLLocation *lastPoint = [points lastObject];
		SimpleMapAnnotation *startAnnotation = [[SimpleMapAnnotation alloc] initWithCoordinate:firstPoint.coordinate andAnnotationType:MapAnnotationTypeStartAnnotation];
		[self.routeView addAnnotation:startAnnotation];
		
		//Create and add the end annotation
		SimpleMapAnnotation *endAnnotation = [[SimpleMapAnnotation alloc] initWithCoordinate:lastPoint.coordinate andAnnotationType:MapAnnotationTypeStopAnnotation];
		[self.routeView addAnnotation:endAnnotation];
	}
}

- (void)overlayRouteWithPoints:(NSArray *)points {
	NSUInteger locationCount = [points count];
	CLLocationCoordinate2D *locationCoordinate2DArray = malloc(sizeof(CLLocationCoordinate2D) * locationCount);
	for (int i = 0; i < locationCount; i++) {
		locationCoordinate2DArray[i] = [(CLLocation *)points[i] coordinate];
	}
	
	if(self.routeView.overlays.count > 0) {
		[self.routeView removeOverlays:self.routeView.overlays];
	}
	
	MKPolyline *routeLine = [MKPolyline polylineWithCoordinates:locationCoordinate2DArray count:locationCount];
	
	free(locationCoordinate2DArray);
	
	[self.routeView addOverlay:routeLine];
}

#pragma mark - images
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
