//
//  UICustomColors.h
//  MapMyTimeHop
//
//  Created by Lauren Mckenna on 7/27/15.
//  Copyright (c) 2015 Lauren Mckenna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UICustomColors : NSObject

#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 \green:((c>>16)&0xFF)/255.0 \blue:((c>>8)&0xFF)/255.0 \alpha:((c)&0xFF)/255.0];
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

+ (UIColor *)backgroundGray;

@end
