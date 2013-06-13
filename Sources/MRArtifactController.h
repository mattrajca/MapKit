//
//  MRArtifactController.h
//  Sample
//
//  Created by Devon Stewart on 6/10/13.
//
//

#import <Foundation/Foundation.h>

@class CLLocation;

@class MRMapView;

@protocol MRArtifactController <NSObject>

-(void)addArtifactsToMapView:(MRMapView *)mapView;
-(void)removeArtifactsFromMapView:(MRMapView *)mapView;

-(void)updateArtifactsInMapView:(MRMapView *)mapView;

@optional

-(void)registerGesturesInMapView:(MRMapView *)mapView;
-(void)unregisterGesturesInMapView:(MRMapView *)mapView;

-(void)mapView:(MRMapView *)mapView didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;

@end
