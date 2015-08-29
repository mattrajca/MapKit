//
//  MRTileCache.m
//  MapKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "MRTileCache.h"

#include <sys/stat.h>

@interface MRTileCache ()

- (NSString *)tileKeyForX:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom;
- (NSString *)pathForTileAtX:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom;

- (NSDate *)modificationDateForItemAtPath:(NSString *)aPath;

@property (nonatomic, readonly, copy) NSArray *cacheContents;

- (void)flushCachesThread;

@property (readonly) BOOL flushing;

@end


@implementation MRTileCache

@synthesize maxCacheSize = _maxCacheSize;
@synthesize cacheDirectory = _cacheDirectory;
@synthesize flushing = _flushing;

static NSString *const kTileKeyFormat = @"%ld_%ld_%ld.png";

#define kDefaultMaxCacheSize 1000

- (instancetype)initWithCacheDirectory:(NSString *)aPath {
	NSParameterAssert (aPath != nil);
	
	self = [super init];
	if (self) {
		self.maxCacheSize = kDefaultMaxCacheSize;
		_cacheDirectory = [aPath copy];
	}
	return self;
}

- (NSString *)tileKeyForX:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom {
	return [NSString stringWithFormat:kTileKeyFormat, (unsigned long)x, (unsigned long)y, (unsigned long)zoom];
}

- (NSString *)pathForTileAtX:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom {
	NSString *tileKey = [self tileKeyForX:x y:y zoomLevel:zoom];
	
	return [self.cacheDirectory stringByAppendingPathComponent:tileKey];
}

- (NSData *)tileAtX:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom {
	if (self.flushing)
		return nil;
	
	NSFileManager *fm = [[NSFileManager alloc] init];
	
	NSString *path = [self pathForTileAtX:x y:y zoomLevel:zoom];
	NSData *data = [fm contentsAtPath:path];

	if (!data)
		return nil;
	
	return data;
}

- (void)setTile:(NSData *)data x:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom {
	if (self.flushing)
		return;
	
	NSString *path = [self pathForTileAtX:x y:y zoomLevel:zoom];
	[data writeToFile:path atomically:YES];
}

- (NSDate *)modificationDateForItemAtPath:(NSString *)aPath {
	struct tm *date;
	struct stat attrib;
	
	stat(aPath.fileSystemRepresentation, &attrib);
	date = gmtime(&(attrib.st_mtime));
	
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	comps.second = date->tm_sec;
	comps.minute = date->tm_min;
	comps.hour = date->tm_hour;
	comps.day = date->tm_mday;
	comps.month = date->tm_mon + 1;
	comps.year = date->tm_year + 1900;
	
	static NSCalendar *cal;
	
	if (!cal)
		cal = [NSCalendar currentCalendar];
	
	NSTimeInterval tz = [NSTimeZone systemTimeZone].secondsFromGMT;
	
	return [[cal dateFromComponents:comps] dateByAddingTimeInterval:tz];
}

- (NSArray *)cacheContents {
	NSFileManager *fm = [[NSFileManager alloc] init];
	NSString *cacheDirectory = self.cacheDirectory;
    NSArray *contents = [fm contentsOfDirectoryAtPath:cacheDirectory error:nil];
		
	NSMutableArray *files = [NSMutableArray arrayWithCapacity:contents.count];
	
	for (NSString *path in contents) {
		NSString *fPath = [cacheDirectory stringByAppendingPathComponent:path];
		NSDate *modificationDate = [self modificationDateForItemAtPath:fPath];
		
		[files addObject:@{@"path": fPath,
						  @"modificationDate": modificationDate}];
	}
	
	[files sortUsingComparator:^(id path1, id path2) {
		return [path1[@"modificationDate"] compare:
				path2[@"modificationDate"]];
	}];
	
	return files;
}

- (void)flushOldCaches {
	if (self.flushing)
		return;
	
	[NSThread detachNewThreadSelector:@selector(flushCachesThread) toTarget:self withObject:nil];
}

- (void)flushCachesThread {
	@autoreleasepool {
		_flushing = YES;
		
		NSFileManager *fm = [[NSFileManager alloc] init];
		
		NSArray *contents = self.cacheContents;
		NSUInteger count = contents.count;
		
		if (count >= _maxCacheSize) {
			// free so we have 2/3 of the max size
			for (NSUInteger n = 0; n < (count - (_maxCacheSize * 2 / 3)); n++) {
				NSString *path = [contents[n] valueForKey:@"path"];
				[fm removeItemAtPath:path error:nil];
			}
		}

		_flushing = NO;
	}
}

@end
