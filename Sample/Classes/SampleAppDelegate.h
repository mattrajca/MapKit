//
//  MapViewAppDelegate.h
//  Sample
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

@class SampleViewController;

@interface SampleAppDelegate : NSObject < UIApplicationDelegate > {
  @private
    UIWindow *window;
    SampleViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SampleViewController *viewController;

@end
