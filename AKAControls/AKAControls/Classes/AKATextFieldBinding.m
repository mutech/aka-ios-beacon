//
//  AKATextFieldControlViewBinding.m
//  AKAControls
//
//  Created by Michael Utech on 18.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATextFieldBinding.h"
#import "AKATextField.h"
#import "AKAKeyboardActivationSequence.h"

#import "AKAControl.h"
#import "AKAProperty.h"

#import <AKACommons/NSObject+AKAAssociatedValues.h>
#import <AKACommons/AKALog.h>

@interface AKATextFieldBinding() <UITextFieldDelegate> {
    NSString* _originalText;
    id<UITextFieldDelegate> _savedTextViewDelegate;
}

@property(nonatomic) NSString* originalText;
@property(nonatomic) NSNumber* originalReturnKeyType;

@property(nonatomic, weak) id<UITextFieldDelegate> savedTextViewDelegate;

#pragma mark - Convenience

@property(nonatomic, readonly) UITextField* textField;
@property(nonatomic, readonly) AKATextFieldBindingConfiguration* textFieldConfiguration;

@end

@implementation AKATextFieldBinding

#pragma mark - Binding Configuration

- (AKATextFieldBindingConfiguration *)textFieldConfiguration
{
    return (AKATextFieldBindingConfiguration*)self.configuration;
}

#pragma mark - View Value Binding

- (AKAProperty *)createViewValueProperty;
{
    AKAProperty* result;
    result = [AKAProperty propertyOfWeakTarget:self
                                      getter:
              ^id (id target)
              {
                  AKATextFieldBinding* binding = target;
                  return binding.textField.text;
              }
                                      setter:
              ^(id target, id value)
              {
                  AKATextFieldBinding* adapter = target;
                  if (value == nil || [value isKindOfClass:[NSString class]])
                  {
                      adapter.textField.text = value;
                  }
                  else if (value != nil)
                  {
                      adapter.textField.text = [NSString stringWithFormat:@"%@", value];
                  }
              }
                          observationStarter:
              ^BOOL (id target)
              {
                  AKATextFieldBinding* binding = target;
                  if (binding.textField.delegate != binding)
                  {
                      binding.originalText = binding.textField.text;
                      binding.savedTextViewDelegate = binding.textField.delegate;
                      binding.textField.delegate = binding;
                      [binding.textField addTarget:binding
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
                  AKATextFieldBinding* binding = target;
                  [binding.textField removeTarget:target
                                           action:@selector(textDidChange:)
                                 forControlEvents:UIControlEventEditingChanged];
                  binding.textField.delegate = binding.savedTextViewDelegate;
                  binding.originalText = nil;
                  return YES;
              }];
    return result;
}

- (id<UITextFieldDelegate>)savedTextViewDelegate
{
    return _savedTextViewDelegate;
}

- (void)setSavedTextViewDelegate:(id<UITextFieldDelegate>)savedTextViewDelegate
{
    NSParameterAssert(savedTextViewDelegate != self);
    _savedTextViewDelegate = savedTextViewDelegate;
}

#pragma mark - Validation

- (BOOL)managesValidationStateForContext:(id)validationContext view:(UIView *)view
{
    return NO; //view == self.textField;
}

- (void)setValidationState:(NSError *)error
                   forView:(UIView *)view
         validationContext:(id)validationContext
{
    if (view == self.textField)
    {
        // Save and restore indicator attributes, best using themes or view customization:
        if (error == nil)
        {
            self.textField.textColor = [UIColor blackColor];
        }
        else
        {
            self.textField.textColor = [UIColor redColor];
        }
    }
}

#pragma mark - Convenience

- (UITextField *)textField
{
    UITextField* result = nil;
    if ([self.view isKindOfClass:[UITextField class]])
    {
        result = (UITextField*)self.view;
    }
    return result;
}

- (BOOL)liveModelUpdates
{
    return self.textFieldConfiguration.liveModelUpdates;
}

#pragma mark - Activation

- (BOOL)supportsActivation
{
    BOOL result = self.textField != nil;
    return result;
}

- (BOOL)shouldAutoActivate
{
    BOOL result = self.supportsActivation && self.textFieldConfiguration.autoActivate;
    return result;
}

- (BOOL)participatesInKeyboardActivationSequence
{
    BOOL result = self.supportsActivation && self.textFieldConfiguration.KBActivationSequence;
    return result;
}

- (void)setupKeyboardActivationSequenceWithPredecessor:(UIView*)previous
                                             successor:(UIView*)next
{
    // TODO: support keyboard toolbar to add previous/next buttons for keyboards not
    // supporting them and maybe always provide close keyboard button.
    UITextField* textField = self.textField;
    if (textField != nil)
    {
        //AKALogDebug(@"Setting up return style for %@ in sequence (%p-%p-%p)", textField, previous.view, textField, next.view);

        // TODO: save properties in this object (not text field) and also restore on dealloc
        if (next != nil)
        {
            if (self.originalReturnKeyType == nil)
            {
                self.originalReturnKeyType = @(textField.returnKeyType);
            }
            textField.returnKeyType = UIReturnKeyNext;
            //AKALogDebug(@"Set return key type of %@ to %@ (%@)", textField, @(UIReturnKeyNext), @(textField.returnKeyType));
        }
        else
        {
            if (self.originalReturnKeyType != nil)
            {
                textField.returnKeyType = self.originalReturnKeyType.unsignedIntegerValue;
                //AKALogDebug(@"Restored return key type of %@ to %@ (%@)", textField, self.originalReturnKeyType, @(textField.returnKeyType));
                self.originalReturnKeyType = nil;
            }
        }
    }
}

- (BOOL)activate
{
    UITextField* textField = self.textField;
    BOOL result = textField != nil;
    if (result)
    {
        [self viewWillActivate];
        result = [textField becomeFirstResponder];
    }
    return result;
}

- (BOOL)deactivate
{
    UITextField* textField = self.textField;
    BOOL result = textField != nil;
    if (result)
    {
        [self viewWillDeactivate];
        result = [textField resignFirstResponder];
    }
    return result;
}

#pragma mark - UITextFieldDelegate Implementation

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSParameterAssert(textField == self.textField);
    id<UITextFieldDelegate> secondary = self.savedTextViewDelegate;

    [self updateOriginalTextBeforeEditing];
    [self viewDidActivate];
    if ([secondary respondsToSelector:@selector(textFieldDidBeginEditing:)])
    {
        [secondary textFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
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
                if ([self shouldDeactivate])
                {
                    if (![self.delegate.keyboardActivationSequence activateNext])
                    {
                        [self deactivate];
                    }
                }
                break;

            case UIReturnKeyGo:
            case UIReturnKeyDone:
                // TODO: check if committing the form is appropriate for these return key styles.
            default:
                // This will call the corresponding should/did end editing handlers
                [self deactivate];
                break;
        }
    }
    return result;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
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
        result = [self            textField:textField
              shouldChangeCharactersInRange:range
                          replacementString:@""];
    }
    return result;
}

- (BOOL)               textField:(UITextField *)textField
   shouldChangeCharactersInRange:(NSRange)range
               replacementString:(NSString *)string
{
    NSParameterAssert(textField == self.textField);
    id<UITextFieldDelegate> secondary = self.savedTextViewDelegate;

    BOOL result = YES;
    if ([secondary respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
    {
        result = [secondary textField:textField
        shouldChangeCharactersInRange:range
                    replacementString:string];
    }
    return result;

    /*
    if (result && self.liveModelUpdates)
    {
        // Simulate a didChange event by performing the change
        // manually and returning NO here.
        NSString* newText = [textField.text
                             stringByReplacingCharactersInRange:range
                             withString:string];
        textField.text = newText;
        [self textField:textField didChangeCharactersInRange:range replacementString:string];

        // Correct cursor position:
        UITextPosition *start = [textField positionFromPosition:[textField beginningOfDocument]
                                                         offset:(NSInteger)(range.location + string.length)];
        UITextPosition *end = [textField positionFromPosition:start
                                                       offset:0];
        [textField setSelectedTextRange:[textField textRangeFromPosition:start toPosition:end]];

        result = NO;
    }
    return result;
     */
}

- (void)textFieldDidChange:(UITextField*)textField
{
    if (self.liveModelUpdates)
    {
        [self viewValueDidChange];
    }
}

/*
- (void)                textField:(UITextField*)textField
       didChangeCharactersInRange:(NSRange)range
                replacementString:(NSString*)string
{
    NSParameterAssert(textField == self.textField);
    (void)range; // not used
    (void)string; // not used

    if (self.liveModelUpdates)
    {
        [self viewValueDidChange];
    }
}
*/

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
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

- (void)textFieldDidEndEditing:(UITextField *)textField
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
    [self viewDidDeactivate];
}

- (void)updateOriginalTextBeforeEditing
{
    NSString* previousValue = self.originalText;

    self.originalText = self.textField.text;
    if (previousValue != nil && ![previousValue isEqualToString:self.originalText])
    {
        // Value has been changed without us noticing; TODO: check if we have to do something
    }
}

- (void)viewValueDidChange
{
    NSString* oldValue = self.originalText;
    NSString* newValue = self.textField.text;

    // Send change notification
    if (newValue != oldValue && ![newValue isEqualToString:oldValue])
    {
        [self viewValueDidChangeFrom:oldValue to:newValue];
        newValue = self.textField.text; // the delegate may change the value
    }

    if (newValue != oldValue && ![newValue isEqualToString:oldValue])
    {
        [self.viewValueProperty notifyPropertyValueDidChangeFrom:oldValue to:newValue];
        self.originalText = newValue;
    }
}

@end

@implementation AKATextFieldBindingConfiguration

- (Class)preferredBindingType
{
    return [AKATextFieldBinding class];
}

- (Class)preferredViewType
{
    return [AKATextField class];
}

@end
