//
//  MRBuiltinGPSDotProvider.m
//  Sample
//
//  Created by Devon Stewart on 6/10/13.
//
//

#import <QuartzCore/QuartzCore.h>

#import "MRMapView.h"

#import "MRBuiltinGPSDotProvider.h"

@implementation MRBuiltinGPSDotProvider

-(void)commonInit
{
    gpsDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    gpsDot.layer.cornerRadius = 10;
    gpsDot.backgroundColor = [UIColor blueColor];
}

-(id)init
{
    if((self = [super init]))
    {
        [self commonInit];
    }

    return self;
}

-(void)addArtifactsToMapView:(MRMapView *)mapView
{
    [mapView addSubview:gpsDot];
}

-(void)updateArtifactsInMapView:(MRMapView *)mapView
{
    if(lastLocation)
    {
        MRMapCoordinate coordinate = MRMapCoordinateMake(lastLocation.coordinate.latitude, lastLocation.coordinate.longitude);
        CGPoint point = [mapView scaledPointForCoordinate:coordinate];
        gpsDot.center = point;
    }
}

-(void)removeArtifactsFromMapView:(MRMapView *)mapView
{
    [gpsDot removeFromSuperview];
}

-(void)mapView:(MRMapView *)mapView didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    lastLocation = newLocation;
    [self updateArtifactsInMapView:mapView];
}

@end
