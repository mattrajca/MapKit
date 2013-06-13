//
//  MRProjection.h
//  MapKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "MRMapTypes.h"
#include <AvailabilityMacros.h>

@protocol MRProjection < NSObject >

// Convert pixel coordinates to latitude / longitude and vice-versa

- (CGPoint)pointForCoordinate:(MRMapCoordinate)coordinate zoomLevel:(NSUInteger)zoom tileSize:(CGSize)tileSize DEPRECATED_ATTRIBUTE;
- (CGPoint)scaledPointForCoordinate:(MRMapCoordinate)coordinate zoomScale:(float)zoomScale contentSize:(CGSize)contentSize tileSize:(CGSize)tileSize andOffset:(CGPoint)offset;

- (MRMapCoordinate)coordinateForPoint:(CGPoint)point zoomLevel:(NSUInteger)zoom tileSize:(CGSize)tileSize DEPRECATED_ATTRIBUTE;
- (MRMapCoordinate)coordinateForPoint:(CGPoint)point zoomScale:(float)zoomScale contentSize:(CGSize)contentSize tileSize:(CGSize)tileSize andOffset:(CGPoint)offset;

@end
