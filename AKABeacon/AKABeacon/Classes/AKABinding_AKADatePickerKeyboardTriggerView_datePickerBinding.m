//
//  AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 08.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding.h"
#import "AKADatePickerKeyboardTriggerView.h"


#pragma mark - AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding - Private Interface
#pragma mark -

@interface AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding () <
    AKACustomKeyboardResponderDelegate
    >

@property(nonatomic, readonly)       AKADatePickerKeyboardTriggerView*      triggerView;
@property(nonatomic, readonly)       UIDatePicker*                          pickerView;

@property(nonatomic)                 NSDate*                                originalDate;
@property(nonatomic)                 NSDate*                                previousDate;

@end


#pragma mark - AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding - Implementation
#pragma mark -

@implementation AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding

+ (AKABindingSpecification*)                   specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec = @{
                               @"bindingType":              [AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding class],
                               @"targetType":               [AKADatePickerKeyboardTriggerView class],
                               @"expressionType":           @(AKABindingExpressionTypeAnyKeyPath),// TODO: create a date (constant-) type
                               @"attributes": @{
                                       @"liveModelUpdates": @{
                                               @"expressionType":  @(AKABindingExpressionTypeBoolean),
                                               @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                                               },
                                       @"autoActivate": @{
                                               @"expressionType":  @(AKABindingExpressionTypeBoolean),
                                               @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                                               },
                                       @"KBActivationSequence": @{
                                               @"expressionType":  @(AKABindingExpressionTypeBoolean),
                                               @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                                               @"bindingProperty": @"shouldParticipateInKeyboardActivationSequence"
                                               }
                                       }
                               };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[AKAKeyboardBinding_AKACustomKeyboardResponderView specification]];
    });
    
    return result;
}

#pragma mark - Initialization

- (req_AKAProperty)       createTargetValuePropertyForTarget:(req_id)view
                                                       error:(out_NSError __unused)error
{
    NSParameterAssert(view == nil || [view isKindOfClass:[AKADatePickerKeyboardTriggerView class]]);
    (void)view;

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
                [binding attachToCustomKeyboardResponderView];
                [binding.pickerView
                        addTarget:binding
                           action:@selector(datePickerDidChangeValue:)
                 forControlEvents:UIControlEventValueChanged];

                return YES;
            }
            observationStopper:
            ^BOOL (id target)
            {
                AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding* binding = target;
                [binding.pickerView
                     removeTarget:binding
                           action:@selector(datePickerDidChangeValue:)
                 forControlEvents:UIControlEventValueChanged];
                [binding detachFromCustomKeyboardResponderView];

                return YES;
            }];
}

- (void)                            datePickerDidChangeValue:(id)sender
{
    (void)sender;

    NSDate* value = self.pickerView.date;

    id oldValue = self.previousDate;

    if (self.liveModelUpdates)
    {
        [self animateTriggerForDate:oldValue
                           changeTo:value
                         animations:
         ^{
             [self targetValueDidChangeFromOldValue:oldValue
                                         toNewValue:value];
             self.previousDate = value;
         }];
    }

    if ([self shouldResignFirstResponderOnSelectedRowChanged])
    {
        [self.triggerView resignFirstResponder];
    }
}

#pragma mark - Properties

- (AKADatePickerKeyboardTriggerView*)            triggerView
{
    UIView* result = self.target;

    NSParameterAssert(result == nil || [result isKindOfClass:[AKADatePickerKeyboardTriggerView class]]);

    return (AKADatePickerKeyboardTriggerView*)result;
}

@synthesize pickerView = _pickerView;
- (UIDatePicker*)                                 pickerView
{
    if (_pickerView == nil)
    {
        UIView* inputView = [super inputViewForCustomKeyboardResponderView:self.triggerView];

        if ([inputView isKindOfClass:[UIDatePicker class]])
        {
            _pickerView = (UIDatePicker*)inputView;
        }
        else
        {
            NSAssert(inputView == nil, @"Binding %@ conflicts with delegate defined for view %@: the input view %@ provided by the original delegate is not an instance of UIDatePickerView.", self, self.triggerView, inputView);

            _pickerView = [[UIDatePicker alloc] initWithFrame:CGRectZero];
            _pickerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        }
    }

    return _pickerView;
}

#pragma mark - AKACustomKeyboardResponderDelegate Implementation

- (UIView*)          inputViewForCustomKeyboardResponderView:(AKACustomKeyboardResponderView*)view
{
    (void)view;
    NSParameterAssert(view == self.triggerView);

    // The view returned by the super class implementation, if defined and valid, is used by

    // self.pickerView if possible.
    return self.pickerView;
}

#pragma mark - Animated Target Value Update

- (void)                               animateTriggerForDate:(NSDate*)oldDate
                                                    changeTo:(NSDate*)newDate
                                                  animations:(void (^)())block
{
    if (block)
    {
        double duration = .3;
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

- (BOOL)      shouldResignFirstResponderOnSelectedRowChanged
{
    return NO;
}

#pragma mark - AKACustomKeyboardResponderDelegate Implementation

#pragma mark First Responder Support

- (void)                             responderDidDeactivate:(req_UIResponder)responder
{
    if (!self.liveModelUpdates)
    {
        NSDate* date = self.pickerView.date;

        if (date != self.originalDate && ![date isEqualToDate:self.originalDate])
        {
            [self animateTriggerForDate:self.originalDate
                               changeTo:date
                             animations:
             ^{
                 [self targetValueDidChangeFromOldValue:self.originalDate
                                             toNewValue:date];
             }];
        }
    }

    [super responderDidDeactivate:responder];
}

@end
