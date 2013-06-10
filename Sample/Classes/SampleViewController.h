//
//  SampleViewController.h
//  Sample
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

@class MRMapView;

@interface SampleViewController : UIViewController {
  @private
	MRMapView *_mapView;
}

@property (nonatomic, retain) IBOutlet MRMapView *mapView;

- (IBAction)locateChicago:(id)sender;

@end
