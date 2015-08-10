//
//  MapAnnotationView.m
//  iMapMy3
//
//  Created by Corey Roberts on 6/4/13.
//  Copyright (c) 2013 MapMyFitness, Inc. All rights reserved.
//

#import "MapAnnotationView.h"

@interface MapAnnotationView()
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) MapAnnotationType annotationType;
@end

@implementation MapAnnotationView

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andAnnotationType:(MapAnnotationType)annotationType {
	self = [super init];
	if (self != nil) {
		self.coordinate = coordinate;
		self.annotationType = annotationType;
		
		switch (annotationType) {
			case MapAnnotationTypeStartAnnotation:
				self.image = [UIImage imageNamed:@"start_dot.png"];
				break;
			case MapAnnotationTypeStopAnnotation:
				self.image = [UIImage imageNamed:@"end_dot.png"];
				break;
			case MapAnnotationTypeSelectedElevationAnnotation:
				self.image = [UIImage imageNamed:@"elevation_dot.png"];
				break;
		}
		
		self.canShowCallout = NO;
	}
	
	return self;
}
@end
