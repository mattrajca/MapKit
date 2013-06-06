//
//  MRBuiltinPinProvider.h
//  Sample
//
//  Created by Devon Stewart on 6/6/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MRPinProvider.h"

@interface MRBuiltinPin : UIView <MRPin>

@end

@interface MRBuiltinPinProvider : NSObject <MRPinProvider>
{
    NSMutableDictionary *_pinStore;
    NSMutableDictionary *_coordStore;
}

@property (nonatomic, retain) Class pinClass;

@end