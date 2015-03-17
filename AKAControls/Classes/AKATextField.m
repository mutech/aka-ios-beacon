//
//  AKATextField.m
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATextField.h"
#import "AKAControlViewBinding_Protected.h"
#import "AKAControl.h"
#import "AKAProperty.h"

@interface AKATextFieldControlViewBinding: AKAControlViewBinding<
    UITextFieldDelegate
>

#pragma mark - State

@property(nonatomic, weak) id<UITextFieldDelegate> savedTextViewDelegate;

@property(nonatomic) NSString* originalText;

#pragma mark - Convenience

@property(nonatomic, readonly) AKATextField* textField;

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


#pragma mark - Convenience

- (AKATextField *)textField
{
    return (AKATextField*)self.view;
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
                if ([self controlViewShouldActivateNextControl:self.textField])
                {
                    [self controlViewRequestsActivateNextControl:self.textField];
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

    if (result && self.textField.liveModelUpdates)
    {
        // Simulate a changed event by performing the change
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

    if (self.textField.liveModelUpdates)
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
    if (!self.textField.liveModelUpdates)
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


@interface AKATextField() {
    AKATextFieldControlViewBinding* _controlBinding;
    NSString* _valueKeyPath;
}
@end

@implementation AKATextField

- (NSString *)valueKeyPath { return _valueKeyPath; }
- (void)setValueKeyPath:(NSString *)valueKeyPath { _valueKeyPath = valueKeyPath; }

- (AKAControlViewBinding *)bindToControl:(AKAControl *)control
{
    AKATextFieldControlViewBinding* result;
    AKAControlViewBinding* controlViewBinding = self.controlBinding;

    if (controlViewBinding != nil)
    {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"Invalid attempt to bind %@ to %@: Already bound: %@", self, control, controlViewBinding]
                                     userInfo:nil];
    }
    _controlBinding = result =
        [[AKATextFieldControlViewBinding alloc] initWithControl:control
                                                           view:self];
    return result;
}

- (AKAControl*)createControlWithDataContext:(id)dataContext
{
    AKAControl* result = [AKAControl controlWithDataContext:dataContext keyPath:self.valueKeyPath];
    result.viewBinding = [self bindToControl:result];
    return result;
}

- (AKAControl*)createControlWithOwner:(AKACompositeControl *)owner
{
    AKAControl* result = [AKAControl controlWithOwner:owner keyPath:self.valueKeyPath];
    result.viewBinding = [self bindToControl:result];
    return result;
}

- (AKAControlViewBinding *)controlBinding
{
    return _controlBinding;
}

@end
