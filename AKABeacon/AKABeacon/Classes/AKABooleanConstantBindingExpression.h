//
//  AKABooleanConstantBindingExpression.h
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKANumberConstantBindingExpression.h"


@interface AKABooleanConstantBindingExpression: AKANumberConstantBindingExpression

+ (AKABooleanConstantBindingExpression*_Nonnull)constantTrue;
+ (AKABooleanConstantBindingExpression*_Nonnull)constantFalse;

@end
