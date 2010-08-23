//
//  MRTileProvider.h
//  MapKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

@protocol MRTileProvider < NSObject >

- (NSURL *)tileURLForTile:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom;

- (NSUInteger)minZoomLevel;
- (NSUInteger)maxZoomLevel;
- (NSUInteger)defaultZoomLevel;

- (CGSize)tileSize;

@end
