//
//  AKAScalarControl+ControlViewBindingDelegate.m
//  AKABeacon
//
//  Created by Michael Utech on 15.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAScalarControl+ControlViewBindingDelegate.h"
#import "AKAKeyboardControlViewBinding.h"
#import "AKACompositeControl+BindingDelegatePropagation.h"


@implementation AKAScalarControl (ControlViewBindingDelegate)

- (void)                                      binding:(req_AKAControlViewBinding)binding
               sourceUpdateFailedToConvertTargetValue:(opt_id)targetValue
                               toSourceValueWithError:(opt_NSError)error
{
    [self setValidationState:(AKAControlValidationStateViewValueInvalid | // Invalid after conversion
                              AKAControlValidationStateViewValueDirty   | // Not in sync w/ model
                              // Preserve model value status
                              (self.validationState & (AKAControlValidationStateModelValueDirty |
                                                       AKAControlValidationStateModelValueValid)))
                   withError:error];

    [self.owner                         control:self
                                        binding:binding
         sourceUpdateFailedToConvertTargetValue:targetValue
                         toSourceValueWithError:error];
}

- (void)                                      binding:(req_AKAControlViewBinding)binding
              sourceUpdateFailedToValidateSourceValue:(opt_id)sourceValue
                             convertedFromTargetValue:(opt_id)targetValue
                                            withError:(opt_NSError)error
{
    // view (target) value by itself is valid but the model (source) value after conversion not, this
    // is interpreted as invalid view value.
    [self setValidationState:(AKAControlValidationStateViewValueInvalid | // Invalid after conversion
                              AKAControlValidationStateViewValueDirty   | // Not in sync w/ model
                              // Preserve model value status
                              (self.validationState & (AKAControlValidationStateModelValueDirty |
                                                       AKAControlValidationStateModelValueValid)))
                   withError:error];

    [self.owner                         control:self
                                        binding:binding
        sourceUpdateFailedToValidateSourceValue:sourceValue
                       convertedFromTargetValue:targetValue
                                      withError:error];
}

- (BOOL)                                shouldBinding:(req_AKAControlViewBinding)binding
                                    updateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
                                       forTargetValue:(opt_id)oldTargetValue
                                             changeTo:(opt_id)newTargetValue
{
    return [self.owner                  control:self
                                  shouldBinding:binding
                              updateSourceValue:oldSourceValue
                                             to:newSourceValue
                                 forTargetValue:oldTargetValue
                                       changeTo:newTargetValue];
}

- (void)                                      binding:(req_AKAControlViewBinding)binding
                                willUpdateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
{
    [self.owner     control:self
                    binding:binding
      willUpdateSourceValue:oldSourceValue
                         to:newSourceValue];
}

- (void)                                      binding:(req_AKAControlViewBinding)binding
                                 didUpdateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
{
    // A successful update means both model and view values are valid and in sync
    [self setValidationState:AKAControlValidationStateValid
                   withError:nil];

    [self.owner     control:self
                    binding:binding
       didUpdateSourceValue:oldSourceValue
                         to:newSourceValue];
}

@end

