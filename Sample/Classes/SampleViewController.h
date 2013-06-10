//
//  SampleViewController.h
//  Sample
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

@class MRMapView;

typedef struct {
    BOOL isTrackingLocation;
} SampleViewControllerState;

@interface SampleViewController : UIViewController {
  @private
	MRMapView *_mapView;

    SampleViewControllerState _state;
}

@property (nonatomic, retain) IBOutlet MRMapView *mapView;

- (IBAction)locateChicago:(id)sender;

-(void)applicationWillResignActive;
-(void)applicationDidBecomeActive;

@end
