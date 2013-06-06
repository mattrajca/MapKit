//
//  MRMapTypes.m
//  MapKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "MRMapTypes.h"

MRMapCoordinate MRMapCoordinateMake (MRLatitude lat, MRLongitude lng) {
	return (MRMapCoordinate) { .latitude = lat, .longitude = lng };
}

NSUInteger MRMapZoomLevelFromScale (NSUInteger scale) {
	return log2(scale);
}

NSUInteger MRMapScaleFromZoomLevel (NSUInteger zoomLevel) {
	return pow(2, zoomLevel);
}

NSValue *MRMapCoordinateToValue(MRMapCoordinate loc) {
    NSValue *r = [NSValue value:&loc withObjCType:@encode(MRMapCoordinate)];
    return r;
}

MRMapCoordinate MRMapCoordinateFromValue(NSValue *value) {
    MRMapCoordinate r;
    [value getValue:&r];

    return r;
}
