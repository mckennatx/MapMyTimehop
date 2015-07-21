//
//  AppDelegate.h
//  MapMyTimehop
//
//  Created by Lauren Mckenna on 7/20/15.
//
//

#import <UIKit/UIKit.h>


@class MMTimeHopViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) MMTimeHopViewController *timeHopViewController;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) UIWindow *window;

@end

