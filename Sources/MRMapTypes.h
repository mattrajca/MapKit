//
//  MRMapTypes.h
//  MapKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

typedef double MRLatitude;
typedef double MRLongitude;

struct _MRMapCoordinate {
	MRLatitude latitude;
	MRLongitude longitude;
};
typedef struct _MRMapCoordinate MRMapCoordinate;

MRMapCoordinate MRMapCoordinateMake (MRLatitude lat, MRLongitude lng);

// Convert between map scales and zoom levels
NSUInteger MRMapZoomLevelFromScale (NSUInteger scale);
NSUInteger MRMapScaleFromZoomLevel (NSUInteger zoomLevel);
