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

+(CGPoint)dragOffset;

@end
