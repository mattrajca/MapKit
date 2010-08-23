//
//  MRTileCache.h
//  MapKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

@interface MRTileCache : NSObject {

}

+ (id)sharedTileCache;

- (UIImage *)tileAtX:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom;
- (void)setTile:(UIImage *)img x:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom;

@end
