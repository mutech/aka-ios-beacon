//
//  AKABindingProvider_UITextField_textBinding.m
//  AKAControls
//
//  Created by Michael Utech on 28.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.NSObject_AKAAssociatedValues;

#import "AKABindingProvider_UITextField_textBinding.h"

#pragma mark - AKABindingProvider_UITextField_textBinding - Implementation
#pragma mark -

@implementation AKABindingProvider_UITextField_textBinding

#pragma mark - Initialization

+ (instancetype)    sharedInstance
{
    static AKABindingProvider_UITextField_textBinding* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AKABindingProvider_UITextField_textBinding new];
    });
    return instance;
}

#pragma mark - Binding Expression Validation

- (AKABindingSpecification *)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":          [AKABinding_UITextField_textBinding class],
           @"bindingProviderType":  [AKABindingProvider_UITextField_textBinding class],
           @"targetType":           [UITextField class],
           @"expressionType":       @(AKABindingExpressionTypeAny ^ AKABindingExpressionTypeArray),
           @"attributes":
               @{ @"liveModelUpdates":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBoolean),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty)
                         },
                  @"autoActivate":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBoolean),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty)
                         },
                  @"KBActivationSequence":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBoolean),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty)
                         }
                  }
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec];
    });
    return result;
}

@end


#pragma mark - AKABinding_UITextField_textBinding - Private Interface
#pragma mark -

@interface AKABinding_UITextField_textBinding() <UITextFieldDelegate>

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
{
    NSParameterAssert([target isKindOfClass:[UITextField class]]);
    return [self      initWithView:(UITextField*)target
                        expression:bindingExpression
                           context:bindingContext
                          delegate:delegate];
}

- (instancetype)                              initWithView:(req_UITextField)textField
                                                expression:(req_AKABindingExpression)bindingExpression
                                                   context:(req_AKABindingContext)bindingContext
                                                  delegate:(opt_AKABindingDelegate)delegate
{
    NSParameterAssert([textField isKindOfClass:[UITextField class]]);
    if (self = [super initWithView:textField
                          expression:bindingExpression
                             context:bindingContext
                            delegate:delegate])
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
                AKABinding_UITextField_textBinding* adapter = target;
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
                AKABinding_UITextField_textBinding* binding = target;
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
                AKABinding_UITextField_textBinding* binding = target;
                [binding.textField removeTarget:target
                                         action:@selector(textFieldDidChange:)
                               forControlEvents:UIControlEventEditingChanged];
                binding.textField.delegate = binding.savedTextViewDelegate;
                binding.originalText = nil;
                return YES;
            }];
}

#pragma mark - Properties

- (UITextField *)                                 textField
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

- (BOOL)                       textFieldShouldBeginEditing:(UITextField *)textField
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

- (void)                          textFieldDidBeginEditing:(UITextField *)textField
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

- (BOOL)                             textFieldShouldReturn:(UITextField *)textField
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
                    if (![self.delegate binding:self responderRequestedActivateNext:self.textField])
                    {
                        [self deactivateResponder];
                    }
                }
                break;

            case UIReturnKeyGo:
            case UIReturnKeyDone:
                // TODO: check if committing the form is appropriate for these return key styles.
            default:
                // This will call the corresponding should/did end editing handlers
                [self deactivateResponder];
                break;
        }
    }
    return result;
}

- (BOOL)                              textFieldShouldClear:(UITextField *)textField
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

- (BOOL)                                         textField:(UITextField *)textField
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
}

- (void)                                textFieldDidChange:(UITextField*)textField
{
    if (self.liveModelUpdates)
    {
        [self viewValueDidChange];
    }
}

- (BOOL)                         textFieldShouldEndEditing:(UITextField *)textField
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

- (void)                            textFieldDidEndEditing:(UITextField *)textField
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
    NSString* previousValue = self.originalText;

    self.originalText = self.textField.text;
    if (previousValue != nil && ![previousValue isEqualToString:self.originalText])
    {
        // Value has been changed without us noticing; TODO: check if we have to do something
    }
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

- (void)setResponderInputAccessoryView:(UIView *)responderInputAccessoryView
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
