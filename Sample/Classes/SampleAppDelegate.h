//
//  MapViewAppDelegate.h
//  Sample
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

@class SampleViewController;

@interface SampleAppDelegate : NSObject < UIApplicationDelegate >

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet SampleViewController *viewController;

@end
