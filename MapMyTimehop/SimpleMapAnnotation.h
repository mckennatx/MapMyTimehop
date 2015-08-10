//
//  SimpleMapAnnotation.h
//  iMapMy3
//
//  Created by James Humphrey on 11/16/09.
//  Copyright 2009-2010 MapMyFitness, Inc. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CLLocation.h>
#import <Foundation/Foundation.h>

typedef enum {
	MapAnnotationTypeStartAnnotation = 0,
	MapAnnotationTypeStopAnnotation,
	MapAnnotationTypeSelectedElevationAnnotation
} MapAnnotationType;

@interface SimpleMapAnnotation : NSObject<MKAnnotation>

@property (nonatomic, readonly) MapAnnotationType annotationType;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andAnnotationType:(MapAnnotationType)annotationType;

@end
