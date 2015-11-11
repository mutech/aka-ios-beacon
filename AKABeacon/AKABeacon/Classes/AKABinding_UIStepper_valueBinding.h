//
//  AKABinding_UIStepper_valueBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 09.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAControlViewBinding.h"

@interface AKABinding_UIStepper_valueBinding : AKAControlViewBinding

@property(nonatomic) AKABindingExpression*  minimumValueExpression;
@property(nonatomic) AKABindingExpression*  maximumValueExpression;
@property(nonatomic) AKABindingExpression*  stepValueExpression;
@property(nonatomic) NSNumber*              autorepeat;
@property(nonatomic) NSNumber*              continuous;
@property(nonatomic) NSNumber*              wraps;

@property(nonatomic, readonly) UIStepper*   uiStepper;

@end
