//
//  StartLocationAnnotation.m
//  iMapMy3
//
//  Created by James Humphrey on 11/16/09.
//  Copyright 2009-2010 MapMyFitness, Inc. All rights reserved.
//

#import "SimpleMapAnnotation.h"

@interface SimpleMapAnnotation()
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) MapAnnotationType annotationType;
@end

@implementation SimpleMapAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andAnnotationType:(MapAnnotationType)annotationType {
	self = [super init];
	if (self != nil) {
		self.coordinate = coordinate;
		self.annotationType = annotationType;
	}
	
	return self;
}

@end