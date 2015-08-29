//
//  MRMapView.h
//  MapKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "MRMapTypes.h"

@protocol MRTileProvider, MRProjection;

/*
  NOTE: MRMapView sets itself as the delegate of its UIScrollView superclass
  Don't change it!
  
  The QuartzCore framework must also be linked against in order to use MRMapView
*/

@interface MRMapView : UIScrollView < UIScrollViewDelegate >

/*
  If you don't use the - initWithFrame:tileProvider: initializer, the
  tile provider will be nil. It MUST be set in order to display any tiles
*/
@property (nonatomic) id < MRTileProvider > tileProvider;

// The default projection is MRMercatorProjection
@property (nonatomic) id < MRProjection > mapProjection;

@property (nonatomic) MRMapCoordinate center; // animated
@property (nonatomic) NSUInteger zoomLevel;   // animated


// tileProvider must not be nil
- (instancetype)initWithFrame:(CGRect)frame tileProvider:(id < MRTileProvider >)tileProvider;

- (void)setCenter:(MRMapCoordinate)coord animated:(BOOL)anim;
- (void)setZoomLevel:(NSUInteger)zoom animated:(BOOL)anim;

@end
