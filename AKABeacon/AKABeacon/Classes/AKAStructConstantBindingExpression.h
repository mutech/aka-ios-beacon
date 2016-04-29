//
//  AKAStructConstantBindingExpression.h
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAConstantBindingExpression.h"

@interface AKAStructConstantBindingExpression : AKAConstantBindingExpression

+ (opt_NSNumber) coordinateWithKeys:(NSArray<NSString*>*_Nullable)keys
                     fromAttributes:(opt_AKABindingExpressionAttributes)attributes
                           required:(BOOL)required;

@end
