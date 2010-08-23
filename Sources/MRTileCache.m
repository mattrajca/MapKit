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

- (NSArray *)cacheContents;
- (void)flushCache;

@end


@implementation MRTileCache

@synthesize maxCacheSize = _maxCacheSize;

static NSString *const kTileKeyFormat = @"%d_%d_%d.png";
static NSString *const kLastFlushedKey = @"lastFlushedTileCache";

+ (id)sharedTileCache {
	static MRTileCache *sharedTileCache;
	
	if (!sharedTileCache) {
		sharedTileCache = [[MRTileCache alloc] init];
	}
	
	return sharedTileCache;
}

- (id)init {
	self = [super init];
	if (self) {
		self.maxCacheSize = 2000;
		[self performSelector:@selector(flushCache) withObject:nil afterDelay:1.0f];
	}
	return self;
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
	NSData *data = UIImagePNGRepresentation(img);
	
	NSString *path = [self pathForTileAtX:x y:y zoomLevel:zoom];
	[data writeToFile:path atomically:YES];
}

#define kDay 60

- (NSArray *)cacheContents {
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self cacheDirectory]
                                                                         error:nil];
	
	NSMutableArray *filesAndProperties = [NSMutableArray
										  arrayWithCapacity:[files count]];
	for(NSString* path in files)
	{
		NSDictionary* properties = [[NSFileManager defaultManager]
									attributesOfItemAtPath:path
									error:nil];
		NSDate* modDate = [properties objectForKey:NSFileCreationDate];
		
			[filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:
										   path, @"path",
										   modDate, @"lastModDate",
										   nil]];
	}
	
	NSArray* sortedFiles = [filesAndProperties sortedArrayUsingComparator:^(id path1, id path2) {
		return [[path1 objectForKey:@"lastModDate"] compare:
				[path2 objectForKey:@"lastModDate"]];
	}];
	
	NSLog(@"sortedFiles: %@", sortedFiles);
	
	return sortedFiles;
}

- (void)flushCache {
	NSDate *date = [[NSUserDefaults standardUserDefaults] valueForKey:kLastFlushedKey];
	
	if (!date || [date timeIntervalSinceNow] > kDay) {
		NSFileManager *fm = [NSFileManager defaultManager];		
		NSArray *contents = [self cacheContents];
		
		if ([contents count] >= 400) {
			// free so we have 2/3 of the max size
			for (NSUInteger n = 0; n < (400 * 2 / 3); n++) {
				NSString *path = [[contents objectAtIndex:n] valueForKey:@"path"];
				[fm removeItemAtPath:path error:nil];
			}
		}
		
		[[NSUserDefaults standardUserDefaults] setValue:date forKey:kLastFlushedKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

@end
