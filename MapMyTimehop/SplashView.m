//
//  SplashView.m
//  MapMyTimeHop
//
//  Created by Lauren Mckenna on 7/29/15.
//  Copyright (c) 2015 Lauren Mckenna. All rights reserved.
//

#import "SplashView.h"
#import "UALoginViewController.h"
#import "MMTimeHopViewController.h"
@import UASDK;

@interface SplashView ()
@property (weak, nonatomic) IBOutlet UIImageView *mmth;
@property (nonatomic, retain) UIImageView *pogo;
@property (nonatomic, retain) UIImageView *header;

@property (nonatomic, assign) BOOL displayHeader;

@property (nonatomic, retain) NSMutableArray *dotArray;

@property(nonatomic, assign) CGPoint position;
@end

@implementation SplashView

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSArray *imageNames = @[@"pogo_01.png", @"pogo_02.png", @"pogo_03.png", @"pogo_04.png",
							@"pogo_03.png", @"pogo_02.png", @"pogo_01.png"];
	
	
	NSMutableArray *images = [[NSMutableArray alloc] init];
	for (int i = 0; i < imageNames.count; i++) {
		[images addObject:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
	}
	
	self.pogo = [[UIImageView alloc] initWithFrame:CGRectMake(5, 200, 200, 200)];
	self.position = CGPointMake(5, 200);
	//[self.pogo setImage:[UIImage imageNamed:@"pogo_01.png"]];
	self.pogo.animationImages = images;
	self.pogo.animationDuration = 4.5f;
	self.pogo.contentMode = UIViewContentModeScaleAspectFit;
	
	self.header = [[UIImageView alloc] initWithFrame:CGRectMake(self.position.x+80, 400, 320, 200)];
	[self.header setImage:([UIImage imageNamed:@"header"])];
	self.header.contentMode = UIViewContentModeScaleAspectFit;
	self.displayHeader = YES;
	
	[self.view addSubview:self.pogo];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.view addSubview:self.pogo];
		[self.pogo startAnimating];
		[self animatePogoStick:^() {
		}];
	});
	
}

- (void)animatePogoStick:(void (^)())complete
{
	__block void (^requestBlock)(void);
	
	void(^responseBlock)() = ^(){
		BOOL nextPoint = !(self.position.x > 350);
		
		if(nextPoint) {
			dispatch_async(dispatch_get_main_queue(), ^{
				requestBlock();
			});
		}
		else {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"dismiss" object:nil];
			complete();
		}
	};
	
	requestBlock = ^{
		dispatch_async(dispatch_get_main_queue(), ^{
			[UIView animateWithDuration:.35
								  delay:0.00
								options:UIViewAnimationOptionCurveEaseIn
							 animations:^{
								 [self.pogo setFrame:CGRectMake(self.position.x, self.position.y, self.pogo.frame.size.width, self.pogo.frame.size.height)];
							 }
							 completion:^(BOOL finished){
								 complete();
								 if(((int)self.position.y % 300) == 0) {
									 self.position = CGPointMake(self.position.x+45, 250);
									 if(self.displayHeader) {
										 [self.view addSubview:self.header];
										 self.displayHeader = NO;
									 }
									 
									 //every time it hits "bottom", leave a print
									 UIImageView *pogoPrint = [[UIImageView alloc] initWithFrame:CGRectMake(self.position.x+48, 440, 10, 10)];
									 [pogoPrint setImage:[UIImage imageNamed:@"dot"]];
									 pogoPrint.contentMode = UIViewContentModeScaleAspectFit;
									 [self performSelector:@selector(pogoPrint:) withObject:pogoPrint afterDelay:.1];
								 }
								 else {
									 self.position = CGPointMake(self.position.x+10, 300);
								 }
								 responseBlock();
							 }];
		});
		
	};
	
	requestBlock();
}

- (void)pogoPrint:(UIImageView *)pogoPrint {
	[self.view addSubview:pogoPrint];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
