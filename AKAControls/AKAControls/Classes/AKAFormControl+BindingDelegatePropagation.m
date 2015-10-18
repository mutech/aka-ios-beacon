//
//  AKAFormControl+BindingDelegatePropagation.m
//  AKAControls
//
//  Created by Michael Utech on 18.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAFormControl+BindingDelegatePropagation.h"
#import "AKAKeyboardActivationSequence.h"

@implementation AKAFormControl (BindingDelegatePropagation)

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKABinding)binding
               targetUpdateFailedToConvertSourceValue:(opt_id)sourceValue
                               toTargetValueWithError:(opt_NSError)error
{
    [self.owner
     control:control
     binding:binding
     targetUpdateFailedToConvertSourceValue:sourceValue
     toTargetValueWithError:error];

    if ([self.delegate respondsToSelector:@selector(control:binding:targetUpdateFailedToConvertSourceValue:toTargetValueWithError:)])
    {
        [self.delegate
         control:control
         binding:binding
         targetUpdateFailedToConvertSourceValue:sourceValue
         toTargetValueWithError:error];
    }
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKABinding)binding
              targetUpdateFailedToValidateTargetValue:(opt_id)targetValue
                             convertedFromSourceValue:(opt_id)sourceValue
                                            withError:(opt_NSError)error
{
    [self.owner
     control:control
     binding:binding
     targetUpdateFailedToValidateTargetValue:targetValue
     convertedFromSourceValue:sourceValue
     withError:error];

    if ([self.delegate respondsToSelector:@selector(control:binding:targetUpdateFailedToValidateTargetValue:convertedFromSourceValue:withError:)])
    {
        [self.delegate
         control:control
         binding:binding
         targetUpdateFailedToValidateTargetValue:targetValue
         convertedFromSourceValue:sourceValue
         withError:error];
    }
}

- (BOOL)                                      control:(req_AKAControl)control
                                        shouldBinding:(req_AKABinding)binding
                                    updateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue
                                       forSourceValue:(opt_id)oldSourceValue
                                             changeTo:(opt_id)newSourceValue
{
    BOOL result = YES;

    if ([self.delegate respondsToSelector:@selector(control:shouldBinding:updateTargetValue:to:forSourceValue:changeTo:)])
    {
        result = [self.delegate
                  control:control
                  shouldBinding:binding
                  updateTargetValue:oldTargetValue
                  to:newTargetValue
                  forSourceValue:oldSourceValue
                  changeTo:newSourceValue];
    }

    if (result && self.owner)
    {
        result = [self.owner
                  control:control
                  shouldBinding:binding
                  updateTargetValue:oldTargetValue
                  to:newTargetValue
                  forSourceValue:oldSourceValue
                  changeTo:newSourceValue];
    }

    return result;
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKABinding)binding
                                willUpdateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue
{
    [self.owner
     control:control
     binding:binding
     willUpdateTargetValue:oldTargetValue
     to:newTargetValue];

    if ([self.delegate respondsToSelector:@selector(control:binding:willUpdateTargetValue:to:)])
    {
        [self.delegate
         control:control
         binding:binding
         willUpdateTargetValue:oldTargetValue
         to:newTargetValue];
    }
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKABinding)binding
                                 didUpdateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue
{
    [self.owner
     control:control
     binding:binding
     didUpdateTargetValue:oldTargetValue
     to:newTargetValue];

    if ([self.delegate respondsToSelector:@selector(control:binding:didUpdateTargetValue:to:)])
    {
        [self.delegate
         control:control
         binding:binding
         didUpdateTargetValue:oldTargetValue
         to:newTargetValue];
    }
}

@end


@implementation AKAFormControl (ControlViewBindingDelegatePropagation)

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAControlViewBinding)binding
               sourceUpdateFailedToConvertTargetValue:(opt_id)targetValue
                               toSourceValueWithError:(opt_NSError)error
{
    [self.owner
     control:control
     binding:binding
     sourceUpdateFailedToConvertTargetValue:targetValue
     toSourceValueWithError:error];

    if ([self.delegate respondsToSelector:@selector(control:binding:sourceUpdateFailedToConvertTargetValue:toSourceValueWithError:)])
    {
        [self.delegate
         control:control
         binding:binding
         sourceUpdateFailedToConvertTargetValue:targetValue
         toSourceValueWithError:error];
    }
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAControlViewBinding)binding
              sourceUpdateFailedToValidateSourceValue:(opt_id)sourceValue
                             convertedFromTargetValue:(opt_id)targetValue
                                            withError:(opt_NSError)error
{
    [self.owner
     control:control
     binding:binding
     sourceUpdateFailedToValidateSourceValue:sourceValue
     convertedFromTargetValue:targetValue
     withError:error];

    if ([self.delegate respondsToSelector:@selector(control:binding:sourceUpdateFailedToValidateSourceValue:convertedFromTargetValue:withError:)])
    {
        [self.delegate
         control:control
         binding:binding
         sourceUpdateFailedToValidateSourceValue:sourceValue
         convertedFromTargetValue:targetValue
         withError:error];
    }
}

- (BOOL)                                      control:(req_AKAControl)control
                                        shouldBinding:(req_AKAControlViewBinding)binding
                                    updateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
                                       forTargetValue:(opt_id)oldTargetValue
                                             changeTo:(opt_id)newTargetValue
{
    BOOL result = YES;

    if ([self.delegate respondsToSelector:@selector(control:shouldBinding:updateSourceValue:to:forTargetValue:changeTo:)])
    {
        result = [self.delegate
                  control:control
                  shouldBinding:binding
                  updateSourceValue:oldSourceValue
                  to:newSourceValue
                  forTargetValue:oldTargetValue
                  changeTo:newTargetValue];
    }

    if (result && self.owner)
    {
        result = [self.owner
                  control:control
                  shouldBinding:binding
                  updateSourceValue:oldSourceValue
                  to:newSourceValue
                  forTargetValue:oldTargetValue
                  changeTo:newTargetValue];
    }

    return result;
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAControlViewBinding)binding
                                willUpdateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
{
    [self.owner
     control:control
     binding:binding
     willUpdateSourceValue:oldSourceValue
     to:newSourceValue];

    if ([self.delegate respondsToSelector:@selector(control:binding:willUpdateSourceValue:to:)])
    {
        [self.delegate
         control:control
         binding:binding
         willUpdateSourceValue:oldSourceValue
         to:newSourceValue];
    }
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAControlViewBinding)binding
                                 didUpdateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
{
    [self.owner
     control:control
     binding:binding
     didUpdateSourceValue:oldSourceValue
     to:newSourceValue];

    if ([self.delegate respondsToSelector:@selector(control:binding:didUpdateSourceValue:to:)])
    {
        [self.delegate
         control:control
         binding:binding
         didUpdateSourceValue:oldSourceValue
         to:newSourceValue];
    }
}

@end


@implementation AKAFormControl (KeyboardControlViewBindingDelegatePropagation)

- (BOOL)                                      control:(req_AKAControl)control
                                        shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                    responderActivate:(req_UIResponder)responder
{
    BOOL result = YES;

    if ([self.delegate respondsToSelector:@selector(control:shouldBinding:responderActivate:)])
    {
        result = [self.delegate control:control shouldBinding:binding responderActivate:responder];
    }

    if (result && self.owner)
    {
        result = [self.owner control:control shouldBinding:binding responderActivate:responder];
    }

    return result;
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                                responderWillActivate:(req_UIResponder)responder
{
    [self.owner control:control binding:binding responderWillActivate:responder];
    if ([self.delegate respondsToSelector:@selector(control:binding:responderWillActivate:)])
    {
        [self.delegate control:control binding:binding responderWillActivate:responder];
    }
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                                 responderDidActivate:(req_UIResponder)responder
{
    [self.owner control:control binding:binding responderDidActivate:responder];
    if ([self.delegate respondsToSelector:@selector(control:binding:responderDidActivate:)])
    {
        [self.delegate control:control binding:binding responderDidActivate:responder];
    }
}

- (BOOL)                                      control:(req_AKAControl)control
                                        shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                  responderDeactivate:(req_UIResponder)responder
{
    BOOL result = YES;

    if ([self.delegate respondsToSelector:@selector(control:shouldBinding:responderDeactivate:)])
    {
        result = [self.delegate control:control shouldBinding:binding responderDeactivate:responder];
    }

    if (result && self.owner)
    {
        result = [self.owner control:control shouldBinding:binding responderDeactivate:responder];
    }

    return result;
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                              responderWillDeactivate:(req_UIResponder)responder
{
    [self.owner control:control binding:binding responderWillDeactivate:responder];
    if ([self.delegate respondsToSelector:@selector(control:binding:responderWillDeactivate:)])
    {
        [self.delegate control:control binding:binding responderWillDeactivate:responder];
    }
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                               responderDidDeactivate:(req_UIResponder)responder
{
    [self.owner control:control binding:binding responderDidDeactivate:responder];
    if ([self.delegate respondsToSelector:@selector(control:binding:responderDidDeactivate:)])
    {
        [self.delegate control:control binding:binding responderDidDeactivate:responder];
    }
}

- (BOOL)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                       responderRequestedActivateNext:(req_UIResponder)responder
{
    return [self.keyboardActivationSequence activateNext];
}

- (BOOL)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                           responderRequestedGoOrDone:(req_UIResponder)responder
{
    // TODO: consider implementing commit form
    return [self.keyboardActivationSequence deactivate];
}

@end
