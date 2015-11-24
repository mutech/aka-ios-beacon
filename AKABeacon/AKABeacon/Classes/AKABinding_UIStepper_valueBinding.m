//
//  AKABinding_UIStepper_valueBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 09.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.AKAProperty;
@import AKACommons.NSObject_AKAAssociatedValues;

#import "AKABinding_UIStepper_valueBinding.h"
#import "AKABindingExpression.h"

@interface AKABinding_UIStepper_valueBinding()

@property(nonatomic, readonly) AKAProperty*             minimumValueProperty;
@property(nonatomic, readonly) AKAProperty*             maximumValueProperty;
@property(nonatomic, readonly) AKAProperty*             stepValueProperty;
@property(nonatomic, readonly) NSNumber*                minimumValue;
@property(nonatomic, readonly) NSNumber*                maximumValue;
@property(nonatomic, readonly) NSNumber*                stepValue;

@property(nonatomic) NSNumber*                          previousValue;

#pragma mark - Saved stepper configuration


#if RESTORE_BOUND_VIEW_STATE
@property(nonatomic) NSNumber*                          originalValue;
@property(nonatomic) NSNumber*                          originalMinimumValue;
@property(nonatomic) NSNumber*                          originalMaximumValue;
@property(nonatomic) NSNumber*                          originalStepValue;
@property(nonatomic) NSNumber*                          originalAutorepeat;
@property(nonatomic) NSNumber*                          originalContinuous;
@property(nonatomic) NSNumber*                          originalWraps;
#endif

@end

@implementation AKABinding_UIStepper_valueBinding

+  (AKABindingSpecification *)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":              [AKABinding_UIStepper_valueBinding class],
           @"targetType":               [UIStepper class],
           @"expressionType":           @(AKABindingExpressionTypeNumber),
           @"attributes":
               @{ @"minimumValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeNumber),
                         @"use":             @(AKABindingAttributeUseAssignExpressionToBindingProperty),
                         @"bindingProperty": @"minimumValueExpression"
                         },
                  @"maximumValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeNumber),
                         @"use":             @(AKABindingAttributeUseAssignExpressionToBindingProperty),
                         @"bindingProperty": @"maximumValueExpression"
                         },
                  @"stepValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeNumber),
                         @"use":             @(AKABindingAttributeUseAssignExpressionToBindingProperty),
                         @"bindingProperty": @"stepValueExpression"
                         },
                  @"autorepeat":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBoolean),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         },
                  @"continuous":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBoolean),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         },
                  @"wraps":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBoolean),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         },
                  },
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    return result;
}

#pragma mark - Initialization

- (void)dealloc
{
    [_minimumValueProperty stopObservingChanges];
    [_maximumValueProperty stopObservingChanges];
    [_stepValueProperty stopObservingChanges];
}

- (void)                             validateTargetView:(req_UIView)targetView
{
    (void)targetView;
    NSParameterAssert([targetView isKindOfClass:[UIStepper class]]);
}

#pragma mark - Properties

- (NSNumber *)minimumValue { return self.minimumValueProperty.value; }

- (NSNumber *)maximumValue { return self.maximumValueProperty.value; }

- (NSNumber *)stepValue { return self.stepValueProperty.value; }

@synthesize minimumValueProperty = _minimumValueProperty;
- (AKAProperty *)minimumValueProperty
{
    id<AKABindingContextProtocol> context = self.bindingContext;
    if (_minimumValueProperty == nil && self.minimumValueExpression && context)
    {
        __weak AKABinding_UIStepper_valueBinding* weakSelf = self;
        _minimumValueProperty =
            [self.minimumValueExpression bindingSourcePropertyInContext:context
                                                          changeObserer:
             ^(opt_id oldValue, opt_id newValue)
             {
                 (void)oldValue;
                 NSParameterAssert(newValue == nil || [newValue isKindOfClass:[NSNumber class]]);
                 AKABinding_UIStepper_valueBinding* binding = weakSelf;
                 binding.uiStepper.minimumValue = ((NSNumber*)newValue).floatValue;
                 [binding updateTargetValue];
             }];
    }
    return _minimumValueProperty;
}

@synthesize maximumValueProperty = _maximumValueProperty;
- (AKAProperty *)maximumValueProperty
{
    id<AKABindingContextProtocol> context = self.bindingContext;
    if (_maximumValueProperty == nil && self.maximumValueExpression && context)
    {
        __weak AKABinding_UIStepper_valueBinding* weakSelf = self;
        _maximumValueProperty = [self.maximumValueExpression bindingSourcePropertyInContext:context
                                                                              changeObserer:
         ^(opt_id oldValue, opt_id newValue)
         {
             (void)oldValue;
             NSParameterAssert(newValue == nil || [newValue isKindOfClass:[NSNumber class]]);
             AKABinding_UIStepper_valueBinding* binding = weakSelf;
             binding.uiStepper.maximumValue = ((NSNumber*)newValue).floatValue;
             [binding updateTargetValue];
         }];
    }
    return _maximumValueProperty;
}

@synthesize stepValueProperty = _stepValueProperty;
- (AKAProperty *)stepValueProperty
{
    id<AKABindingContextProtocol> context = self.bindingContext;
    if (_stepValueProperty == nil && self.stepValueExpression && context)
    {
        __weak AKABinding_UIStepper_valueBinding* weakSelf = self;
        _stepValueProperty = [self.stepValueExpression bindingSourcePropertyInContext:context
                                                                        changeObserer:
         ^(opt_id oldValue, opt_id newValue)
         {
             (void)oldValue;
             NSParameterAssert(newValue == nil || [newValue isKindOfClass:[NSNumber class]]);
             AKABinding_UIStepper_valueBinding* binding = weakSelf;
             binding.uiStepper.stepValue = ((NSNumber*)newValue).floatValue;
             [binding updateTargetValue];
         }];
    }
    return _stepValueProperty;
}

#pragma mark - Binding Target

- (req_AKAProperty)  createBindingTargetPropertyForView:(req_UIView)view
{
    NSParameterAssert(view == nil || [view isKindOfClass:[UIStepper class]]);

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                AKABinding_UIStepper_valueBinding* binding = target;
                return @(binding.uiStepper.value);
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_UIStepper_valueBinding* binding = target;
                if ([value isKindOfClass:[NSNumber class]])
                {
                    float floatValue = ((NSNumber*)value).floatValue;
                    binding.uiStepper.value = floatValue;
                    NSAssert(binding.uiStepper.value == floatValue, @"Failed to set stepper %@ value to %g", binding.uiStepper, floatValue);
                }
            }
                          observationStarter:
            ^BOOL (id target)
            {
                AKABinding_UIStepper_valueBinding* binding = target;
                BOOL result = binding.uiStepper != nil;
                if (result)
                {
#if RESTORE_BOUND_VIEW_STATE
                    [binding saveViewState];
#endif
                    [binding setupView];
                    [binding.uiStepper addTarget:binding
                                         action:@selector(targetValueDidChangeSender:)
                               forControlEvents:UIControlEventValueChanged];
                }
                return result;
            }
                          observationStopper:
            ^BOOL (id target)
            {
                AKABinding_UIStepper_valueBinding* binding = target;
                BOOL result = binding.uiStepper != nil;
                if (result)
                {
                    [binding.uiStepper removeTarget:binding
                                            action:@selector(targetValueDidChangeSender:)
                                  forControlEvents:UIControlEventValueChanged];

#if RESTORE_BOUND_VIEW_STATE
                    [binding restoreViewState];
#endif
                }
                return result;
            }];
}

- (BOOL)startObservingChanges
{
    [self.minimumValueProperty startObservingChanges];
    [self.maximumValueProperty startObservingChanges];
    [self.stepValueProperty startObservingChanges];

    return [super startObservingChanges];
}

- (BOOL)stopObservingChanges
{
    BOOL result = [super stopObservingChanges];

    [self.stepValueProperty stopObservingChanges];
    [self.maximumValueProperty stopObservingChanges];
    [self.minimumValueProperty stopObservingChanges];

    return result;
}

- (void)                          setupView
{
    self.previousValue = @(self.uiStepper.value);

    if (self.minimumValue)
    {
        self.uiStepper.minimumValue = self.minimumValue.floatValue;
    }
    if (self.maximumValue)
    {
        self.uiStepper.maximumValue = self.maximumValue.floatValue;
    }
    if (self.stepValue)
    {
        self.uiStepper.stepValue = self.stepValue.floatValue;
    }
    if (self.autorepeat)
    {
        self.uiStepper.autorepeat = self.autorepeat.boolValue;
    }
    if (self.continuous)
    {
        self.uiStepper.continuous = self.continuous.boolValue;
    }
    if (self.wraps)
    {
        self.uiStepper.wraps = self.wraps.boolValue;
    }
}


#if RESTORE_BOUND_VIEW_STATE
- (void)                                   setViewState
{
    self.originalValue = self.previousValue = @(self.uiStepper.value);

    if (self.minimumValue)
    {
        self.originalMinimumValue = @(self.uiStepper.minimumValue);
    }
    if (self.maximumValue)
    {
        self.originalMaximumValue = @(self.uiStepper.maximumValue);
    }
    if (self.stepValue)
    {
        self.originalStepValue = @(self.uiStepper.stepValue);
    }
    if (self.autorepeat)
    {
        self.originalAutorepeat = @(self.uiStepper.autorepeat);
    }
    if (self.continuous)
    {
        self.originalContinuous = @(self.uiStepper.continuous);
    }
    if (self.wraps)
    {
        self.originalWraps = @(self.uiStepper.wraps);
    }
}

- (void)                               restoreViewState
{
    if (self.originalValue)
    {
        self.uiStepper.value = self.originalValue.floatValue;
        self.originalValue = self.previousValue = nil;
    }
    if (self.originalMinimumValue)
    {
        self.uiStepper.minimumValue = self.originalMinimumValue.floatValue;
        self.originalMinimumValue = nil;
    }
    if (self.originalMaximumValue)
    {
        self.uiStepper.maximumValue = self.originalMaximumValue.floatValue;
        self.originalMaximumValue = nil;
    }
    if (self.originalStepValue)
    {
        self.uiStepper.stepValue = self.originalStepValue.floatValue;
        self.originalStepValue = nil;
    }
    if (self.originalAutorepeat)
    {
        self.uiStepper.autorepeat = self.originalAutorepeat.boolValue;
        self.originalAutorepeat = nil;
    }
    if (self.originalContinuous)
    {
        self.uiStepper.continuous = self.originalContinuous.boolValue;
        self.originalContinuous = nil;
    }
    if (self.originalWraps)
    {
        self.uiStepper.wraps = self.originalWraps.boolValue;
        self.originalWraps = nil;
    }
}
#endif

#pragma mark - Properties

- (UIStepper *)                               uiStepper
{
    UIView* result = self.view;
    NSParameterAssert(result == nil || [result isKindOfClass:[UIStepper class]]);

    return (UIStepper*)result;
}

#pragma mark - Change Observation

- (void)                     targetValueDidChangeSender:(id)sender
{
    (void)sender; // Not used

    NSNumber* newValue = @(self.uiStepper.value);
    NSNumber* oldValue = self.previousValue;
    self.previousValue = newValue;

    [self targetValueDidChangeFromOldValue:oldValue
                                toNewValue:newValue];

    // Trigger change notifications for bindingTarget property (for the case that someone
    // created a depedendant property based on the binding target). Stepper value may have
    // been changed above, so we query it again here:
    newValue = @(self.uiStepper.value);
    if (newValue != oldValue)
    {
        [self.bindingTarget notifyPropertyValueDidChangeFrom:oldValue to:newValue];
    }
}

@end
