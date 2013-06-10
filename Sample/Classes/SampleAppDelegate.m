//
//	MapViewAppDelegate.m
//	Sample
//
//	Copyright Matt Rajca 2010. All rights reserved.
//

#import "SampleAppDelegate.h"

#import "SampleViewController.h"

#import "MRMapView.h"

@implementation SampleAppDelegate

@synthesize window, viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [window setRootViewController:viewController];
	
	return YES;
}

-(void)applicationWillResignActive:(UIApplication *)application
{
    [MRMapView mapsShouldStopTracking];
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
    [MRMapView mapsShouldStartTracking];
}

@end
