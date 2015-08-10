//
//  MapAnnotationView.h
//  iMapMy3
//
//  Created by Corey Roberts on 6/4/13.
//  Copyright (c) 2013 MapMyFitness, Inc. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "SimpleMapAnnotation.h"

@interface MapAnnotationView : MKAnnotationView

@property (nonatomic, readonly) MapAnnotationType annotationType;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andAnnotationType:(MapAnnotationType)annotationType;

@end
