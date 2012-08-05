//
//  MRMQOTileProvider.m
//
//  Tile provider for MapQuest Open ( http://wiki.openstreetmap.org/wiki/Mapquest )
//

#import "MRMQOTileProvider.h"

@implementation MRMQOTileProvider

- (NSURL *)tileURLForTile:(NSUInteger)x y:(NSUInteger)y zoomLevel:(NSUInteger)zoom {
    static NSUInteger tiledomain=0;
	NSString *url = [NSString stringWithFormat:@"http://otile%d.mqcdn.com/tiles/1.0.0/osm/%d/%d/%d.png", tiledomain+1,zoom, x, y];
    
    //Alternate through MapQuest's 4 tile subdomains
    tiledomain=(tiledomain+1)%4;
	
	return [NSURL URLWithString:url];
}

- (NSUInteger)minZoomLevel {
	return 0;
}

- (NSUInteger)maxZoomLevel {
	return 18;
}

- (CGSize)tileSize {
	return CGSizeMake(256.0f, 256.0f);
}
@end
