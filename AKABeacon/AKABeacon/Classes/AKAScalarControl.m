//
//  AKAScalarControl.m
//  AKABeacon
//
//  Created by Michael Utech on 14.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAScalarControl.h"

@implementation AKAScalarControl

#pragma mark - Value Access

- (id)                                      viewValue
{
    return self.controlViewBinding.targetValueProperty.value;
}

- (void)                                 setViewValue:(id)viewValue
{
    self.controlViewBinding.targetValueProperty.value = viewValue;
}

- (id)                                     modelValue
{
    return self.controlViewBinding.sourceValueProperty.value;
}

- (void)                                setModelValue:(id)modelValue
{
    self.controlViewBinding.sourceValueProperty.value = modelValue;
}

#pragma mark - Conversion

- (BOOL)                             convertViewValue:(opt_id)viewValue
                                         toModelValue:(out_id)modelValueStorage
                                                error:(out_NSError)error
{
    return [self.controlViewBinding convertTargetValue:viewValue
                                         toSourceValue:modelValueStorage
                                                 error:error];
}

- (BOOL)                            convertModelValue:(opt_id)modelValue
                                          toViewValue:(out_id)viewValueStorage
                                                error:(out_NSError)error
{
    return [self.controlViewBinding convertSourceValue:modelValue
                                         toTargetValue:viewValueStorage
                                                 error:error];
}

@end
