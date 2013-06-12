//
//  MRBuiltinPinProvider.h
//  Sample
//
//  Created by Devon Stewart on 6/6/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MRPin.h"
#import "MRPinProvider.h"

@interface MRBuiltinPin : UIView <MRPin, UIGestureRecognizerDelegate>
{
    UIColor *backgroundColor;
    CGSize pinSize;
    CGPoint pinAnchorPoint;
    CGRect pinHandle;
    @private
    CGPoint touchOffsetFromCenter;
    CGPoint dragOffset; // Convenience ivar. Override +dragOffset instead of changing this directly.
}

// Subclasses should override the following methods
-(void)initializeVariables;

@end

@interface MRBuiltinPinProvider : NSObject <MRPinProvider>
{
    NSMutableDictionary *_pinStore;
    NSMutableDictionary *_coordStore;
    @private
    id < NSCopying > _addPin_newIdentifier;
    UILongPressGestureRecognizer *addPinGestureRecognizer;
}

@end
