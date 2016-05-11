//
//  AKABinding_AKAPickerKeyboardTriggerView_pickerBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 04.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.NSObject_AKAConcurrencyTools;

#import "AKABinding_AKAPickerKeyboardTriggerView_pickerBinding.h"
#import "AKAPickerKeyboardTriggerView.h"
#import "AKAKeyboardActivationSequenceAccessoryView.h"
#import "AKASelectionControlViewBinding.h"

#import "AKABinding_UIPickerView_valueBinding.h"
#import "UIPickerView+AKAIBBindingProperties.h"

#import "AKAViewBinding_Protected.h"

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

- (BOOL)                     initializeManualAttributeWithName:(NSString *)attributeName
                                                 specification:(req_AKABindingAttributeSpecification __unused)specification
                                           attributeExpression:(AKABindingExpression *)attributeExpression
                                                bindingContext:(req_AKABindingContext)bindingContext
                                                         error:(NSError *__autoreleasing  _Nullable *)error
{
    BOOL result = NO;
    if ([@"picker" isEqualToString:attributeName])
    {
        if (attributeExpression)
        {
            AKACustomKeyboardResponderView* triggerView = self.triggerView;
            UIView* inputView = [super inputViewForCustomKeyboardResponderView:triggerView];

            // Use the picker view provided by the delegate or create a new one:
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

            // Create the picker binding using the previously obtained picker view as target
            _pickerBinding = [[AKABinding_UIPickerView_valueBinding alloc] initWithView:_pickerView
                                                                             expression:attributeExpression
                                                                                context:bindingContext
                                                                               delegate:self
                                                                                  error:error];

            // Ensure that the picker binding is tracking changes
            [self addBindingPropertyBinding:_pickerBinding];

            result = _pickerBinding != nil;
        }
    }

    return result;
}

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

- (void)                                    validateTargetView:(req_UIView)targetView
{
    (void)targetView;
    NSParameterAssert([targetView isKindOfClass:[AKAPickerKeyboardTriggerView class]]);
}

- (req_AKAProperty)         createBindingTargetPropertyForView:(req_UIView)view
{
    NSParameterAssert(view == nil || [view isKindOfClass:[AKAPickerKeyboardTriggerView class]]);
    (void)view;

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                AKABinding_AKAPickerKeyboardTriggerView_pickerBinding* binding = target;

                return binding.pickerBinding.bindingTarget.value;
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_AKAPickerKeyboardTriggerView_pickerBinding* binding = target;

                [self animateTriggerForValue:binding.pickerBinding.bindingTarget.value
                                    changeTo:value
                                  animations:^{
                                      binding.pickerBinding.bindingTarget.value = value;
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

#pragma mark - Change Tracking

- (void)                                    viewValueDidChange
{
    id value;

    if ([self.pickerBinding convertTargetValue:self.bindingTarget.value
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

- (AKAPickerKeyboardTriggerView*)                 triggerView
{
    UIView* result = super.triggerView;

    NSParameterAssert(result == nil || [result isKindOfClass:[AKAPickerKeyboardTriggerView class]]);

    return (AKAPickerKeyboardTriggerView*)result;
}

#pragma mark - AKAControlViewBindingDelegate (for picker binding)

- (BOOL)                                        shouldBinding:(req_AKAControlViewBinding)binding
                                            updateSourceValue:(id)oldSourceValue
                                                           to:(id)newSourceValue
                                               forTargetValue:(id)oldTargetValue
                                                     changeTo:(id)newTargetValue
{
    BOOL result = YES;

    if (binding == self.pickerBinding)
    {
        result = NO;

        // update source value only while keyboard is shown and if live model updates enabled
        if (self.triggerView.isFirstResponder && self.liveModelUpdates)
        {
            id<AKAControlViewBindingDelegate> delegate = self.delegate;

            if ([delegate respondsToSelector:@selector(shouldBinding:updateSourceValue:to:forTargetValue:changeTo:)])
            {
                result = [delegate shouldBinding:self
                               updateSourceValue:oldSourceValue
                                              to:newSourceValue
                                  forTargetValue:oldTargetValue
                                        changeTo:newTargetValue];
            }
            else
            {
                result = YES;
            }
        }

        if (result)
        {
            // TODO: refactor that, too hacky: Find a good way to handle bindings for composite views
            // where components are not part of the subview hierarchy (these are cleanly handled by controls
            // managing bindings), like with keyboards. Problems:
            // - Event propagation/handling
            // - Binding expressions (too much nesting versus problems with combined attributes and their definitions)
            // - Alt.: single keyboard trigger view with different possible keyboard type sub bindings
            // - etc.
            // Hijack change and process it in this binding:
            result = NO;
            [self viewValueDidChange];
        }
    }

    return result;
}

#pragma mark - AKACustomKeyboardResponderDelegate Implementation

- (UIView*)           inputViewForCustomKeyboardResponderView:(AKACustomKeyboardResponderView*)view
{
    (void)view;
    NSParameterAssert(view == self.triggerView);

    // The view returned by the super class implementation, if defined and valid, is used by

    // self.pickerView if possible, see initialization
    return self.pickerView;
}

#pragma mark -

- (void)                                responderWillActivate:(req_UIResponder)responder
{
    [super responderWillActivate:responder];

    self.previousValue = self.bindingSource.value;
}

- (void)                               responderDidDeactivate:(req_UIResponder)responder
{
    if (!self.liveModelUpdates)
    {
        [self.pickerBinding updateTargetValue];
        [self viewValueDidChange];
    }

    [super responderDidDeactivate:responder];
}

#pragma mark - Animated Target Value Update

- (void)                               animateTriggerForValue:(id)oldValue
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

- (BOOL)       shouldResignFirstResponderOnSelectedRowChanged
{
    return (self.liveModelUpdates &&
            ![self.inputAccessoryView isKindOfClass:[AKAKeyboardActivationSequenceAccessoryView class]]);
}

@end
