//
//  AKABinding_UITextField_textBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABinding_UITextField_textBinding.h"
#import "AKABindingErrors.h"

#import "AKABinding_AKABinding_formatter.h"
#import "AKABinding_AKABinding_numberFormatter.h"
#import "AKABinding_AKABinding_dateFormatter.h"

#pragma mark - AKABinding_UITextField_textBinding - Private Interface
#pragma mark -

@interface AKABinding_UITextField_textBinding () <UITextFieldDelegate>

#pragma mark - Saved UITextField State

#if RESTORE_BOUND_VIEW_STATE
@property(nonatomic, nullable) NSString*                   originalPlaceholder;
@property(nonatomic, nullable) NSString*                   originalText;
#endif
@property(nonatomic, weak) id<UITextFieldDelegate>         savedTextViewDelegate;
@property(nonatomic, nullable) NSString*                   previousText;
@property(nonatomic) BOOL useEditingFormat;

#pragma mark - Convenience

@property(nonatomic, readonly) UITextField*                textField;

@end


#pragma mark - AKABinding_UITextField_textBinding - Implementation
#pragma mark -

@implementation AKABinding_UITextField_textBinding


+ (AKABindingSpecification*)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        // see specification defined in AKAKeyboardControlViewBindingProvider:
        NSDictionary* spec = @{
            @"bindingType":          [AKABinding_UITextField_textBinding class],
            @"targetType":           [UITextField class],
            @"expressionType":       @(AKABindingExpressionTypeAny),
            @"attributes": @{
                @"numberFormatter": @{
                    @"bindingType":         [AKABinding_AKABinding_numberFormatter class],
                    @"use":                 @(AKABindingAttributeUseBindToBindingProperty),
                    @"bindingProperty":     @"formatter"
                },
                @"dateFormatter": @{
                    @"bindingType":         [AKABinding_AKABinding_dateFormatter class],
                    @"use":                 @(AKABindingAttributeUseBindToBindingProperty),
                    @"bindingProperty":     @"formatter"
                },
                @"formatter": @{
                    @"bindingType":         [AKABinding_AKABinding_formatter class],
                    @"use":                 @(AKABindingAttributeUseBindToBindingProperty),
                    @"bindingProperty":     @"formatter"
                },
                @"editingNumberFormatter": @{
                    @"bindingType":         [AKABinding_AKABinding_numberFormatter class],
                    @"use":                 @(AKABindingAttributeUseBindToBindingProperty),
                    @"bindingProperty":     @"editingFormatter"
                },
                @"editingDateFormatter": @{
                    @"bindingType":         [AKABinding_AKABinding_dateFormatter class],
                    @"use":                 @(AKABindingAttributeUseBindToBindingProperty),
                    @"bindingProperty":     @"editingFormatter"
                },
                @"editingFormatter": @{
                    @"bindingType":         [AKABinding_AKABinding_formatter class],
                    @"use":                 @(AKABindingAttributeUseBindToBindingProperty),
                    @"bindingProperty":     @"editingFormatter"
                },
                @"textForUndefinedValue": @{
                    @"expressionType":      @(AKABindingExpressionTypeString),
                    @"use":                 @(AKABindingAttributeUseAssignValueToBindingProperty),
                    @"bindingProperty":     @"textForUndefinedValue"
                },
                @"treatEmptyTextAsUndefined": @{
                    @"expressionType":      @(AKABindingExpressionTypeBoolean),
                    @"use":                 @(AKABindingAttributeUseAssignValueToBindingProperty),
                    @"bindingProperty":     @"treatEmptyTextAsUndefined"
                }
            }
        };

        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

#pragma mark - Initialization

- (void)validateTargetView:(req_UIView)targetView
{
    NSParameterAssert([targetView isKindOfClass:[UITextField class]]);
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
                else if ([value isKindOfClass:[NSString class]])
                {
                    binding.textField.text = value;
                }
                else
                {
                    binding.textField.text = [NSString stringWithFormat:@"%@", value];
                }

                // A programmatic change resets edits and thus needs to be reflected in previousText
                self.previousText = binding.textField.text;
            }
            observationStarter:
            ^BOOL (id target)
            {
                AKABinding_UITextField_textBinding* binding = target;
                UITextField* textField = binding.textField;
                id<UITextFieldDelegate> textFieldDelegate = textField.delegate;

                if (textFieldDelegate != binding)
                {

#if RESTORE_BOUND_VIEW_STATE
                    binding.originalText = binding.textField.text;
                    binding.originalPlaceholder = textField.placeholder;
#endif
                    binding.previousText = nil;
                    textField.placeholder = binding.textForUndefinedValue;

                    // Format text for editing and save the result as previousText
                    // representing the target value for the current source value.
                    BOOL wasEditing = binding.useEditingFormat;

                    if (!wasEditing)
                    {
                        binding.useEditingFormat = YES;
                        [binding updateTargetValue];
                    }
                    binding.previousText = binding.textField.text;

                    // Render text for display
                    if (!wasEditing)
                    {
                        binding.useEditingFormat = NO;
                        [binding updateTargetValue];
                    }

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
                id<UITextFieldDelegate> textFieldDelegate = textField.delegate;

                if (textFieldDelegate == binding)
                {
                    [textField removeTarget:target
                                     action:@selector(textFieldDidChange:)
                           forControlEvents:UIControlEventEditingChanged];

                    textField.delegate = binding.savedTextViewDelegate;

#if RESTORE_BOUND_VIEW_STATE
                    textField.text = binding.originalText;
                    binding.originalText = nil;
                    textField.placeholder = binding.originalPlaceholder;
                    binding.originalPlaceholder = nil;
#endif
                    binding.previousText = nil;

                }

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

#pragma mark -

- (BOOL)                                convertTargetValue:(opt_id)targetValue
                                             toSourceValue:(out_id)sourceValueStore
                                                     error:(out_NSError)error
{
    BOOL result = NO;

    if (targetValue)
    {
        NSString* errorDescription = nil;
        NSFormatter* formatter = nil;

        if (self.useEditingFormat && self.editingFormatter)
        {
            formatter = self.editingFormatter;
            result = [formatter getObjectValue:sourceValueStore
                                     forString:(req_id)targetValue
                              errorDescription:&errorDescription];
        }
        else if (self.formatter)
        {
            formatter = self.formatter;
            result = [formatter getObjectValue:sourceValueStore
                                     forString:(req_id)targetValue
                              errorDescription:&errorDescription];
        }
        else
        {
            result = [super convertTargetValue:targetValue
                                 toSourceValue:sourceValueStore
                                         error:error];
        }

        if (!result && formatter && error)
        {
            *error = [AKABindingErrors bindingErrorConversionOfBinding:self
                                                           targetValue:targetValue
                                                        usingFormatter:(req_NSFormatter)self.formatter
                                                     failedWithMessage:errorDescription];
        }
    }
    else
    {
        result = [super convertTargetValue:targetValue
                             toSourceValue:sourceValueStore
                                     error:error];
    }

    return result;
}

- (BOOL)                                convertSourceValue:(opt_id)sourceValue
                                             toTargetValue:(out_id)targetValueStore
                                                     error:(out_NSError)error
{
    BOOL result = NO;

    id effectiveSourceValue = sourceValue;

    if (self.treatEmptyTextAsUndefined && [effectiveSourceValue isKindOfClass:[NSString class]])
    {
        NSString* text = (NSString*)effectiveSourceValue;

        // TODO: the disabled behavior below is more robust, but maybe not expected, consider adding
        // another configuration item or enabling this:
        //text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        if (text.length == 0)
        {
            effectiveSourceValue = nil;
        }
    }

    if (effectiveSourceValue)
    {
        NSString* errorDescription = nil;
        NSFormatter* formatter = nil;
        NSString* text = nil;

        if (self.useEditingFormat && self.editingFormatter)
        {
            formatter = self.editingFormatter;
            text = [formatter stringForObjectValue:(req_id)effectiveSourceValue];
            result = text != nil;
        }
        else if (self.formatter)
        {
            formatter = self.formatter;

            if (self.useEditingFormat)
            {
                text = [formatter editingStringForObjectValue:(req_id)effectiveSourceValue];
                result = text != nil;
            }
            else
            {
                text = [self.formatter stringForObjectValue:(req_id)effectiveSourceValue];
                result = text != nil;
            }
        }
        else
        {
            result = [super convertSourceValue:effectiveSourceValue
                                 toTargetValue:targetValueStore
                                         error:error];
        }

        if (formatter)
        {
            if (result)
            {
                *targetValueStore = text;
            }
            else if (error)
            {
                *error = [AKABindingErrors bindingErrorConversionOfBinding:self
                                                               sourceValue:effectiveSourceValue
                                                            usingFormatter:(req_NSFormatter)formatter
                                                         failedWithMessage:errorDescription];
            }
        }
    }
    else
    {
        result = [super convertSourceValue:effectiveSourceValue
                             toTargetValue:targetValueStore
                                     error:error];
    }

    return result;
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

    self.useEditingFormat = YES;

    if (self.liveModelUpdates || self.textField.text.length > 0 || self.textField.clearButtonMode == UITextFieldViewModeNever)
    {
        // update unless the current state may be the result of a clear button press, in which case
        // the update would undo the clear action.
        [self updateTargetValue];
    }

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

    [self viewValueDidChange];
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

    // Call delegate first to give it a chance to change the value
    if ([secondary respondsToSelector:@selector(textFieldDidEndEditing:)])
    {
        [secondary textFieldDidEndEditing:textField];
    }

    // Update source
    [self viewValueDidChange];

    // Notify delegates
    [self responderDidDeactivate:textField];

    // Rerender text in display format
    self.useEditingFormat = NO;
    [self updateTargetValue];
}

#pragma mark - Change Observation

- (void)                                viewValueDidChange
{
    NSString* oldValue = self.previousText;
    NSString* newValue = self.textField.text;

    if (self.liveModelUpdates || !self.textField.isFirstResponder)
    {
        // Send change notification
        if (newValue != oldValue && ![newValue isEqualToString:oldValue])
        {
            [self targetValueDidChangeFromOldValue:oldValue toNewValue:newValue];
            newValue = self.textField.text; // the delegate may change the value
        }

        if (newValue != oldValue && ![newValue isEqualToString:oldValue])
        {
            [self.bindingTarget notifyPropertyValueDidChangeFrom:oldValue to:newValue];
            self.previousText = newValue;
        }
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
