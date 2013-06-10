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

-(void)registerGesturesInMapView:(MRMapView *)mapView;
-(void)unregisterGesturesInMapView:(MRMapView *)mapView;

-(void)addArtifactsToMapView:(MRMapView *)mapView;
-(void)removeArtifactsFromMapView:(MRMapView *)mapView;

-(void)updateArtifactsInMapView:(MRMapView *)mapView;

@end
