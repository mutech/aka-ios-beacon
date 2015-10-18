//
//  AKAScalarControl.m
//  AKAControls
//
//  Created by Michael Utech on 14.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAScalarControl.h"

@implementation AKAScalarControl

#pragma mark - Value Access

- (id)                                      viewValue
{
    return self.controlViewBinding.bindingTarget.value;
}

- (void)                                 setViewValue:(id)viewValue
{
    self.controlViewBinding.bindingTarget.value = viewValue;
}

- (id)                                     modelValue
{
    return self.controlViewBinding.bindingSource.value;
}

- (void)                                setModelValue:(id)modelValue
{
    self.controlViewBinding.bindingSource.value = modelValue;
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

#pragma mark - Bindings Owner

- (BOOL)addBinding:(req_AKABinding)binding
{
    BOOL result = [super addBinding:binding];
    if (result && [binding isKindOfClass:[AKAControlViewBinding class]])
    {
        _controlViewBinding = (AKAControlViewBinding*)binding;
    }
    return result;
}

- (BOOL)removeBinding:(req_AKABinding)binding
{
    BOOL result = [super removeBinding:binding];
    if (result && _controlViewBinding == binding)
    {
        _controlViewBinding = nil;
    }
    return result;
}

@end
