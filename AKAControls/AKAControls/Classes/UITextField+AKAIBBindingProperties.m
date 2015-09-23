//
//  UITextField+AKAIBBindingProperties.m
//  AKAControls
//
//  Created by Michael Utech on 20.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKANullability;
@import AKACommons.AKALog;

#import "UITextField+AKAIBBindingProperties.h"

#import "AKABindingProvider.h"
#import "AKABindingExpression_Internal.h"
#import "AKABinding.h"
#import "AKABindingContextProtocol.h"

@interface AKABindingProvider_UITextField_textBinding: AKABindingProvider

+ (instancetype)sharedInstance;

@end

@implementation UITextField(AKAIBBindingProperties)

- (NSString *)textBinding
{
    AKABindingProvider_UITextField_textBinding* provider = [AKABindingProvider_UITextField_textBinding sharedInstance];
    return [provider bindingExpressionTextForSelector:@selector(textBinding)
                                               inView:self];
}

- (void)setTextBinding:(NSString *)textBinding
{
    AKABindingProvider_UITextField_textBinding* provider = [AKABindingProvider_UITextField_textBinding sharedInstance];
    [provider setBindingExpressionText:textBinding
                               forSelector:@selector(textBinding)
                                    inView:self];
}

@end


@interface AKABinding_UITextField: AKABinding

- (instancetype)initWithTextField:(req_UITextField)textField
                       expression:(req_AKABindingExpression)bindingExpression
                          context:(req_AKABindingContext)bindingContext
                         delegate:(opt_AKABindingDelegate)delegate;

@end


@implementation AKABindingProvider_UITextField_textBinding

+ (instancetype)    sharedInstance
{
    static AKABindingProvider_UITextField_textBinding* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AKABindingProvider_UITextField_textBinding new];
    });
    return instance;
}

- (req_AKABinding)  bindingWithView:(req_UIView)view
                         expression:(req_AKABindingExpression)bindingExpression
                            context:(req_AKABindingContext)bindingContext
                           delegate:(opt_AKABindingDelegate)delegate
{
    NSParameterAssert([view isKindOfClass:[UITextField class]]);

    UITextField* textField = (UITextField*)view;

    return [[AKABinding_UITextField alloc] initWithTextField:textField
                                                  expression:bindingExpression
                                                     context:bindingContext
                                                    delegate:delegate];
}

@end


@interface AKABinding_UITextField() <UITextFieldDelegate> {
    AKAProperty* __strong _bindingSource;
    AKAProperty* __strong _bindingTarget;
}

@property(nonatomic, weak) UITextField*                   textField;

#pragma mark - Binding Configuration

@property(nonatomic, readonly) BOOL                       liveModelUpdates;
@property(nonatomic, readonly) BOOL                       autoActivate;
@property(nonatomic, readonly) BOOL                       KBActivationSequence;

#pragma mark - Saved UITextField State

@property(nonatomic, weak) id<UITextFieldDelegate>        savedTextViewDelegate;
@property(nonatomic, nullable) NSString*                  originalText;
@property(nonatomic) NSNumber*                            originalReturnKeyType;

@end


@implementation AKABinding_UITextField

#pragma mark - Initialization

- (instancetype)                         initWithTextField:(req_UITextField)textField
                                                expression:(req_AKABindingExpression)bindingExpression
                                                   context:(req_AKABindingContext)bindingContext
                                                  delegate:(opt_AKABindingDelegate)delegate
{
    if (self = [super initWithDelegate:delegate])
    {
        // TODO: setup configuration from binding expression:
        _liveModelUpdates = YES;

        _textField = textField;
        
        _bindingSource = [bindingExpression bindingSourcePropertyInContext:bindingContext
                                                             changeObserer:
                          ^(opt_id oldValue, opt_id newValue)
                          {
                              [self sourceValueDidChangeFromOldValue:oldValue
                                                          toNewValue:newValue];
                          }];

        _bindingTarget = [AKAProperty propertyOfWeakTarget:self
                                                    getter:
                          ^id (id target)
                          {
                              AKABinding_UITextField* binding = target;
                              return binding.textField.text;
                          }
                                                    setter:
                          ^(id target, id value)
                          {
                              AKABinding_UITextField* adapter = target;
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
                              AKABinding_UITextField* binding = target;
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
                              AKABinding_UITextField* binding = target;
                              [binding.textField removeTarget:target
                                                       action:@selector(textFieldDidChange:)
                                             forControlEvents:UIControlEventEditingChanged];
                              binding.textField.delegate = binding.savedTextViewDelegate;
                              binding.originalText = nil;
                              return YES;
                          }];
    }
    return self;
}

#pragma mark - Properties

- (AKAProperty *)                            bindingSource
{
    return _bindingSource;
}

- (AKAProperty *)                            bindingTarget
{
    return _bindingTarget;
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
    [self viewDidActivate];
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
                    if (![self activateNextInActivationSequence])
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
    [self viewDidDeactivate];
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

#pragma mark - Activation

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

- (BOOL)          participatesInKeyboardActivationSequence
{
    BOOL result = self.supportsActivation && self.KBActivationSequence;
    return result;
}

- (void)    setupKeyboardActivationSequenceWithPredecessor:(UIView*)previous
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

- (BOOL)                                          activate
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

- (BOOL)                                        deactivate
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

- (BOOL)                  activateNextInActivationSequence
{
    //[self.delegate.keyboardActivationSequence activateNext]
    return NO;
}

#pragma mark - Obsolete (probably) Delegate Support Methods

- (BOOL)shouldActivate
{
    return YES;
}

- (void)viewWillActivate
{
}

- (void)viewDidActivate
{
}

- (BOOL)shouldDeactivate
{
    return YES;
}

- (void)viewWillDeactivate
{
}

- (void)viewDidDeactivate
{
}

@end
