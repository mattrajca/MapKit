//
//  MRMapView.h
//  MapKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "MRMapTypes.h"

@class MRMapBaseView;
@protocol MRTileProvider, MRProjection, MRPinProvider, MRArtifactController;

/*
  NOTE: MRMapView sets itself as the delegate of its UIScrollView superclass
  Don't change it!
  
  The QuartzCore framework must also be linked against in order to use MRMapView
*/

#define MRMapViewStartTrackingLocation @"MRMapViewStartTrackingLocation"
#define MRMapViewStopTrackingLocation @"MRMapViewStopTrackingLocation"

typedef struct {
    BOOL isSuspended;
    BOOL isTracking;
} MapViewState;

@interface MRMapView : UIScrollView < UIScrollViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate > {
  @private
    MapViewState _state;

	MRMapBaseView *_baseView;
	
	id < MRTileProvider > _tileProvider;
	id < MRProjection > _mapProjection;

    NSMutableArray *artifactControllers;

    CLLocationManager *_locationManager;
}

+(void)mapsShouldStartTracking;
+(void)mapsShouldStopTracking;

/*
  If you don't use the appropriate initWith... method, the following properties will be nil. They MUST be set in order to display any tiles.
 */
@property (nonatomic, retain) id < MRTileProvider > tileProvider;
@property (nonatomic, retain) id < MRProjection > mapProjection;

@property (nonatomic, assign) MRMapCoordinate center; // animated
@property (nonatomic, assign) NSUInteger zoomLevel;   // animated


- (id)initWithFrame:(CGRect)frame tileProvider:(id < MRTileProvider >)tileProvider DEPRECATED_ATTRIBUTE;
// tileProvider and mapProjection must not be nil.
- (id)initWithFrame:(CGRect)frame tileProvider:(id < MRTileProvider >)tileProvider mapProjection:(id < MRProjection >)mapProjection;

- (void)setCenter:(MRMapCoordinate)coord animated:(BOOL)anim;
- (void)setZoomLevel:(NSUInteger)zoom animated:(BOOL)anim;

-(CGPoint)scaledPointForCoordinate:(MRMapCoordinate)coordinate;
-(MRMapCoordinate)coordinateForPoint:(CGPoint)point;

-(void)addArtifactController:(id<MRArtifactController>)artifactController;
-(void)removeArtifactController:(id<MRArtifactController>)artifactController;

-(void)startUpdatingLocation;
-(void)stopUpdatingLocation;

@end
