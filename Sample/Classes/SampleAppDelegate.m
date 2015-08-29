//
//	MapViewAppDelegate.m
//	Sample
//
//	Copyright Matt Rajca 2010. All rights reserved.
//

#import "SampleAppDelegate.h"

#import "SampleViewController.h"

@implementation SampleAppDelegate

@synthesize window, viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	window.rootViewController = viewController;
	[window makeKeyAndVisible];
	
	return YES;
}

- (void)dealloc {
	[viewController release];
	[window release];
	
	[super dealloc];
}

@end
