//
//  SampleViewController.m
//  Sample
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "SampleViewController.h"

#import "MRMapView.h"

#import "MRMQOTileProvider.h"
#import "MRMercatorProjection.h"
#import "MRBuiltinPinProvider.h"
#import "MRBuiltinGPSDotProvider.h"

@interface SampleViewController ()

- (void)loadState;
- (void)saveState:(id)sender;

@end


@implementation SampleViewController

@synthesize mapView = _mapView;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	_mapView.tileProvider = [MRMQOTileProvider new];
	_mapView.mapProjection = [MRMercatorProjection new];

    { // Set up Pin provider
        MRBuiltinPinProvider *pinProvider = [MRBuiltinPinProvider new];
        [_mapView addArtifactController:pinProvider];

        __weak MRMapView *weakMapView = _mapView;
        __weak MRBuiltinPinProvider *weakPinProvider = pinProvider;
        pinProvider.updatePinMethod = ^(id<NSCopying> identifier, CGPoint newPoint) {
            MRMapCoordinate coord = [weakMapView coordinateForPoint:newPoint];
            [weakPinProvider updatePin:identifier withCoordinates:coord];
        };
    }

    {
        MRBuiltinGPSDotProvider *gpsDotProvider = [MRBuiltinGPSDotProvider new];
        [_mapView addArtifactController:gpsDotProvider];
        [_mapView startUpdatingLocation];
    }

	[self loadState];
}


- (void)loadState {
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[defs registerDefaults:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1]
													   forKey:@"zoom"]];
	
	NSUInteger zoom = [defs integerForKey:@"zoom"];
	[_mapView setZoomLevel:zoom animated:NO];
	
	MRMapCoordinate center;
	center.latitude = [defs doubleForKey:@"centerLat"];
	center.longitude = [defs doubleForKey:@"centerLng"];
	
	[_mapView setCenter:center animated:NO];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(saveState:)
												 name:UIApplicationWillResignActiveNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(saveState:)
												 name:UIApplicationWillTerminateNotification
											   object:nil];
}

- (void)saveState:(id)sender {
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[defs setInteger:_mapView.zoomLevel forKey:@"zoom"];
	
	MRMapCoordinate center = _mapView.center;
	[defs setDouble:center.latitude forKey:@"centerLat"];
	[defs setDouble:center.longitude forKey:@"centerLng"];
	
	[defs synchronize];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (IBAction)locateChicago:(id)sender {
	_mapView.zoomLevel = 10;
	_mapView.center = MRMapCoordinateMake(41.85f, -87.65f);
}

@end
