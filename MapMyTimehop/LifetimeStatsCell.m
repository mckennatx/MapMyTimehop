//
//  LifetimeStatsCell.m
//  MapMyTimeHop
//
//  Created by Lauren Mckenna on 7/31/15.
//  Copyright (c) 2015 Lauren Mckenna. All rights reserved.
//

#import "LifetimeStatsCell.h"
#import "UICustomColors.h"

@implementation LifetimeStatsCell

- (void)awakeFromNib {
	self.backgroundColor = [UICustomColors backgroundGray];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(CGFloat)rowHeight {
	return 75;
}
@end
