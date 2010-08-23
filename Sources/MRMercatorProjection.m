//
//  MRMercatorProjection.m
//  MapKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "MRMercatorProjection.h"

@implementation MRMercatorProjection

- (CGPoint)pointForCoordinate:(MRMapCoordinate)coordinate
					zoomLevel:(NSUInteger)zoom tileSize:(CGSize)tileSize {
	
	double sinLatitude = sin(coordinate.latitude * M_PI / 180);
	CGFloat y = ((0.5 - log((1 + sinLatitude) / (1 - sinLatitude)) / (4 * M_PI)) * ((long) tileSize.height << zoom));
	CGFloat x = ((coordinate.longitude + 180) / 360 * ((long) tileSize.width << zoom));
	
	return CGPointMake(x, y);
}

- (MRMapCoordinate)coordinateForPoint:(CGPoint)point zoomLevel:(NSUInteger)zoom 
							 tileSize:(CGSize)tileSize {
	
	MRLongitude lon = 360 * ((point.x / ((long) tileSize.width << zoom)) - 0.5);
	
	double y = 0.5 - (point.y / ((long) tileSize.height << zoom));
	MRLatitude lat = 90 - 360 * atan(exp(-y * 2 * M_PI)) / M_PI;
	
	return MRMapCoordinateMake(lat, lon);
}

@end
