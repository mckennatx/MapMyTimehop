//
//  SettingsModel.h
//  MapMyTimeHop
//
//  Created by Lauren Mckenna on 7/27/15.
//  Copyright (c) 2015 Lauren Mckenna. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UASDK;

@interface SettingsModel : NSObject

+ (SettingsModel *)sharedInstance;
@property (nonatomic, retain) UAUser *user;
@property (nonatomic, retain) UAUserStats *lifetimeSummary;

@end
