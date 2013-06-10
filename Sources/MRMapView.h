//
//  MRMapView.h
//  MapKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "MRMapTypes.h"

@class MRMapBaseView;
@protocol MRTileProvider, MRProjection, MRPinProvider;

/*
  NOTE: MRMapView sets itself as the delegate of its UIScrollView superclass
  Don't change it!
  
  The QuartzCore framework must also be linked against in order to use MRMapView
*/

@interface MRMapView : UIScrollView < UIScrollViewDelegate, UIGestureRecognizerDelegate > {
  @private
	MRMapBaseView *_baseView;
	
	id < MRTileProvider > _tileProvider;
	id < MRProjection > _mapProjection;
    id < MRPinProvider > _pinProvider;

    id < NSCopying > _addPin_newIdentifier;
}

/*
  If you don't use the appropriate initWith... method, the following properties will be nil. They MUST be set in order to display any tiles.
 */
@property (nonatomic, retain) id < MRTileProvider > tileProvider;
@property (nonatomic, retain) id < MRProjection > mapProjection;

/*
 If you want pin support, pinProvider cannot be nil.
 */
@property (nonatomic, retain) id < MRPinProvider > pinProvider;

@property (nonatomic, assign) MRMapCoordinate center; // animated
@property (nonatomic, assign) NSUInteger zoomLevel;   // animated


- (id)initWithFrame:(CGRect)frame tileProvider:(id < MRTileProvider >)tileProvider DEPRECATED_ATTRIBUTE;
// tileProvider and mapProjection must not be nil.
- (id)initWithFrame:(CGRect)frame tileProvider:(id < MRTileProvider >)tileProvider mapProjection:(id < MRProjection >)mapProjection;

- (void)setCenter:(MRMapCoordinate)coord animated:(BOOL)anim;
- (void)setZoomLevel:(NSUInteger)zoom animated:(BOOL)anim;

-(CGPoint)scaledPointForCoordinate:(MRMapCoordinate)coordinate;
-(MRMapCoordinate)coordinateForPoint:(CGPoint)point;

@end
