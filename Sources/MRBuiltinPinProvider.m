//
//  MRBuiltinPinProvider.m
//  Sample
//
//  Created by Devon Stewart on 6/6/13.
//
//

#import <QuartzCore/QuartzCore.h>

#import "MRBuiltinPinProvider.h"
#import "MRMapTypes.h"
#import "MRMapView.h"

@implementation MRBuiltinPin

@synthesize provider=_provider;

+(CGPoint)dragOffset
{
    return CGPointMake(0, 25 * [UIScreen mainScreen].scale);
}

-(void)initializeVariables
{
    imageName = @"CurrentLocationPin";
    UIImage *backgroundImage = [UIImage imageNamed:imageName];
    if(backgroundImage)
    {
        backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
        pinSize = CGSizeMake(64, 104);
        pinAnchorPoint = CGPointMake(7, 45);
        pinHandle = CGRectMake(6, 0, 48, 47);
    }
    else
    {
        self.backgroundColor = [UIColor redColor];
        pinSize = CGSizeMake(10, 10);
        imageName = nil;
    }
}

-(void)commonInit
{
    dragOffset = [[self class] dragOffset];

    [self initializeVariables];

    if(CGPointEqualToPoint(pinAnchorPoint, CGPointZero))
    {
        pinAnchorPoint = CGPointMake(pinSize.width / 2, pinSize.height / 2);
    }

    if(CGRectEqualToRect(pinHandle, CGRectZero))
    {
        pinHandle = CGRectMake(0, 0, pinSize.width, pinSize.height);
    }

    self.frame = CGRectMake(0, 0, pinSize.width, pinSize.height);
    self.layer.anchorPoint = CGPointMake(pinAnchorPoint.x / pinSize.width, pinAnchorPoint.y / pinSize.height);

    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
    longPressGesture.delegate = self;
    [self addGestureRecognizer:longPressGesture];
}

-(id)init
{
    if((self = [super init]))
    {
        [self commonInit];
    }
    return self;
}

-(void)drag:(UILongPressGestureRecognizer *)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [recognizer locationInView:[self superview]];
        touchOffsetFromCenter = CGPointMake(self.center.x - location.x - dragOffset.x, self.center.y - location.y - dragOffset.y);

        location.x += touchOffsetFromCenter.x;
        location.y += touchOffsetFromCenter.y;

        [UIView beginAnimations:@"liftPin" context:nil];
        [UIView setAnimationDuration:0.15];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        self.center = location;
        [UIView commitAnimations];
    }
    else if(recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint location = [recognizer locationInView:[self superview]];
        location.x += touchOffsetFromCenter.x;
        location.y += touchOffsetFromCenter.y;
        self.center = location;
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateRecognized) {
        id<NSCopying> identifier = [self.provider identifierForPin:self];
        [self.provider updatePinMethod](identifier, self.center);
    }

}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:self];
    return CGRectContainsPoint(pinHandle, location);
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

-(UIView<MRPin> *)newPinForIdentifier:(id<NSCopying>)identifier
{
    NSLog(@"Creating a new pin.");
    UIView<MRPin> *newPin = [_pinClass new];

    newPin.provider = self;

    [_pinStore setObject:newPin forKey:identifier];

    return newPin;
}

-(UIView<MRPin> *)newPinForIdentifier:(id<NSCopying>)identifier withCoordinates:(MRMapCoordinate)coordinates
{
    UIView<MRPin> *newPin = [self newPinForIdentifier:identifier];
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

-(void)updateArtifactsInMapView:(MRMapView *)mapView
{
    for(id<NSCopying> identifier in [self allPinIdentifiers])
    {
        UIView<MRPin> *pin = [self pinForIdentifier:identifier];
        MRMapCoordinate coord = [self coordinateForIdentifier:identifier];

        pin.center = [mapView scaledPointForCoordinate:coord];
    }
}

-(void)registerGesturesInMapView:(MRMapView *)mapView
{
    addPinGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addPin:)];
    [mapView addGestureRecognizer:addPinGestureRecognizer];
}

-(void)addArtifactsToMapView:(MRMapView *)mapView
{
    for(id<NSCopying> identifier in [self allPinIdentifiers])
    {
        UIView<MRPin> *pin = [self pinForIdentifier:identifier];
        [mapView addSubview:pin];
    }
}

-(void)unregisterGesturesInMapView:(MRMapView *)mapView
{
    [mapView removeGestureRecognizer:addPinGestureRecognizer];
    _addPin_newIdentifier = nil; // If unregistered while dragging, this will cause problems if not reset.
}

-(void)removeArtifactsFromMapView:(MRMapView *)mapView
{
    for(id<NSCopying> identifier in [self allPinIdentifiers])
    {
        UIView<MRPin> *pin = [self pinForIdentifier:identifier];
        [pin removeFromSuperview];
    }
}

-(void)addPin:(UILongPressGestureRecognizer *)recognizer {
    if(recognizer != addPinGestureRecognizer)
    {
        NSLog(@"MRBuiltinPinProvider: Kind of strange, addPin: was called with a different gesture recognizer than expected.");
    }

    MRMapView *mapView = (MRMapView *)[recognizer view];
    CGPoint dragOffset = [[self pinClass] dragOffset];

    CGPoint location = [recognizer locationInView:mapView];
    location.x -= dragOffset.x;
    location.y -= dragOffset.y;

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSAssert(_addPin_newIdentifier == nil, @"MRMapView: _addPin_newIdentifier != nil, addPin already in progress?");

        _addPin_newIdentifier = [NSDate date];
        UIView<MRPin> *pin = [self newPinForIdentifier:_addPin_newIdentifier];
        pin.center = location;
        [mapView addSubview:pin];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        UIView<MRPin> *pin = [self pinForIdentifier:_addPin_newIdentifier];
        pin.center = location;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        UIView<MRPin> *pin = [self pinForIdentifier:_addPin_newIdentifier];
        MRMapCoordinate coord = [mapView coordinateForPoint:pin.center];
        [self updatePin:_addPin_newIdentifier withCoordinates:coord];
        _addPin_newIdentifier = nil;
    }
}

@end
