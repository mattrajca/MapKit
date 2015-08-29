//
//  MRTileProvider.h
//  MapKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

@protocol MRTileProvider < NSObject >

- (NSURL *)tileURLForTile:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom;

@property (nonatomic, readonly) NSUInteger minZoomLevel;
@property (nonatomic, readonly) NSUInteger maxZoomLevel;

@property (nonatomic, readonly) CGSize tileSize;

@end
