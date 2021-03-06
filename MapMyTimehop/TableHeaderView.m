//
//  TableHeaderView.m
//  MapMyTimehop
//
//  Created by Lauren Mckenna on 7/21/15.
//
//


#import "TableHeaderView.h"
//#import "Categories.h"
#define kDefaultFontSemibold @"OpenSans-Semibold"
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

static const NSInteger kDefaultHeight = 42;
static const CGFloat kContentHorizontalPadding = 9;
static const CGFloat kContentVerticalPadding = 7;

@interface TableHeaderView()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation TableHeaderView

- (id)init {
	self = [super init];
	if(self) {
		self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kDefaultHeight);
		
		self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kContentHorizontalPadding, kContentVerticalPadding, self.frame.size.width - (kContentHorizontalPadding * 2), self.frame.size.height)];
		UIFont *font = [UIFont fontWithName:kDefaultFontSemibold size:15];
		self.titleLabel.font = font;
		self.titleLabel.backgroundColor = [UIColor clearColor];
		self.backgroundColor = [UIColor clearColor];
		
		[self addSubview:self.titleLabel];
	}
	
	return self;
}

+ (TableHeaderView *)headerWithTitle:(NSString *)title {
	TableHeaderView *header = [[TableHeaderView alloc] init];
	//header.titleLabel.attributedText = [NSAttributedString stringWithDefaultKerning:[title uppercaseString]];
	
	return header;
}

+ (NSInteger)defaultHeight {
	return kDefaultHeight;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
