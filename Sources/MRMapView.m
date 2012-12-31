//
//  MRMapView.m
//  MapKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "MRMapView.h"

#import <QuartzCore/QuartzCore.h>

#import "MRMercatorProjection.h"
#import "MRProjection.h"
#import "MRTileCache.h"
#import "MRTileProvider.h"

@interface MRMapBaseView : UIView {
  @private
	MRTileCache *_cache;
	id < MRTileProvider > _tileProvider;
}

@property (nonatomic, assign) id < MRTileProvider > tileProvider;

- (void)configureLayer;
- (NSString *)cacheDirectory;

@end


@interface MRMapView ()

- (void)commonInit;
- (void)configureScrollView;
- (void)configureLayers;

@end


@implementation MRMapView

@synthesize tileProvider = _tileProvider;
@synthesize mapProjection = _mapProjection;
@dynamic center, zoomLevel;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame tileProvider:(id < MRTileProvider >)tileProvider {
	NSParameterAssert (tileProvider != nil);
	
	self = [self initWithFrame:frame];
	if (self) {
		self.tileProvider = tileProvider;
	}
	return self;
}

- (void)commonInit {
	self.backgroundColor = [UIColor grayColor];
	self.showsHorizontalScrollIndicator = NO;
	self.showsVerticalScrollIndicator = NO;
	self.scrollsToTop = NO;
	self.bounces = NO;
	
	self.mapProjection = [MRMercatorProjection new];
}

- (void)configureScrollView {
	self.contentSize = [_tileProvider tileSize];
	self.minimumZoomScale = 1.0f;
	self.maximumZoomScale = MRMapScaleFromZoomLevel([_tileProvider maxZoomLevel]);
	self.delegate = _tileProvider ? self : nil;
}

- (void)configureLayers {
	if (!_baseView) {
		_baseView = [[MRMapBaseView alloc] initWithFrame:[self bounds]];
		_baseView.multipleTouchEnabled = YES;
		
		[self insertSubview:_baseView atIndex:0];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	// center map if necessary
	CGSize boundsSize = self.bounds.size;
	CGRect frameToCenter = _baseView.frame;
	
	if (frameToCenter.size.width < boundsSize.width)
		frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
	else
		frameToCenter.origin.x = 0;
	
	if (frameToCenter.size.height < boundsSize.height)
		frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
	else
		frameToCenter.origin.y = 0;
	
	_baseView.frame = frameToCenter;

	// Support higher resolution displays
	_baseView.contentScaleFactor = 1.0f / [UIScreen mainScreen].scale;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _baseView;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	
	UITouch *touch = [touches anyObject];
	NSUInteger zoom = MRMapZoomLevelFromScale(self.zoomScale);
	
	if ([touches count] == 1 && touch.tapCount == 2) {
		// zoom in
		if (zoom < [_tileProvider maxZoomLevel]) {
			CGPoint pt = [touch locationInView:self];
			
			MRMapCoordinate coord = [_mapProjection coordinateForPoint:pt
															 zoomLevel:zoom
															  tileSize:[_tileProvider tileSize]];
			zoom++;
			
			[self setCenter:coord animated:NO];
			self.zoomLevel = zoom;
		}
	}
	else if ([touches count] == 2 && touch.tapCount == 1) {
		// zoom out
		if (zoom > [_tileProvider minZoomLevel]) {
			self.zoomLevel = --zoom;
		}
	}
}

- (void)setTileProvider:(id < MRTileProvider > )prov {
	if (_tileProvider != prov) {
		_tileProvider = prov;
		
		[self configureScrollView];
		[self configureLayers];
		
		_baseView.tileProvider = _tileProvider;
		
		[self setCenter:MRMapCoordinateMake(0, 0) animated:NO];
	}
}

- (NSUInteger)zoomLevel {
	return MRMapZoomLevelFromScale(self.zoomScale);
}

- (void)setZoomLevel:(NSUInteger)zoom {
	[self setZoomLevel:zoom animated:YES];
}

- (void)setZoomLevel:(NSUInteger)zoom animated:(BOOL)anim {
	[self setZoomScale:MRMapScaleFromZoomLevel(zoom) animated:anim];
}

- (MRMapCoordinate)center {
	CGPoint pt = self.contentOffset;
	pt.x += self.bounds.size.width / 2;
	pt.y += self.bounds.size.height / 2;
	
	return [_mapProjection coordinateForPoint:pt
									zoomLevel:self.zoomLevel
									 tileSize:[_tileProvider tileSize]];
}

- (void)setCenter:(MRMapCoordinate)coord {
	[self setCenter:coord animated:YES];
}

- (void)setCenter:(MRMapCoordinate)coord animated:(BOOL)anim {
	CGPoint pt = [_mapProjection pointForCoordinate:coord
										  zoomLevel:self.zoomLevel
										   tileSize:[_tileProvider tileSize]];
	
	pt.x -= self.bounds.size.width / 2;
	pt.y -= self.bounds.size.height / 2;
	
	[self setContentOffset:pt animated:anim];
}

@end


@implementation MRMapBaseView

@synthesize tileProvider;

static NSString *const kLastFlushedKey = @"lastFlushedTileCache";

#define kDay 60 * 60 * 24

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		_cache = [[MRTileCache alloc] initWithCacheDirectory:[self cacheDirectory]];
		
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		NSDate *date = [defs valueForKey:kLastFlushedKey];
		
		if (!date || -[date timeIntervalSinceNow] > kDay) {
			[_cache flushOldCaches];
			
			[defs setValue:[NSDate date] forKey:kLastFlushedKey];
			[defs synchronize];
		}
	}
	return self;
}

- (NSString *)cacheDirectory {
	NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	
	if (![dirs count])
		return nil;
	
	NSString *path = [[dirs objectAtIndex:0] stringByAppendingPathComponent:@"Tiles"];
	
	NSFileManager *fm = [[NSFileManager alloc] init];
	
	if (![fm fileExistsAtPath:path isDirectory:NULL]) {
		[fm createDirectoryAtPath:path withIntermediateDirectories:YES
					   attributes:nil error:nil];
	}

	return path;
}

+ (Class)layerClass {
	return [CATiledLayer class];
}

- (void)configureLayer {
	CATiledLayer *tiledLayer = (CATiledLayer *) self.layer;
	tiledLayer.levelsOfDetail = [_tileProvider maxZoomLevel];
	tiledLayer.levelsOfDetailBias = [_tileProvider maxZoomLevel];
	
	CGSize tileSize = [_tileProvider tileSize];
	tiledLayer.tileSize = tileSize;
	tiledLayer.frame = CGRectMake(0.0f, 0.0f, tileSize.width, tileSize.height);
	
	[self.layer setNeedsDisplay];
}

- (void)setTileProvider:(id < MRTileProvider >)prov {
	if (_tileProvider != prov) {
		_tileProvider = prov;
		
		[self configureLayer];
	}
}

- (void)drawRect:(CGRect)rect {
	if (!_tileProvider) {
		return;
	}
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGRect crect = CGContextGetClipBoundingBox(ctx);
	CGFloat scale = CGContextGetCTM(ctx).a;
		
	NSUInteger zoomLevel = MRMapZoomLevelFromScale(scale);
	NSUInteger x = floor(crect.origin.x / crect.size.width);
	NSUInteger y = floor(crect.origin.y / crect.size.width);
	
	NSData *tileData = [_cache tileAtX:x y:y zoomLevel:zoomLevel];
	
	if (!tileData) {
		NSURL *tileURL = [_tileProvider tileURLForTile:x y:y zoomLevel:zoomLevel];
		tileData = [[NSData alloc] initWithContentsOfURL:tileURL];
		
		if (!tileData)
			return;
		
		[_cache setTile:tileData x:x y:y zoomLevel:zoomLevel];
	}
	
	UIImage *tileImage = [[UIImage alloc] initWithData:tileData];

	[tileImage drawInRect:crect];
}

@end
