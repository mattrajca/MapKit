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
#import "MRPinProvider.h"

@implementation MRBuiltinPin

@synthesize provider=_provider;

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
    if(recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint location = [recognizer locationInView:[self superview]];
        location.y -= 50;
        self.center = location;
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateRecognized) {
        NSLog(@"drag else");

        id<NSCopying> identifier = [self.provider identifierForPin:self];
        [self.provider updatePinMethod](identifier, self.center);
    }
}

@end

@implementation MRBuiltinPinProvider

@synthesize pinClass = _pinClass;
@synthesize updatePinMethod = _updatePinMethod;

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

    newPin.provider = self;
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

-(id<NSCopying>)identifierForPin:(UIView<MRPin> *)somePin
{
    for(id<NSCopying>identifier in [_pinStore keyEnumerator]) {
        UIView<MRPin> *pin = [_pinStore objectForKey:identifier];
        if(pin == somePin) {
            return identifier;
        }
    }

    return nil;
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
