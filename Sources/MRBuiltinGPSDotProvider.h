//
//  MRBuiltinGPSDotProvider.h
//  Sample
//
//  Created by Devon Stewart on 6/10/13.
//
//

#import <Foundation/Foundation.h>

#import "MRArtifactController.h"

@interface MRBuiltinGPSDotProvider : NSObject <MRArtifactController>
{
    UIView *gpsDot;
    CLLocation *lastLocation;
}

@end
