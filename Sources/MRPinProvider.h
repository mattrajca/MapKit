//
//  MRPinProvider.h
//  Sample
//
//  Created by Devon Stewart on 6/6/13.
//
//

#import <Foundation/Foundation.h>

#import "MRArtifactController.h"

#import "MRMapTypes.h"
#import "MRPin.h"

@protocol MRPinProvider <NSObject, MRArtifactController>

@property (nonatomic, retain) Class pinClass;
@property (nonatomic, copy) MRUpdatePinCoordinateWithPoint updatePinMethod;

-(UIView<MRPin> *)newPinForIdentifier:(id<NSCopying>)identifier;
-(UIView<MRPin> *)newPinForIdentifier:(id<NSCopying>)identifier withCoordinates:(MRMapCoordinate)coordinates;
-(void)addPin:(UIView<MRPin> *)pin forIdentifier:(id<NSCopying>)identifier withCoordinates:(MRMapCoordinate)coordinates;
-(UIView<MRPin> *)pinForIdentifier:(id<NSCopying>)identifier;
-(id<NSCopying>)identifierForPin:(UIView<MRPin> *)pin;
-(MRMapCoordinate)coordinateForIdentifier:(id<NSCopying>)identifier;
-(void)updatePin:(id<NSCopying>)identifier withCoordinates:(MRMapCoordinate)coordinates;
-(void)removePin:(id<NSCopying>)identifier;
-(NSArray *)allPinIdentifiers;

@end
