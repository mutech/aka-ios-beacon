//
//  AKATextFieldControlViewBinding.m
//  AKAControls
//
//  Created by Michael Utech on 18.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATextFieldControlViewBinding.h"
#import "AKAControlViewBinding_Protected.h"
#import "AKATextField.h"

#import "AKAControl.h"
#import "AKAProperty.h"

#import <AKACommons/NSObject+AKAAssociatedValues.h>
#import <AKACommons/AKALog.h>

@interface AKATextFieldControlViewBinding(Protected)<UITextFieldDelegate>

@property(nonatomic, weak) id<UITextFieldDelegate> savedTextViewDelegate;

@end

@interface AKATextFieldControlViewBinding() {
    NSString* _originalText;
    id<UITextFieldDelegate> _savedTextViewDelegate;
}
@property(nonatomic) NSString* originalText;
@property(nonatomic) NSNumber* originalReturnKeyType;

@end

@implementation AKATextFieldControlViewBinding

#pragma mark - View Value Binding

- (AKAProperty *)createViewValueProperty
{
    AKAProperty* result;
    result = [AKAProperty propertyWithGetter:^id {
        return self.textField.text;
    } setter:^(id value) {
        if ([value isKindOfClass:[NSString class]])
        {
            self.textField.text = value;
        }
        else
        {
            self.textField.text = [NSString stringWithFormat:@"%@", value];
        }
    } observationStarter:^BOOL () {
        self.originalText = self.textField.text;
        self.savedTextViewDelegate = self.textField.delegate;
        self.textField.delegate = self;
        return YES;
    } observationStopper:^BOOL {
        self.originalText = nil;
        self.textField.delegate = self.savedTextViewDelegate;
        return YES;
    }];
    return result;
}

- (id<UITextFieldDelegate>)savedTextViewDelegate { return _savedTextViewDelegate; }
- (void)setSavedTextViewDelegate:(id<UITextFieldDelegate>)savedTextViewDelegate { _savedTextViewDelegate = savedTextViewDelegate; }

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

- (AKATextField*)akaTextField
{
    AKATextField* result = nil;
    if ([self.view isKindOfClass:[AKATextField class]])
    {
        result = (AKATextField*)self.view;
    }
    return result;
}

- (BOOL)liveModelUpdates
{
    BOOL result;
    AKATextField* akaTextField = self.akaTextField;
    if (akaTextField)
    {
        result = akaTextField.liveModelUpdates;
    }
    else
    {
        result = YES;
    }
    return result;
}

#pragma mark - Activation

- (BOOL)controlViewCanActivate
{
    return self.textField != nil;
}

- (BOOL)shouldAutoActivate
{
    BOOL result = self.controlViewCanActivate;
    AKATextField* akaTextField = self.akaTextField;
    if (akaTextField)
    {
        result = akaTextField.autoActivate;
    }
    return result;
}

- (BOOL)participatesInKeyboardActivationSequence
{
    BOOL result = self.controlViewCanActivate;
    if (result)
    {
        AKATextField* akaTextField = self.akaTextField;
        if (akaTextField)
        {
            result = akaTextField.KBActivationSequence;
        }
    }
    return result;
}

- (void)setupKeyboardActivationSequenceWithPredecessor:(AKAControl*)previous
                                             successor:(AKAControl*)next
{
    // TODO: support keyboard toolbar to add previous/next buttons for keyboards not
    // supporting them and maybe always provide close keyboard button.
    UITextField* textField = self.textField;
    if (textField != nil)
    {
        AKALogDebug(@"Setting up return style for %@ in sequence (%p-%p-%p)", textField, previous.view, textField, next.view);

        // TODO: save properties in this object (not text field) and also restore on dealloc
        if (next != nil)
        {
            if (self.originalReturnKeyType == nil)
            {
                self.originalReturnKeyType = @(textField.returnKeyType);
            }
            textField.returnKeyType = UIReturnKeyNext;
            AKALogDebug(@"Set return key type of %@ to %@ (%@)", textField, @(UIReturnKeyNext), @(textField.returnKeyType));
        }
        else
        {
            if (self.originalReturnKeyType != nil)
            {
                textField.returnKeyType = self.originalReturnKeyType.unsignedIntegerValue;
                AKALogDebug(@"Restored return key type of %@ to %@ (%@)", textField, self.originalReturnKeyType, @(textField.returnKeyType));
                self.originalReturnKeyType = nil;
            }
        }
    }
}


- (BOOL)activateControlView
{
    UITextField* textField = self.textField;
    BOOL result = textField != nil;
    if (result)
    {
        result = [textField becomeFirstResponder];
    }
    return result;
}

- (BOOL)deactivateControlView
{
    UITextField* textField = self.textField;
    BOOL result = textField != nil;
    if (result)
    {
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
        result = [self controlViewShouldActivate:self.textField];
    }
    return result;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSParameterAssert(textField == self.textField);
    id<UITextFieldDelegate> secondary = self.savedTextViewDelegate;

    [self updateOriginalTextBeforeEditing];
    [self controlViewDidActivate:self.textField];
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
                if ([self.control shouldDeactivate])
                {
                    AKAControl* next = [self.control nextControlInKeyboardActivationSequence];
                    if ([next shouldActivate])
                    {
                        [next activate];
                    }
                }
                break;

            case UIReturnKeyGo:
            case UIReturnKeyDone:
                // TODO: check if committing the form is appropriate for these return key styles.
            default:
                // This will call the corresponding should/did end editing handlers
                [textField resignFirstResponder];
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
    if (result && !self.control.isActive)
    {
        // If the control should not activate, it should also not change its value
        // TODO: this might not always be true, consider to make this behaviour customizable.
        result = self.control.shouldActivate;
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
}

- (void)                textField:(UITextField*)textField
       didChangeCharactersInRange:(NSRange)range
                replacementString:(NSString*)string
{
    NSParameterAssert(textField == self.textField);
    (void)range; // not used
    (void)string; // not used

    if (self.liveModelUpdates)
    {
        [self viewValueDidChangeFrom:self.originalText to:self.textField.text];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSParameterAssert(textField == self.textField);
    id<UITextFieldDelegate> secondary = self.savedTextViewDelegate;

    BOOL result = YES;
    if ([secondary respondsToSelector:@selector(textFieldShouldEndEditing:)])
    {
        result &= [secondary textFieldShouldEndEditing:textField];
    }
    result &= [self controlViewShouldDeactivate:self.textField];
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
        [self viewValueDidChangeFrom:self.originalText to:self.textField.text];
    }
    [self controlViewDidDeactivate:self.textField];
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

- (void)viewValueDidChangeFrom:(id)oldValue to:(id)newValue
{
    (void)oldValue; // prefer live values
    (void)newValue; // prefer live values

    NSString* previousValue = self.originalText;
    NSString* value = self.textField.text;

    // Send change notification
    if (value != previousValue && ![value isEqualToString:previousValue])
    {
        [self           controlView:self.textField
          didChangeValueChangedFrom:previousValue
                                 to:value];
        value = self.textField.text; // update just in case handler did change the value
    }
    [self.viewValueProperty notifyPropertyValueDidChangeFrom:previousValue to:value];
    self.originalText = self.textField.text;
}

@end

