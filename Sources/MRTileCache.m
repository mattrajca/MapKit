//
//  MRTileCache.m
//  MapKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "MRTileCache.h"

@interface MRTileCache ()

- (NSString *)tileKeyForX:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom;
- (NSString *)pathForTileAtX:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom;
- (NSString *)cacheDirectory;

@end


@implementation MRTileCache

static NSString *const kTileKeyFormat = @"%d_%d_%d.jpg";

+ (id)sharedTileCache {
	static MRTileCache *sharedTileCache;
	
	if (!sharedTileCache) {
		sharedTileCache = [[MRTileCache alloc] init];
	}
	
	return sharedTileCache;
}

- (NSString *)tileKeyForX:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom {
	return [NSString stringWithFormat:kTileKeyFormat, x, y, zoom];
}

- (NSString *)pathForTileAtX:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *cacheDirectory = [self cacheDirectory];
	
	if (![fm fileExistsAtPath:cacheDirectory isDirectory:NULL]) {
		[fm createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	NSString *tileKey = [self tileKeyForX:x y:y zoomLevel:zoom];
	return [cacheDirectory stringByAppendingPathComponent:tileKey];
}

- (NSString *)cacheDirectory {
	NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	
	if (![dirs count])
		return nil;
	
	return [[dirs objectAtIndex:0] stringByAppendingPathComponent:@"Tiles"];
}

- (UIImage *)tileAtX:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom {
	NSString *path = [self pathForTileAtX:x y:y zoomLevel:zoom];
	NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
	
	if (!data)
		return nil;
	
	return [UIImage imageWithData:data];
}

- (void)setTile:(UIImage *)img x:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom {
	NSData *data = UIImageJPEGRepresentation(img, 0.8f);
	
	NSString *path = [self pathForTileAtX:x y:y zoomLevel:zoom];
	[data writeToFile:path atomically:YES];
}

@end
