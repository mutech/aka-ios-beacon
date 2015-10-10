//
//  AKASingleChoiceEditorControlView.m
//  AKAControls
//
//  Created by Michael Utech on 14.09.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKASingleChoiceEditorControlView.h"
#import "AKATextLabel.h"
#import "AKAPickerView.h"

#import "UIView+AKABinding.h"
#import "AKACompositeControl.h"

@interface AKASingleChoiceEditorControlView() <UIKeyInput>

@property(nonatomic, readonly) AKASingleChoiceEditorBindingConfiguration* bindingConfiguration;
- (AKASingleChoiceEditorBindingConfiguration *)createBindingConfiguration;

@property(nonatomic, readonly, strong) AKAPickerView* pickerView;

@end

@implementation AKASingleChoiceEditorControlView

- (BOOL)autocreateEditor:(out UIView *__autoreleasing *)createdView
{
    AKATextLabel* editor = [[AKATextLabel alloc] initWithFrame:CGRectZero];
    BOOL result = editor != nil;

    if (result)
    {
        editor.valueKeyPath = self.valueKeyPath;

        *createdView = editor;
    }

    return result;
}

#pragma mark - Configuration

- (AKASingleChoiceEditorBindingConfiguration *)bindingConfiguration
{
    return (AKASingleChoiceEditorBindingConfiguration*)super.bindingConfiguration;
}

- (AKASingleChoiceEditorBindingConfiguration *)createBindingConfiguration
{
    AKASingleChoiceEditorBindingConfiguration* result = AKASingleChoiceEditorBindingConfiguration.new;

    result.autoActivate = YES;
    result.KBActivationSequence = YES;

    return result;
}

- (void)setupDefaultValues
{
    [super setupDefaultValues];
}

#pragma mark - Interface Builder Properties

- (NSString *)pickerValuesKeyPath { return self.bindingConfiguration.pickerValuesKeyPath; }
- (void)setPickerValuesKeyPath:(NSString *)pickerValuesKeyPath { self.bindingConfiguration.pickerValuesKeyPath = pickerValuesKeyPath; }

- (NSString *)titleKeyPath { return self.bindingConfiguration.titleKeyPath; }
- (void)setTitleKeyPath:(NSString *)titleKeyPath { self.bindingConfiguration.titleKeyPath = titleKeyPath; }

- (NSString *)titleConverterKeyPath { return self.bindingConfiguration.titleConverterKeyPath; }
- (void)setTitleConverterKeyPath:(NSString *)titleConverterKeyPath { self.bindingConfiguration.titleConverterKeyPath = titleConverterKeyPath; }

- (NSString *)otherValueTitle { return self.bindingConfiguration.otherValueTitle; }
- (void)setOtherValueTitle:(NSString *)otherValueTitle { self.bindingConfiguration.otherValueTitle = otherValueTitle; }

- (NSString *)undefinedValueTitle { return self.bindingConfiguration.undefinedValueTitle; }
- (void)setUndefinedValueTitle:(NSString *)undefinedValueTitle { self.bindingConfiguration.undefinedValueTitle = undefinedValueTitle; }

- (BOOL)autoActivate { return self.bindingConfiguration.autoActivate; }
- (void)setAutoActivate:(BOOL)autoActivate { self.bindingConfiguration.autoActivate = autoActivate; }

- (BOOL)KBActivationSequence { return self.bindingConfiguration.KBActivationSequence; }
- (void)setKBActivationSequence:(BOOL)KBActivationSequence { self.bindingConfiguration.KBActivationSequence = KBActivationSequence; }

#pragma mark - Picker Keyboard
#pragma mark -

@synthesize pickerView = _pickerView;
- (AKAPickerView *)pickerView
{
    if (_pickerView == nil)
    {
        _pickerView = [[AKAPickerView alloc] initWithFrame:CGRectZero];
        _pickerView.valueKeyPath = self.editorKeyPath;
        _pickerView.converterKeyPath = self.converterKeyPath;
        _pickerView.validatorKeyPath = self.validatorKeyPath;
        
        _pickerView.pickerValuesKeyPath = self.pickerValuesKeyPath;
        _pickerView.titleKeyPath = self.titleKeyPath;
        _pickerView.titleConverterKeyPath = self.titleConverterKeyPath;
        _pickerView.otherValueTitle = self.otherValueTitle;
        _pickerView.undefinedValueTitle = self.undefinedValueTitle;

        _pickerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        AKAObsoleteViewBinding * binding = self.aka_binding;
        NSAssert(binding != nil, @"TODO: may need defered initialization here");
        if (binding != nil)
        {
            id control = binding.delegate;
            NSAssert([control isKindOfClass:[AKACompositeControl class]], @"Need a composite control to initialize picker keyboard control");
            if ([control isKindOfClass:[AKACompositeControl class]])
            {
                AKACompositeControl* composite = control;
                AKAControl* control = [composite createControlForView:_pickerView withConfiguration:_pickerView.bindingConfiguration];
                [composite addControl:control];
                if (composite.isObservingChanges)
                {
                    [control startObservingChanges];
                }
            }
        }
    }
    return _pickerView;
}

#pragma mark - Keyboard Support

- (BOOL)canBecomeFirstResponder
{
    return !self.readOnly && self.pickerValuesKeyPath.length > 0;
}

- (BOOL)becomeFirstResponder
{
    [self.aka_binding viewWillActivate];
    BOOL result = [super becomeFirstResponder];
    if (result)
    {
        [self.aka_binding viewDidActivate];
    }
    return result;
}

- (BOOL)resignFirstResponder
{
    [self.aka_binding viewWillDeactivate];
    BOOL result = [super resignFirstResponder];
    if (result)
    {
        [self.aka_binding viewDidDeactivate];
    }
    return result;
}

- (UIView *)inputView
{
    return self.pickerView;
}

@synthesize inputAccessoryView = _inputAccessoryView;
- (UIView *)inputAccessoryView
{
    return _inputAccessoryView;
}
- (void)setInputAccessoryView:(UIView *)inputAccessoryView
{
    _inputAccessoryView = inputAccessoryView;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (self.canBecomeFirstResponder)
    {
        [self becomeFirstResponder];
    }
}

#pragma mark - Key Input Protocol Implementation

- (BOOL)hasText
{
    return YES;
}

- (void)insertText:(NSString *)text
{
}

- (void)deleteBackward
{
}

@end

@interface AKASingleChoiceEditorBinding()

@property(nonatomic, readonly) AKASingleChoiceEditorControlView* singleChoiceView;
@property(nonatomic, readonly) AKASingleChoiceEditorBindingConfiguration* configuration;

@end

@implementation AKASingleChoiceEditorBinding

#pragma mark - Configuration

- (AKASingleChoiceEditorBindingConfiguration *)configuration
{
    NSAssert([super.configuration isKindOfClass:[AKASingleChoiceEditorBindingConfiguration class]], nil);
    return (AKASingleChoiceEditorBindingConfiguration*)super.configuration;
}

#pragma mark - Convenience

- (AKASingleChoiceEditorControlView *)singleChoiceView
{
    AKASingleChoiceEditorControlView* result = nil;

    if ([self.view isKindOfClass:[AKASingleChoiceEditorControlView class]])
    {
        result = (id)self.view;
    }
    return result;
}

#pragma mark - Activation and Keyboard support

- (BOOL)supportsActivation
{
    BOOL result = self.singleChoiceView != nil;
    return result;
}

- (BOOL)shouldAutoActivate
{
    BOOL result = self.supportsActivation && self.configuration.autoActivate;
    return result;
}

- (BOOL)participatesInKeyboardActivationSequence
{
    BOOL result = self.supportsActivation && self.configuration.KBActivationSequence;
    return result;
}

- (void)setupKeyboardActivationSequenceWithPredecessor:(UIView*)previous
                                             successor:(UIView*)next
{
}

- (BOOL)activate
{
    BOOL result = self.view != nil;
    if (result)
    {
        // becomeFirstResponder will call viewWillActivate
        //[self viewWillActivate];
        result = [self.view becomeFirstResponder];
    }
    return result;
}

- (BOOL)deactivate
{
    BOOL result = self.view != nil;
    if (result)
    {
        // resignFirstResponder will call viewWillDeactivate
        //[self viewWillDeactivate];
        result = [self.view resignFirstResponder];
    }
    return result;
}

@end

@implementation AKASingleChoiceEditorBindingConfiguration

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.pickerValuesKeyPath = [aDecoder decodeObjectForKey:@"pickerValuesKeyPath"];
        self.titleKeyPath = [aDecoder decodeObjectForKey:@"titleKeyPath"];
        self.titleConverterKeyPath = [aDecoder decodeObjectForKey:@"titleConverterKeyPath"];
        self.otherValueTitle = [aDecoder decodeObjectForKey:@"otherValueTitle"];
        self.undefinedValueTitle = [aDecoder decodeObjectForKey:@"undefinedValueTitle"];
        self.autoActivate = ((NSNumber*)[aDecoder decodeObjectForKey:@"autoActivate"]).boolValue;
        self.KBActivationSequence = ((NSNumber*)[aDecoder decodeObjectForKey:@"KBActivationSequence"]).boolValue;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.pickerValuesKeyPath forKey:@"pickerValuesKeyPath"];
    [aCoder encodeObject:self.titleKeyPath forKey:@"titleKeyPath"];
    [aCoder encodeObject:self.titleConverterKeyPath forKey:@"titleConverterKeyPath"];
    [aCoder encodeObject:self.otherValueTitle forKey:@"otherValueTitle"];
    [aCoder encodeObject:self.undefinedValueTitle forKey:@"undefinedValueTitle"];
    [aCoder encodeObject:@(self.autoActivate) forKey:@"autoActivate"];
    [aCoder encodeObject:@(self.KBActivationSequence) forKey:@"KBActivationSequence"];
}

#pragma mark - Configuration

- (Class)preferredViewType
{
    return [AKASingleChoiceEditorControlView class];
}

- (Class)preferredBindingType
{
    return [AKASingleChoiceEditorBinding class];
}

@end
