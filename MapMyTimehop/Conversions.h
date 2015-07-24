//
//  Conversions.h
//  MapMyTimehop
//
//  Created by Lauren Mckenna on 7/23/15.
//
//

#import <Foundation/Foundation.h>
@import UASDK;

#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 \
green:((c>>16)&0xFF)/255.0 \
blue:((c>>8)&0xFF)/255.0 \
alpha:((c)&0xFF)/255.0];

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface Conversions : NSObject
+ (double)distanceInUserUnits:(double)distanceInMeters measurement:(UADisplayMeasurementSystem)measurement;
+ (NSString *)rollupStringForNumber:(NSNumber*)number;
+ (double)convertJoulesToCalories:(double)joules;
@end
