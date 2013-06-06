//
//  MRMapView.m
//  MapKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "MRMapView.h"

#import <QuartzCore/QuartzCore.h>

#import "MRProjection.h"
#import "MRTileCache.h"
#import "MRTileProvider.h"
#import "MRPinProvider.h"
#import "MRPin.h"

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
@synthesize pinProvider = _pinProvider;
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
    if((self = [self initWithFrame:frame])) {
        self.tileProvider = tileProvider;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame tileProvider:(id < MRTileProvider >)tileProvider mapProjection:(id < MRProjection >)mapProjection {
	NSParameterAssert (tileProvider != nil);
	NSParameterAssert (mapProjection != nil);

	self = [self initWithFrame:frame];
	if (self) {
		self.tileProvider = tileProvider;
        self.mapProjection = mapProjection;
	}
	return self;
}

- (void)commonInit {
	self.backgroundColor = [UIColor grayColor];
	self.showsHorizontalScrollIndicator = NO;
	self.showsVerticalScrollIndicator = NO;
	self.scrollsToTop = NO;
	self.bounces = NO;

    UITapGestureRecognizer *zoomInGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomIn:)];
    zoomInGestureRecognizer.numberOfTouchesRequired = 1;
    zoomInGestureRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:zoomInGestureRecognizer];

    UITapGestureRecognizer *zoomOutGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomOut:)];
    zoomOutGestureRecognizer.numberOfTouchesRequired = 2;
    zoomOutGestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:zoomOutGestureRecognizer];

    UILongPressGestureRecognizer *addPinGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addPin:)];
    addPinGestureRecognizer.numberOfTouchesRequired = 1;
    addPinGestureRecognizer.numberOfTapsRequired = 0;
    addPinGestureRecognizer.minimumPressDuration = 0.5;
    addPinGestureRecognizer.allowableMovement = 20;
    [self addGestureRecognizer:addPinGestureRecognizer];
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

-(CGPoint)getOffset
{
    CGPoint offset = CGPointZero;

    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _baseView.frame;

    if(frameToCenter.size.width < boundsSize.width)
    {
        offset.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    if(frameToCenter.size.height < boundsSize.height)
    {
        offset.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }

    return offset;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _baseView;
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
                                    zoomScale:self.zoomScale
                                  contentSize:self.contentSize
                                     tileSize:[_tileProvider tileSize]
                                    andOffset:[self getOffset]];

}

- (void)setCenter:(MRMapCoordinate)coord {
	[self setCenter:coord animated:YES];
}

- (void)setCenter:(MRMapCoordinate)coord animated:(BOOL)anim {
	CGPoint pt = [_mapProjection scaledPointForCoordinate:coord
                                                zoomScale:self.zoomScale
                                              contentSize:self.contentSize
                                                 tileSize:[_tileProvider tileSize]
                                                andOffset:[self getOffset]];

	pt.x -= self.bounds.size.width / 2;
	pt.y -= self.bounds.size.height / 2;
	
	[self setContentOffset:pt animated:anim];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    for(id<NSCopying> identifier in [_pinProvider allPinIdentifiers])
    {
        UIView<MRPin> *pin = [_pinProvider pinForIdentifier:identifier];
        MRMapCoordinate coord = [_pinProvider coordinateForIdentifier:identifier];

        pin.center = [_mapProjection scaledPointForCoordinate:coord
                                                    zoomScale:self.zoomScale
                                                  contentSize:self.contentSize
                                                     tileSize:[_tileProvider tileSize]
                                                    andOffset:[self getOffset]];
    }
}

@end

@implementation MRMapView (gestures)

-(void)zoomIn:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self];
	NSUInteger zoom = MRMapZoomLevelFromScale(self.zoomScale);

    if (zoom < [_tileProvider maxZoomLevel]) {
        MRMapCoordinate coord = [_mapProjection coordinateForPoint:location
                                                         zoomScale:self.zoomScale
                                                       contentSize:self.contentSize
                                                          tileSize:[_tileProvider tileSize]
                                                         andOffset:[self getOffset]];
        self.zoomLevel = ++zoom;
        [self setCenter:coord animated:NO];
    }
}

-(void)zoomOut:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self];
	NSUInteger zoom = MRMapZoomLevelFromScale(self.zoomScale);

    // zoom out
    if (zoom > [_tileProvider minZoomLevel]) {
        MRMapCoordinate coord = [_mapProjection coordinateForPoint:location
                                                         zoomScale:self.zoomScale
                                                       contentSize:self.contentSize
                                                          tileSize:[_tileProvider tileSize]
                                                         andOffset:[self getOffset]];
        self.zoomLevel = --zoom;
        [self setCenter:coord animated:NO];
    }
}

-(void)addPin:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [recognizer locationInView:self];
        MRMapCoordinate coord = [_mapProjection coordinateForPoint:location
                                                         zoomScale:self.zoomScale
                                                       contentSize:self.contentSize
                                                          tileSize:[_tileProvider tileSize]
                                                         andOffset:[self getOffset]];

        UIView<MRPin> *pin = [_pinProvider newPinForIdentifier:[NSDate date] withCoordinates:coord];

        [self addSubview:pin];
    }
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
