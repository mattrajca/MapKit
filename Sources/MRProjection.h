//
//  MRProjection.h
//  MapKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "MRMapTypes.h"

@protocol MRProjection < NSObject >

// Convert pixel coordinates to latitude / longitude and vice-versa
- (CGPoint)pointForCoordinate:(MRMapCoordinate)coordinate zoomLevel:(NSUInteger)zoom tileSize:(CGSize)tileSize;
- (MRMapCoordinate)coordinateForPoint:(CGPoint)point zoomLevel:(NSUInteger)zoom tileSize:(CGSize)tileSize;

@end
