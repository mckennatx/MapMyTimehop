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

+ (UIFont *)regularFontWithSize:(CGFloat)size {
	UIFont *regular = [UIFont fontWithName:kDefaultFontRegular size:size];
	if(!regular)
		regular = [UIFont systemFontOfSize:size];
	return regular;
}

+ (UIFont *)semiboldFontWithSize:(CGFloat)size {
	UIFont *semiBold = [UIFont fontWithName:kDefaultFontSemibold size:size];
	if(!semiBold)
		semiBold = [UIFont systemFontOfSize:size];
	return semiBold;
}

+ (UIFont *)boldFontWithSize:(CGFloat)size {
	UIFont *bold = [UIFont fontWithName:kDefaultFontBold size:size];
	if(!bold)
		bold = [UIFont systemFontOfSize:size];
	return bold;
}

+ (UIFont *)lightFontWithSize:(CGFloat)size
{
	UIFont *light = [UIFont fontWithName:kDefaultFontLight size:size];
	if(!light)
		light = [UIFont systemFontOfSize:size];
	return light;
}

+(NSString *)secondsToHMS:(NSInteger)totalSeconds {
	NSInteger hours = (totalSeconds / 3600);
	NSInteger mins = (totalSeconds / 60) % 60;
	NSInteger sec = totalSeconds % 60;
	NSString *result = [NSString stringWithFormat:@"%ldhr:%ldmin:%ldsec", hours, mins, sec];
	
	return result;
}

@end
