/*
 * LoadingView.h
 *
 * Adapted from the UASDK Tutorial App
 * Copyright (c) 2015 Under Armour. All rights reserved.
 *
 */


#import <UIKit/UIKit.h>

@interface LoadingView : UIView

+ (void)showModalLoadingViewWithText:(NSString *)text;

+ (void)dismissModalLoadingView;

@end
