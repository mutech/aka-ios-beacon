//
//  AKAControl+BindingDelegate.m
//  AKABeacon
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAControl+BindingDelegate.h"
#import "AKACompositeControl+BindingDelegatePropagation.h"


@implementation AKAControl(BindingDelegate)

- (void)                                      binding:(req_AKABinding)binding
               targetUpdateFailedToConvertSourceValue:(opt_id)sourceValue
                               toTargetValueWithError:(opt_NSError)error
{
    [self setValidationState:(AKAControlValidationStateModelValueInvalid | // Invalid after conversion
                              AKAControlValidationStateModelValueDirty   | // Not in sync w/ model
                              // Preserve view value status
                              (self.validationState & (AKAControlValidationStateViewValueDirty |
                                                       AKAControlValidationStateViewValueValid)))
                   withError:error];

    [self.owner                         control:self
                                        binding:binding
         targetUpdateFailedToConvertSourceValue:sourceValue
                         toTargetValueWithError:error];
}

- (void)                                      binding:(req_AKABinding)binding
              targetUpdateFailedToValidateTargetValue:(opt_id)targetValue
                             convertedFromSourceValue:(opt_id)sourceValue
                                            withError:(opt_NSError)error
{
    [self setValidationState:(AKAControlValidationStateModelValueInvalid | // Invalid after conversion
                              AKAControlValidationStateModelValueDirty   | // Not in sync w/ model
                              // Preserve view value status
                              (self.validationState & (AKAControlValidationStateViewValueDirty |
                                                       AKAControlValidationStateViewValueValid)))
                   withError:error];

    [self.owner                         control:self
                                        binding:binding
        targetUpdateFailedToValidateTargetValue:targetValue
                       convertedFromSourceValue:sourceValue
                                      withError:error];
}

- (BOOL)                                shouldBinding:(req_AKABinding)binding
                                    updateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue
                                       forSourceValue:(opt_id)oldSourceValue
                                             changeTo:(opt_id)newSourceValue
{
    AKACompositeControl* owner = self.owner;
    return owner == nil || [owner control:self
                            shouldBinding:binding
                        updateTargetValue:oldTargetValue
                                       to:newTargetValue
                           forSourceValue:oldSourceValue
                                 changeTo:newSourceValue];
}


- (void)                                      binding:(req_AKABinding)binding
                                willUpdateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue
{
    [self.owner         control:self
                        binding:binding
          willUpdateTargetValue:oldTargetValue
                             to:newTargetValue];
}

- (void)binding:(req_AKABinding)binding didUpdateTargetValue:(opt_id)oldTargetValue to:(opt_id)newTargetValue
 forSourceValue:(opt_id)oldSourceValue changeTo:(opt_id)newSourceValue {
    // A successful update means both model and view values are valid and in sync
    [self setValidationState:AKAControlValidationStateValid
                   withError:nil];

    [self.owner         control:self
                        binding:binding
           didUpdateTargetValue:oldTargetValue
                             to:newTargetValue];
}

@end



