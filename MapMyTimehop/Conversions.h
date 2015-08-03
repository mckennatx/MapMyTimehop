//
//  Conversions.h
//  MapMyTimehop
//
//  Created by Lauren Mckenna on 7/23/15.
//
//

#import <Foundation/Foundation.h>
@import UASDK;

@interface Conversions : NSObject

+ (double)distanceInUserUnits:(double)distanceInMeters measurement:(UADisplayMeasurementSystem)measurement;
+ (NSString *)rollupStringForNumber:(NSNumber*)number;
+ (double)convertJoulesToCalories:(double)joules;
+(NSString *)secondsToHMS:(NSInteger)totalSeconds;
+ (NSString *)paceInUserUnitsString:(double)paceInSecsPerMeter;
+ (double)paceInMinutesPerUserUnits:(double)paceInSecsPerMeter;

@end
