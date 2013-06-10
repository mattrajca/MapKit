//
//  MRArtifactController.h
//  Sample
//
//  Created by Devon Stewart on 6/10/13.
//
//

#import <Foundation/Foundation.h>

@class MRMapView;

@protocol MRArtifactController <NSObject>

-(void)updateArtifactsInMapView:(MRMapView *)mapView;
-(void)registerGesturesInMapView:(MRMapView *)mapView;
-(void)unregisterGesturesInMapView:(MRMapView *)mapView;
@end
