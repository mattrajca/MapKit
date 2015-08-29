//
//	MapViewAppDelegate.m
//	Sample
//
//	Copyright Matt Rajca 2010. All rights reserved.
//

#import "SampleAppDelegate.h"

#import "SampleViewController.h"

@implementation SampleAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	_window.rootViewController = _viewController;
	[_window makeKeyAndVisible];
	
	return YES;
}

@end
