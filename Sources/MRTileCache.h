//
//  MRTileCache.h
//  MapKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

@interface MRTileCache : NSObject {
  @private
	NSUInteger _maxCacheSize;
}

@property (assign) NSUInteger maxCacheSize; /* in tiles, default=2,000 */

+ (id)sharedTileCache;

- (UIImage *)tileAtX:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom;
- (void)setTile:(UIImage *)img x:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom;

@end
