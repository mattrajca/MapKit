//
//  SampleViewController.h
//  Sample
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

@class MRMapView;

@interface SampleViewController : UIViewController

@property (nonatomic, weak) IBOutlet MRMapView *mapView;

- (IBAction)locateChicago:(id)sender;

@end
