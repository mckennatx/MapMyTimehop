//
//  LifetimeStatsCell.h
//  MapMyTimeHop
//
//  Created by Lauren Mckenna on 7/31/15.
//  Copyright (c) 2015 Lauren Mckenna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LifetimeStatsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *value;
+(CGFloat)rowHeight;
@end
