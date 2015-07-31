//
//  Conversions.m
//  MapMyTimehop
//
//  Created by Lauren Mckenna on 7/23/15.
//
//

#import "Conversions.h"

@implementation Conversions

+ (double)distanceInUserUnits:(double)distanceInMeters measurement:(UADisplayMeasurementSystem)measurement {
	double distanceInUserUnits = distanceInMeters;
	
	if(measurement == UADisplayMeasurementImperial){
		distanceInUserUnits *= MILES_PER_METER;
	} else {
		distanceInUserUnits /= 1000;
	}
	
	return distanceInUserUnits;
}

+ (NSString *)rollupStringForNumber:(NSNumber*)number
{
	NSString *response = nil;
	NSString *format = nil;
	float floatVal = [number floatValue];
	if (floatVal >= 10000000)
	{
		floatVal /= 1000000;
		floatVal = roundf(floatVal);
		format = @"%0.1fM";
	}
	else if (floatVal >= 10000)
	{
		floatVal /= 1000.f;
		format = @"%0.1fK";
	}
	else
	{
		float whole = floorf(floatVal);
		format = floatVal - whole >= 0.1 ? @"%0.1f" : @"%0.0f";
	}
	
	response = [NSString stringWithFormat:format, floatVal];
	
	return response;
}

+ (double)convertJoulesToCalories:(double)joules
{
	return joules * 0.000239005736;
}

+(NSString *)secondsToHMS:(NSInteger)totalSeconds {
	NSInteger hours = (totalSeconds / 3600);
	NSInteger mins = (totalSeconds / 60) % 60;
	NSString *result = [NSString stringWithFormat:@"%ld hr %ld min", hours, mins];
	
	return result;
}

@end
