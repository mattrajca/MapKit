//
//  MRBuiltinPinProvider.m
//  Sample
//
//  Created by Devon Stewart on 6/6/13.
//
//

#import <QuartzCore/QuartzCore.h>

#import "MRBuiltinPinProvider.h"
#import "MRPin.h"
#import "MRMapTypes.h"

@implementation MRBuiltinPin

-(id)init
{
    if((self = [super init]))
    {
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
        longPressGesture.delegate = self;
        [self addGestureRecognizer:longPressGesture];
    }
    return self;
}

-(void)drag:(UILongPressGestureRecognizer *)recognizer
{
    NSLog(@"Long press drag!");
}

@end

@implementation MRBuiltinPinProvider

@synthesize pinClass = _pinClass;

-(id)init
{
    if((self = [super init])) {
        self.pinClass = [MRBuiltinPin class];
        _pinStore = [NSMutableDictionary new];
        _coordStore = [NSMutableDictionary new];
    }

    return self;
}

-(NSArray *)allPinIdentifiers
{
    return [_pinStore allKeys];
}

-(UIView<MRPin> *)newPinForIdentifier:(id<NSCopying>)identifier withCoordinates:(MRMapCoordinate)coordinates
{
    NSLog(@"Creating a new pin.");
    UIView<MRPin> *newPin = [_pinClass new];

    newPin.frame = CGRectMake(0, 0, 64, 104);
    newPin.layer.anchorPoint = CGPointMake(7.0 / 64.0, 45.0 / 104.0);
    newPin.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"CurrentLocationPin"]];

    [_pinStore setObject:newPin forKey:identifier];
    [_coordStore setObject:MRMapCoordinateToValue(coordinates) forKey:identifier];

    return newPin;
}

-(void)addPin:(UIView<MRPin> *)pin forIdentifier:(id<NSCopying>)identifier withCoordinates:(MRMapCoordinate)coordinates
{
    [_pinStore setObject:pin forKey:identifier];
    [_coordStore setObject:MRMapCoordinateToValue(coordinates) forKey:identifier];
}

-(UIView<MRPin> *)pinForIdentifier:(id<NSCopying>)identifier
{
    return [_pinStore objectForKey:identifier];
}

-(MRMapCoordinate)coordinateForIdentifier:(id<NSCopying>)identifier
{
    return MRMapCoordinateFromValue([_coordStore objectForKey:identifier]);
}

-(void)updatePin:(id<NSCopying>)identifier withCoordinates:(MRMapCoordinate)coordinates
{
    [_coordStore setObject:MRMapCoordinateToValue(coordinates) forKey:identifier];
}

-(void)removePin:(id<NSCopying>)identifier
{
    UIView *view = [_pinStore objectForKey:identifier];
    [view removeFromSuperview];

    [_pinStore removeObjectForKey:identifier];
    [_coordStore removeObjectForKey:identifier];
}

@end
