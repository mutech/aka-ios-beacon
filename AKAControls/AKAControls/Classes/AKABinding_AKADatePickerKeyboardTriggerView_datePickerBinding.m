//
//  AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding.m
//  AKAControls
//
//  Created by Michael Utech on 08.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding.h"
#import "AKADatePickerKeyboardTriggerView.h"

@interface AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding() <
    AKACustomKeyboardResponderDelegate
>

@property(nonatomic, readonly)       AKADatePickerKeyboardTriggerView*      triggerView;
@property(nonatomic, readonly)       UIDatePicker*                          pickerView;
@property(nonatomic, readonly, weak) id<AKABindingContextProtocol>          bindingContext;

@property(nonatomic, weak)           UIView*                                inputAccessoryView;

@property(nonatomic, weak)           id<AKACustomKeyboardResponderDelegate> savedTriggerViewDelegate;

@property(nonatomic)                 NSDate*                                originalDate;
@property(nonatomic)                 NSDate*                                previousDate;

@end


@implementation AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding

#pragma mark - Initialization

- (instancetype _Nullable)                      initWithTarget:(id)target
                                                    expression:(req_AKABindingExpression)bindingExpression
                                                       context:(req_AKABindingContext)bindingContext
                                                      delegate:(opt_AKABindingDelegate)delegate
{
    NSParameterAssert([target isKindOfClass:[AKADatePickerKeyboardTriggerView class]]);
    return [self initWithTriggerView:(AKADatePickerKeyboardTriggerView*)target
                          expression:bindingExpression
                             context:bindingContext
                            delegate:delegate];
}

- (instancetype)                           initWithTriggerView:(AKADatePickerKeyboardTriggerView* _Nonnull)triggerView
                                                    expression:(req_AKABindingExpression)bindingExpression
                                                       context:(req_AKABindingContext)bindingContext
                                                      delegate:(opt_AKABindingDelegate)delegate
{
    if (self = [super initWithTarget:[self createTargetProperty]
                          expression:bindingExpression
                             context:bindingContext
                            delegate:delegate])
    {
        _KBActivationSequence = YES;
        _autoActivate = YES;
        _liveModelUpdates = YES;

        _triggerView = triggerView;

        _bindingContext = bindingContext;
    }
    return self;
}

- (AKAProperty*)                          createTargetProperty
{
    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                id result;
                AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding* binding = target;
                result = binding.pickerView.date;
                return result;
            }
                                      setter:
            ^(id target, id value)
            {
                NSAssert(value == nil || [value isKindOfClass:[NSDate class]], @"Invalid attempt to use a date picker with an object '%@' which is not an instance of NSDate", value);

                AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding* binding = target;
                if (value != nil)
                {
                    id currentValue = binding.pickerView.date;
                    if (currentValue == nil && currentValue != value)
                    {
                        currentValue = [NSNull null];
                    }
                    if (currentValue != value)
                    {
                        // Only update picker, if the value associated with
                        // the previously selected row is different from the
                        // new value (selections, especially undefined and
                        // may have the same associated values and in these
                        // cases we don't want to change the selection).
                        binding.pickerView.date = value;
                        binding.originalDate = binding.previousDate = value;
                    }
                }
            }
                          observationStarter:
            ^BOOL (id target)
            {
                AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding* binding = target;
                if (binding.triggerView.delegate != binding)
                {
                    binding.savedTriggerViewDelegate = binding.triggerView.delegate;
                    binding.triggerView.delegate = binding;
                }
                [binding.pickerView addTarget:binding
                                       action:@selector(datePickerDidChangeValue:)
                             forControlEvents:UIControlEventValueChanged];
                return YES;
            }
                          observationStopper:
            ^BOOL (id target)
            {
                AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding* binding = target;
                [binding.pickerView removeTarget:binding
                                          action:@selector(datePickerDidChangeValue:)
                                forControlEvents:UIControlEventValueChanged];
                binding.triggerView.delegate = binding.savedTriggerViewDelegate;

                return YES;
            }];
}

- (void)datePickerDidChangeValue:(id)sender
{
    NSDate* value = self.pickerView.date;

    id oldValue = self.previousDate;
    if (self.liveModelUpdates)
    {

        [self animateTriggerForDate:oldValue changeTo:value animations:
         ^{
             [self targetValueDidChangeFromOldValue:oldValue toNewValue:value];
             self.previousDate = value;
         }];
    }
    if ([self shouldResignFirstResponderOnSelectedRowChanged])
    {
        [self.triggerView resignFirstResponder];
    }
}

#pragma mark - Properties

@synthesize pickerView = _pickerView;
- (UIDatePicker *)                                  pickerView
{
    if (_pickerView == nil)
    {
        _pickerView = [[UIDatePicker alloc] initWithFrame:CGRectZero];
        _pickerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return _pickerView;
}

- (void)                           setSavedTriggerViewDelegate:(id<AKACustomKeyboardResponderDelegate>)savedTriggerViewDelegate
{
    NSAssert(savedTriggerViewDelegate != self, @"Cannot register AKA custom keyboard trigger view binding as saved delegate, it already acts as replacement/proxy delegate");

    _savedTriggerViewDelegate = savedTriggerViewDelegate;
}

#pragma mark - Animated Target Value Update

- (void)animateTriggerForDate:(NSDate*)oldDate
                     changeTo:(NSDate*)newDate
                   animations:(void(^)())block
{
    if (block)
    {
        CGFloat duration = .3;
        UIViewAnimationOptions options;
        if ([oldDate compare:newDate] == NSOrderedAscending)
        {
            options = UIViewAnimationOptionTransitionFlipFromTop;
        }
        else if ([oldDate compare:newDate] == NSOrderedDescending)
        {
            options = UIViewAnimationOptionTransitionFlipFromBottom;
        }
        else
        {
            options = UIViewAnimationOptionTransitionCrossDissolve;
        }
        [UIView transitionWithView:self.triggerView
                          duration:duration
                           options:options
                        animations:
         ^{
             block();
         }
                        completion:nil];
    }
}

- (BOOL)shouldResignFirstResponderOnSelectedRowChanged
{
    return NO;
}

#pragma mark - AKACustomKeyboardResponderDelegate Implementation

- (BOOL)    customKeyboardResponderViewCanBecomeFirstResponder:(AKACustomKeyboardResponderView*)view
{
    BOOL result = YES; // We might want to make this depend on something

    NSParameterAssert(view == self.triggerView);
    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(customKeyboardResponderViewCanBecomeFirstResponder:)])
    {
        result = [secondary customKeyboardResponderViewCanBecomeFirstResponder:view];
    }

    return result;
}

- (UIView*)            inputViewForCustomKeyboardResponderView:(AKACustomKeyboardResponderView*)view
{
    UIView* result = nil; // We might want to make this depend on something

    NSParameterAssert(view == self.triggerView);

    // Let the original delegate replace our picker view
    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(inputViewForCustomKeyboardResponderView:)])
    {
        result = [secondary inputViewForCustomKeyboardResponderView:view];
        // TODO: Add sanity checks on input view configuration:
        // - has to be a picker view, no delegate setup? Or should we proxy it?
    }

    // If original delegate did no provide an input view (the default path), use ours
    if (result == nil)
    {
        result = self.pickerView;
    }

    return result;
}

- (UIView*)   inputAccessoryViewForCustomKeyboardResponderView:(AKACustomKeyboardResponderView*)view
{
    return self.inputAccessoryView;
}

#pragma mark Key Input Protocol Support

- (BOOL)                    customKeyboardResponderViewHasText:(AKACustomKeyboardResponderView*)view
{
    BOOL result = YES;

    NSParameterAssert(view == self.triggerView);
    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(customKeyboardResponderViewHasText:)])
    {
        result = [secondary customKeyboardResponderViewHasText:view];
    }

    return result;
}

- (void)                           customKeyboardResponderView:(AKACustomKeyboardResponderView*)view
                                                    insertText:(NSString *)text
{
    NSParameterAssert(view == self.triggerView);
    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(customKeyboardResponderView:insertText:)])
    {
        [secondary customKeyboardResponderView:view insertText:text];
    }
}

- (void)             customKeyboardResponderViewDeleteBackward:(AKACustomKeyboardResponderView*)view
{
    NSParameterAssert(view == self.triggerView);
    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(customKeyboardResponderViewDeleteBackward:)])
    {
        [secondary customKeyboardResponderViewDeleteBackward:view];
    }
}

#pragma mark First Responder Support

- (BOOL) customKeyboardResponderViewShouldBecomeFirstResponder:(AKACustomKeyboardResponderView*)view
{
    BOOL result = YES; // We might want to make this depend on something

    NSParameterAssert(view == self.triggerView);
    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(customKeyboardResponderViewCanBecomeFirstResponder:)])
    {
        result = [secondary customKeyboardResponderViewCanBecomeFirstResponder:view];
    }

    return result;
}

- (void)   customKeyboardResponderViewWillBecomeFirstResponder:(AKACustomKeyboardResponderView*)view
{
    NSParameterAssert(view == self.triggerView);

    [self.delegate binding:self responderWillActivate:view];

    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(customKeyboardResponderViewWillBecomeFirstResponder:)])
    {
        [secondary customKeyboardResponderViewWillBecomeFirstResponder:view];
    }
}

- (void)    customKeyboardResponderViewDidBecomeFirstResponder:(AKACustomKeyboardResponderView*)view
{
    NSParameterAssert(view == self.triggerView);

    [self.delegate binding:self responderDidActivate:view];

    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(customKeyboardResponderViewDidBecomeFirstResponder:)])
    {
        [secondary customKeyboardResponderViewDidBecomeFirstResponder:view];
    }
}

- (BOOL) customKeyboardResponderViewShouldResignFirstResponder:(AKACustomKeyboardResponderView*)view
{
    BOOL result = YES;

    NSParameterAssert(view == self.triggerView);
    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(customKeyboardResponderViewShouldResignFirstResponder:)])
    {
        result = [secondary customKeyboardResponderViewShouldResignFirstResponder:view];
    }

    return result;
}

- (void)   customKeyboardResponderViewWillResignFirstResponder:(AKACustomKeyboardResponderView*)view
{
    NSParameterAssert(view == self.triggerView);

    [self.delegate binding:self responderWillDeactivate:view];

    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(customKeyboardResponderViewWillResignFirstResponder:)])
    {
        [secondary customKeyboardResponderViewWillResignFirstResponder:view];
    }
}

- (void)    customKeyboardResponderViewDidResignFirstResponder:(AKACustomKeyboardResponderView*)view
{
    NSParameterAssert(view == self.triggerView);

    if (!self.liveModelUpdates)
    {
        NSDate* date = self.pickerView.date;
        if (date != self.originalDate && ![date isEqualToDate:self.originalDate])
        {
            [self animateTriggerForDate:self.originalDate changeTo:date animations:
             ^{
                 [self targetValueDidChangeFromOldValue:self.originalDate toNewValue:date];
             }];
        }
    }

    [self.delegate binding:self responderDidDeactivate:view];

    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(customKeyboardResponderViewDidResignFirstResponder:)])
    {
        [secondary customKeyboardResponderViewDidResignFirstResponder:view];
    }
}

#pragma mark - Activation

- (BOOL)                                    supportsActivation
{
    BOOL result = self.triggerView != nil;
    return result;
}

- (BOOL)                                    shouldAutoActivate
{
    BOOL result = self.supportsActivation && self.autoActivate;
    return result;
}

#pragma mark - Keyboard Activation Sequence

- (BOOL)         shouldParticipateInKeyboardActivationSequence
{
    BOOL result = self.supportsActivation && self.KBActivationSequence;
    return result;
}

- (opt_UIResponder)     responderForKeyboardActivationSequence
{
    return self.triggerView;
}

- (BOOL)                                     isResponderActive
{
    return self.triggerView.isFirstResponder;
}

- (BOOL)                                     activateResponder
{
    AKACustomKeyboardResponderView* triggerView = self.triggerView;
    BOOL result = triggerView != nil;
    if (result)
    {
        [self responderWillActivate:triggerView];
        result = [triggerView becomeFirstResponder];
    }
    return result;
}

- (BOOL)                                   deactivateResponder
{
    AKACustomKeyboardResponderView* triggerView = self.triggerView;
    BOOL result = triggerView != nil;
    if (result)
    {
        [self responderWillDeactivate:triggerView];
        result = [triggerView resignFirstResponder];
    }
    return result;
}

- (BOOL)                             installInputAccessoryView:(req_UIView)inputAccessoryView
{
    self.inputAccessoryView = inputAccessoryView;
    return self.triggerView.inputAccessoryView == inputAccessoryView;
}

- (BOOL)                             restoreInputAccessoryView
{
    self.inputAccessoryView = nil;

    return YES;
}

#pragma mark - Obsolete (probably) Delegate Support Methods

- (BOOL)                                        shouldActivate
{
    return YES;
}

- (BOOL)                                      shouldDeactivate
{
    return YES;
}


@end
