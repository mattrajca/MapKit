//
//  MRTileCache.h
//  MapKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

@interface MRTileCache : NSObject {
  @private
	NSUInteger _maxCacheSize;
	NSString *_cacheDirectory;
	BOOL _flushing;
}

@property (assign) NSUInteger maxCacheSize; /* in tiles, default=1,000 */
@property (nonatomic, retain) NSString *cacheDirectory;

- (id)initWithCacheDirectory:(NSString *)aPath;

// thread safe...
- (BOOL)tileExistsAtX:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom;
- (NSData *)tileAtX:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom;
- (void)setTile:(NSData	*)data x:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom;

// Dispatches a new thread and flushes old caches from the disk
- (void)flushOldCaches;

@end
