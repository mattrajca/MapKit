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
	NSParameterAssert(tileProvider != nil);
	
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
	
	self.mapProjection = [[MRMercatorProjection new] autorelease];
}

- (void)configureScrollView {
	self.contentSize = [_tileProvider tileSize];
	
	// don't support zooming to zoom level 0 with a single 256x256 tile on purpose
	self.minimumZoomScale = MRMapScaleFromZoomLevel([_tileProvider defaultZoomLevel]);
	self.maximumZoomScale = MRMapScaleFromZoomLevel([_tileProvider maxZoomLevel]);
	self.delegate = _tileProvider ? self : nil;
}

- (void)configureLayers {
	if (!_baseView) {
		_baseView = [[MRMapBaseView alloc] initWithFrame:[self bounds]];
		
		[self insertSubview:_baseView atIndex:0];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	// Support higher resolution displays
	_baseView.contentScaleFactor = 1.0f / [UIScreen mainScreen].scale;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _baseView;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];

	if (touch.tapCount == 2) {
		NSUInteger zoom = MRMapZoomLevelFromScale(self.zoomScale);
		
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
}

- (void)setTileProvider:(id < MRTileProvider > )prov {
	if (_tileProvider != prov) {
		[self willChangeValueForKey:@"tileProvider"];
		
		[_tileProvider release];
		_tileProvider = [prov retain];
		
		[self didChangeValueForKey:@"tileProvider"];
		
		[self configureScrollView];
		[self configureLayers];
		
		_baseView.tileProvider = _tileProvider;
		
		[self setZoomLevel:[_tileProvider defaultZoomLevel] animated:NO];
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

- (void)dealloc {
	[_baseView release];
	[_tileProvider release];
	[_mapProjection release];
	
	[super dealloc];
}

@end


@implementation MRMapBaseView

@synthesize tileProvider;

+ (Class)layerClass {
	return [CATiledLayer class];
}

- (void)configureLayer {
	_cache = [MRTileCache sharedTileCache];
	
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
	
	UIImage *img = [_cache tileAtX:x y:y zoomLevel:zoomLevel];
	
	if (img) {
		[img drawInRect:crect];
	}
	else {
		NSURL *tileURL = [_tileProvider tileURLForTile:x y:y zoomLevel:zoomLevel];
		NSData *data = [[NSData alloc] initWithContentsOfURL:tileURL];
		
		if (!data)
			return;
		
		UIImage *tileImage = [[UIImage alloc] initWithData:data];
		[data release];
		
		[tileImage drawInRect:crect];
		[_cache setTile:tileImage x:x y:y zoomLevel:zoomLevel];
		
		[tileImage release];
	}
}

@end
