//
//  MRPin.h
//  Sample
//
//  Created by Devon Stewart on 6/6/13.
//
//

#import <Foundation/Foundation.h>
#import "MRMapTypes.h"

@protocol MRPinProvider;

@protocol MRPin <NSObject>

@property (nonatomic, assign) id<MRPinProvider> provider;
@property (nonatomic, assign) CGFloat accuracyRadius;

+(CGPoint)dragOffset;

@end
