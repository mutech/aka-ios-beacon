//
//  AKABinding_UITextField_textBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABinding_UITextField_textBinding.h"


#pragma mark - AKABinding_UITextField_textBinding - Private Interface
#pragma mark -

@interface AKABinding_UITextField_textBinding () <UITextFieldDelegate>

#pragma mark - Saved UITextField State

@property(nonatomic, weak) id<UITextFieldDelegate>         savedTextViewDelegate;
@property(nonatomic, nullable) NSString*                   originalText;

#pragma mark - Convenience

@property(nonatomic, readonly) UITextField*                textField;

@end


#pragma mark - AKABinding_UITextField_textBinding - Implementation
#pragma mark -

@implementation AKABinding_UITextField_textBinding

#pragma mark - Initialization

- (instancetype _Nullable)                  initWithTarget:(id)target
                                                expression:(req_AKABindingExpression)bindingExpression
                                                   context:(req_AKABindingContext)bindingContext
                                                  delegate:(opt_AKABindingDelegate)delegate
                                                     error:(out_NSError)error
{
    NSParameterAssert([target isKindOfClass:[UITextField class]]);

    return [self      initWithView:(UITextField*)target
                        expression:bindingExpression
                           context:bindingContext
                          delegate:delegate
                             error:error];
}

- (instancetype)                              initWithView:(req_UITextField)textField
                                                expression:(req_AKABindingExpression)bindingExpression
                                                   context:(req_AKABindingContext)bindingContext
                                                  delegate:(opt_AKABindingDelegate)delegate
                                                     error:(out_NSError)error
{
    NSParameterAssert([textField isKindOfClass:[UITextField class]]);

    if (self = [super initWithView:textField
                        expression:bindingExpression
                           context:bindingContext
                          delegate:delegate
                             error:error])
    {
        NSAssert(self.textField == self.view && self.textField == textField, @"initWithView failed to initialize view property");
        self.liveModelUpdates = YES;
    }

    return self;
}

- (req_AKAProperty)createBindingTargetPropertyForView:(req_UIView)view
{
    NSAssert([view isKindOfClass:[UITextField class]], @"Expected a UITextField, got %@", view);
    (void)view;

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                AKABinding_UITextField_textBinding* binding = target;

                return binding.textField.text;
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_UITextField_textBinding* binding = target;

                if (value == nil)
                {
                    binding.textField.text = @"";
                }

                if ([value isKindOfClass:[NSString class]])
                {
                    binding.textField.text = value;
                }
                else if (value != nil)
                {
                    binding.textField.text = [NSString stringWithFormat:@"%@", value];
                }
            }
            observationStarter:
            ^BOOL (id target)
            {
                AKABinding_UITextField_textBinding* binding = target;
                UITextField* textField = binding.textField;
                id<UITextFieldDelegate> textFieldDelegate = textField.delegate;

                if (textFieldDelegate != binding)
                {
                    binding.originalText = textField.text;
                    binding.savedTextViewDelegate = textFieldDelegate;
                    textField.delegate = binding;
                    [textField addTarget:binding
                                  action:@selector(textFieldDidChange:)
                        forControlEvents:UIControlEventEditingChanged];
                }
                else
                {
                    //AKALogDebug(@"Binding %@ is already observing %@", binding, binding.textField);
                }

                return YES;
            }
            observationStopper:
            ^BOOL (id target)
            {
                AKABinding_UITextField_textBinding* binding = target;
                UITextField* textField = binding.textField;
                [textField removeTarget:target
                                 action:@selector(textFieldDidChange:)
                       forControlEvents:UIControlEventEditingChanged];
                textField.delegate = binding.savedTextViewDelegate;
                binding.originalText = nil;

                return YES;
            }];
}

#pragma mark - Properties

- (UITextField*)                                 textField
{
    UIView* view = self.view;

    NSParameterAssert(view == nil || [view isKindOfClass:[UITextField class]]);

    return (UITextField*)view;
}

- (void)                          setSavedTextViewDelegate:(id<UITextFieldDelegate>)savedTextViewDelegate
{
    NSAssert(savedTextViewDelegate != self, @"Cannot register text field binding as saved delegate, it already acts as replacement/proxy delegate");

    _savedTextViewDelegate = savedTextViewDelegate;
}

#pragma mark - UITextFieldDelegate Implementation

- (BOOL)                       textFieldShouldBeginEditing:(UITextField*)textField
{
    id<UITextFieldDelegate> secondary = self.savedTextViewDelegate;

    BOOL result = YES;

    if ([secondary respondsToSelector:@selector(textFieldShouldBeginEditing:)])
    {
        result = [secondary textFieldShouldBeginEditing:textField];
    }

    if (result)
    {
        result = [self shouldActivate];
    }

    return result;
}

- (void)                          textFieldDidBeginEditing:(UITextField*)textField
{
    NSParameterAssert(textField == self.textField);
    id<UITextFieldDelegate> secondary = self.savedTextViewDelegate;

    [self updateOriginalTextBeforeEditing];
    [self responderDidActivate:self.textField];

    if ([secondary respondsToSelector:@selector(textFieldDidBeginEditing:)])
    {
        [secondary textFieldDidBeginEditing:textField];
    }
}

- (BOOL)                             textFieldShouldReturn:(UITextField*)textField
{
    NSParameterAssert(textField == self.textField);
    id<UITextFieldDelegate> secondary = self.savedTextViewDelegate;

    BOOL result = YES;

    if ([secondary respondsToSelector:@selector(textFieldShouldReturn:)])
    {
        result = [secondary textFieldShouldReturn:self.textField];
    }

    if (result)
    {
        result = NO;
        switch (textField.returnKeyType)
        {
        case UIReturnKeyNext:
        {
            id<AKAKeyboardControlViewBindingDelegate> delegate = self.delegate;

            if ([self shouldDeactivate] && [delegate respondsToSelector:@selector(binding:responderRequestedActivateNext:)])
            {
                if (![delegate binding:self responderRequestedActivateNext:self.textField])
                {
                    [self deactivateResponder];
                }
            }
            break;
        }

        case UIReturnKeyGo:
        case UIReturnKeyDone:
        {
            id<AKAKeyboardControlViewBindingDelegate> delegate = self.delegate;

            if ([self shouldDeactivate] && [delegate respondsToSelector:@selector(binding:responderRequestedGoOrDone:)])
            {
                if (![delegate binding:self responderRequestedGoOrDone:self.textField])
                {
                    [self deactivateResponder];
                }
            }
            break;
        }

        default:
            // This will call the corresponding should/did end editing handlers
            [self deactivateResponder];
            break;
        }
    }

    return result;
}

- (BOOL)                              textFieldShouldClear:(UITextField*)textField
{
    NSParameterAssert(textField == self.textField);
    id<UITextFieldDelegate> secondary = self.savedTextViewDelegate;

    BOOL result = YES;

    if ([secondary respondsToSelector:@selector(textFieldShouldClear:)])
    {
        result = [secondary textFieldShouldClear:self.textField];
    }

    if (result && !self.textField.isFirstResponder)
    {
        // If the control should not activate, it should also not change its value
        // TODO: this might not always be true, consider to make this behaviour customizable.
        result = self.shouldActivate;

        if (result)
        {
            // This is needed to update self.originalText, which is updated when the text
            // field begins editing, which it did not if it's not active.
            [self updateOriginalTextBeforeEditing];
        }
    }

    if (result)
    {
        NSRange range = NSMakeRange(0, textField.text.length);
        result = [self                textField:textField
                  shouldChangeCharactersInRange:range
                              replacementString:@""];
    }

    return result;
}

- (BOOL)                                         textField:(UITextField*)textField
                             shouldChangeCharactersInRange:(NSRange)range
                                         replacementString:(NSString*)string
{
    NSParameterAssert(textField == self.textField);
    id<UITextFieldDelegate> secondary = self.savedTextViewDelegate;

    BOOL result = YES;

    if ([secondary respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
    {
        result = [secondary           textField:textField
                  shouldChangeCharactersInRange:range
                              replacementString:string];
    }

    return result;
}

- (void)                                textFieldDidChange:(UITextField*)textField
{
    (void)textField;
    NSParameterAssert(textField == self.textField);

    if (self.liveModelUpdates)
    {
        [self viewValueDidChange];
    }
}

- (BOOL)                         textFieldShouldEndEditing:(UITextField*)textField
{
    NSParameterAssert(textField == self.textField);
    id<UITextFieldDelegate> secondary = self.savedTextViewDelegate;

    BOOL result = YES;

    if ([secondary respondsToSelector:@selector(textFieldShouldEndEditing:)])
    {
        result &= [secondary textFieldShouldEndEditing:textField];
    }
    result &= [self shouldDeactivate];

    return result;
}

- (void)                            textFieldDidEndEditing:(UITextField*)textField
{
    id<UITextFieldDelegate> secondary = self.savedTextViewDelegate;

    NSParameterAssert(textField == self.textField);

    // Call delegate first to give it a change to change the value
    if ([secondary respondsToSelector:@selector(textFieldDidEndEditing:)])
    {
        [secondary textFieldDidEndEditing:textField];
    }

    if (!self.liveModelUpdates)
    {
        [self viewValueDidChange];
    }
    [self responderDidDeactivate:textField];
}

#pragma mark - Change Observation

- (void)                   updateOriginalTextBeforeEditing
{
    self.originalText = self.textField.text;
}

- (void)                                viewValueDidChange
{
    NSString* oldValue = self.originalText;
    NSString* newValue = self.textField.text;

    // Send change notification
    if (newValue != oldValue && ![newValue isEqualToString:oldValue])
    {
        [self targetValueDidChangeFromOldValue:oldValue toNewValue:newValue];
        newValue = self.textField.text; // the delegate may change the value
    }

    if (newValue != oldValue && ![newValue isEqualToString:oldValue])
    {
        [self.bindingTarget notifyPropertyValueDidChangeFrom:oldValue to:newValue];
        self.originalText = newValue;
    }
}

#pragma mark - Keyboard Activation Sequence

- (BOOL)     shouldParticipateInKeyboardActivationSequence
{
    BOOL result = ([super shouldParticipateInKeyboardActivationSequence] &&
                   self.supportsActivation);

    return result;
}

- (void)setResponderInputAccessoryView:(UIView*)responderInputAccessoryView
{
    self.textField.inputAccessoryView = responderInputAccessoryView;
}

#pragma mark - Obsolete (probably) Activation

- (BOOL)                                supportsActivation
{
    BOOL result = self.textField != nil;

    return result;
}

- (BOOL)                                shouldAutoActivate
{
    BOOL result = self.supportsActivation && self.autoActivate;

    return result;
}

#pragma mark - Obsolete (probably) Delegate Support Methods

- (BOOL)                                    shouldActivate
{
    return YES;
}

- (BOOL)                                  shouldDeactivate
{
    return YES;
}

@end
