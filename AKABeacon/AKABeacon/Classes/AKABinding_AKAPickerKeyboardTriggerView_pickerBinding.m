//
//  AKABinding_AKAPickerKeyboardTriggerView_pickerBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 04.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "NSObject+AKAConcurrencyTools.h"

#import "AKABinding_AKAPickerKeyboardTriggerView_pickerBinding.h"
#import "AKAPickerKeyboardTriggerView.h"
#import "AKAKeyboardActivationSequenceAccessoryView.h"
#import "AKASelectionControlViewBinding.h"

#import "AKABinding_UIPickerView_valueBinding.h"
#import "UIPickerView+AKAIBBindingProperties_valueBinding.h"

#import "AKABinding_Protected.h"
#import "AKABinding+SubclassInitialization.h"
#import "AKABinding+DelegateSupport.h"
#import "AKABinding+BindingOwner.h"

#pragma mark - AKABinding_AKAPickerKeyboardTriggerView_pickerBinding - Private Interface
#pragma mark -

@interface AKABinding_AKAPickerKeyboardTriggerView_pickerBinding () <
    AKACustomKeyboardResponderDelegate,
    AKAControlViewBindingDelegate
    >

@property(nonatomic)                 NSArray*                           choices;
@property(nonatomic, readonly)       AKABindingExpression*              bindingExpression;
@property(nonatomic, readonly, weak) AKAPickerKeyboardTriggerView*      triggerView;
@property(nonatomic, readonly)       UIPickerView*                      pickerView;
@property(nonatomic, readonly) AKABinding_UIPickerView_valueBinding*    pickerBinding;
@property(nonatomic)                 id previousValue;

@end


#pragma mark - AKABinding_AKAPickerKeyboardTriggerView_pickerBinding - Implementation
#pragma mark -

@implementation AKABinding_AKAPickerKeyboardTriggerView_pickerBinding

#pragma mark - Specification

+ (AKABindingSpecification*)                     specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
            @{ @"bindingType":  [AKABinding_AKAPickerKeyboardTriggerView_pickerBinding class],
               @"targetType":   [AKAPickerKeyboardTriggerView class],
               @"expressionType": @(AKABindingExpressionTypeNone),
               @"attributes":   @{
                   @"picker":   @{
                       @"required":         @YES,
                       @"bindingType":      [AKABinding_UIPickerView_valueBinding class],
                       @"use":              @(AKABindingAttributeUseManually)
                   }
               }
        };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

#pragma mark - Source Value Property Initialization

- (AKAProperty *)            defaultBindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                                       context:(req_AKABindingContext)bindingContext
                                                changeObserver:(AKAPropertyChangeObserver)changeObserver
                                                         error:(out_NSError)error
{
    (void)error;

    AKAProperty* result = nil;

    // Use the same binding source as the picker binding to be able to animate the triggerView's
    // sub views if the source value changes.

    AKABindingExpression* pickerBindingExpression = bindingExpression.attributes[@"picker"];
    if (bindingExpression)
    {
        result = [pickerBindingExpression bindingSourcePropertyInContext:bindingContext
                                                           changeObserer:changeObserver];
    }
    else
    {
        result = [super defaultBindingSourceForExpression:bindingExpression
                                                  context:bindingContext
                                           changeObserver:changeObserver
                                                    error:error];
    }

    return result;
}

#pragma mark - Target Value Property Initialization

- (req_AKAProperty)         createTargetValuePropertyForTarget:(req_id)view error:(out_NSError __unused)error
{
    NSParameterAssert(view == nil || [view isKindOfClass:[AKAPickerKeyboardTriggerView class]]);
    (void)view;

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                AKABinding_AKAPickerKeyboardTriggerView_pickerBinding* binding = target;

                return binding.pickerBinding.targetValueProperty.value;
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_AKAPickerKeyboardTriggerView_pickerBinding* binding = target;

                [self animateTriggerForValue:binding.pickerBinding.targetValueProperty.value
                                    changeTo:value
                                  animations:^{
                                      binding.pickerBinding.targetValueProperty.value = value;
                                  }];
            }

                          observationStarter:
            ^BOOL (id target)
            {
                AKABinding_AKAPickerKeyboardTriggerView_pickerBinding* binding = target;

                [binding attachToCustomKeyboardResponderView];

                [binding.pickerBinding startObservingChanges];

                return YES;
            }

                          observationStopper:
            ^BOOL (id target)
            {
                AKABinding_AKAPickerKeyboardTriggerView_pickerBinding* binding = target;

                [binding.pickerBinding stopObservingChanges];
                
                [binding detachFromCustomKeyboardResponderView];
                
                return YES;
            }];
}

#pragma mark - Attribute Initialization

- (BOOL)                     initializeManualAttributeWithName:(req_NSString)attributeName
                                                 specification:(req_AKABindingAttributeSpecification __unused)specification
                                           attributeExpression:(req_AKABindingExpression)attributeExpression
                                                         error:(out_NSError)error
{
    BOOL result = NO;
    if ([@"picker" isEqualToString:attributeName])
    {
        if (attributeExpression)
        {
            id<AKABindingContextProtocol> bindingContext = self.bindingContext;
            NSAssert(bindingContext, @"Binding context required during initialization");

            AKACustomKeyboardResponderView* triggerView = self.triggerView;
            UIView* inputView = [super inputViewForCustomKeyboardResponderView:triggerView];

            // Use the picker target provided by the delegate or create a new one:
            if ([inputView isKindOfClass:[UIPickerView class]])
            {
                _pickerView = (UIPickerView*)inputView;
            }
            else
            {
                NSAssert(inputView == nil,
                         @"Binding %@ conflicts with delegate defined for view %@: the input view %@ provided by the original delegate is not an instance of UIPickerView.",
                         self, triggerView, inputView);

                _pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
                _pickerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            }

            _pickerBinding = (id)[AKABinding_UIPickerView_valueBinding bindingToTarget:_pickerView
                                                                        withExpression:attributeExpression
                                                                               context:bindingContext
                                                                                 owner:self
                                                                              delegate:[self delegateForPickerBinding]
                                                                                 error:error];

            // Ensure that the picker binding is tracking changes
            [self addBindingPropertyBinding:_pickerBinding];

            result = _pickerBinding != nil;
        }
    }

    return result;
}

#pragma mark - Change Tracking

- (void)                                    viewValueDidChange
{
    id value;

    if ([self.pickerBinding convertTargetValue:self.targetValueProperty.value
                                 toSourceValue:&value
                                         error:nil])
    {
        id oldValue = self.previousValue;
        self.previousValue = value;
        [self animateTriggerForValue:oldValue
                            changeTo:value
                          animations:
         ^{
             [self.pickerBinding updateSourceValueSkipDelegateRequests:YES];
             [self targetValueDidChangeFromOldValue:oldValue
                                             toNewValue:value];
         }];
    }
}

#pragma mark - Properties

- (AKAPickerKeyboardTriggerView*)                  triggerView
{
    UIView* result = super.triggerView;

    NSParameterAssert(result == nil || [result isKindOfClass:[AKAPickerKeyboardTriggerView class]]);

    return (AKAPickerKeyboardTriggerView*)result;
}

#pragma mark - AKAindingDelegate

- (BOOL)           shouldReceiveDelegateMessagesForSubBindings
{
    return NO;
}

- (id<AKABindingDelegate>)            delegateForPickerBinding
{
    return self;
}

- (BOOL)                                         shouldBinding:(req_AKAControlViewBinding)binding
                                             updateSourceValue:(id __unused)oldSourceValue
                                                            to:(id __unused)newSourceValue
                                                forTargetValue:(id __unused)oldTargetValue
                                                      changeTo:(id __unused)newTargetValue
{
    BOOL result = YES;

    if (binding == self.pickerBinding)
    {
        result = NO;

        // update source value only while keyboard is shown and if live model updates enabled
        if (self.triggerView.isFirstResponder && self.liveModelUpdates)
        {
            result = YES;

            // We don't need to ask our own delegate/owner/controller, because that's alreay
            // done by shouldUpdateSourceValue:to:forTargetValue:changeTo:
        }

        if (result)
        {
            // Hijack change and process it in this binding:

            // TODO: refactor that, too hacky: Find a good way to handle bindings for composite views
            // where components are not part of the subview hierarchy (these are cleanly handled by controls
            // managing bindings), like with keyboards. Problems:
            // - Event propagation/handling
            // - Binding expressions (too much nesting versus problems with combined attributes and their definitions)
            // - Alt.: single keyboard trigger view with different possible keyboard type sub bindings
            // - etc.
            result = NO;
            [self viewValueDidChange];
        }
    }

    return result;
}

#pragma mark - AKACustomKeyboardResponderDelegate Implementation

- (UIView*)            inputViewForCustomKeyboardResponderView:(AKACustomKeyboardResponderView*)view
{
    (void)view;
    NSParameterAssert(view == self.triggerView);

    // The view returned by the super class implementation, if defined and valid, is used by

    // self.pickerView if possible, see initialization
    return self.pickerView;
}

#pragma mark -

- (void)                                 responderWillActivate:(req_UIResponder)responder
{
    [super responderWillActivate:responder];

    self.previousValue = self.sourceValueProperty.value;
}

- (void)                                responderDidDeactivate:(req_UIResponder)responder
{
    if (!self.liveModelUpdates)
    {
        [self.pickerBinding updateTargetValue];
        [self viewValueDidChange];
    }

    [super responderDidDeactivate:responder];
}

#pragma mark - Animated Target Value Update

- (void)                                animateTriggerForValue:(id)oldValue
                                                      changeTo:(id)newValue
                                                    animations:(void (^)())block
{
    if (block)
    {
        double duration = .3;
        UIViewAnimationOptions options;

        NSComparisonResult order = [self.pickerBinding orderInChoicesForValue:oldValue value:newValue];

        switch (order)
        {
            case NSOrderedAscending:
                options = UIViewAnimationOptionTransitionFlipFromTop;
                break;

            case NSOrderedDescending:
                options = UIViewAnimationOptionTransitionFlipFromBottom;
                break;

            default:
                options = UIViewAnimationOptionTransitionCrossDissolve;
                break;
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

- (BOOL)        shouldResignFirstResponderOnSelectedRowChanged
{
    return (self.liveModelUpdates &&
            ![self.inputAccessoryView isKindOfClass:[AKAKeyboardActivationSequenceAccessoryView class]]);
}

@end
