//
//  AKABinding_UIControl_enabledBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 21.03.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABeaconNullability.h"
#import "AKABinding_UIControl_enabledBinding.h"

#pragma mark - AKABinding_UIControl_enabledBinding - Private Interface
#pragma mark -

@interface AKABinding_UIControl_enabledBinding()

/**
 Convenience property accessing self.target as UIControl.
 */
@property(nonatomic, readonly) UIBarButtonItem* uiControl;

@end



#pragma mark - AKABinding_UIControl_enabledBinding - Implementation
#pragma mark -

@implementation AKABinding_UIControl_enabledBinding

+  (AKABindingSpecification *)            specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":              [AKABinding_UIControl_enabledBinding class],
           @"targetType":               [UIControl class],
           @"expressionType":           @(AKABindingExpressionTypeBoolean),
           @"attributes":
               @{ },
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    return result;
}

#pragma mark - Initialization

- (void)validateTarget:(req_id)target
{
    (void)target;
    NSParameterAssert([target isKindOfClass:[UIControl class]]);
}

#pragma mark - Binding Target

- (req_AKAProperty)createTargetValuePropertyForTarget:(req_id)view
{
    NSParameterAssert(view == nil || [view isKindOfClass:[UIControl class]]);

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                AKABinding_UIControl_enabledBinding* binding = target;
                return @(binding.uiControl.enabled);
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_UIControl_enabledBinding* binding = target;
                if ([value isKindOfClass:[NSNumber class]])
                {
                    BOOL boolValue = ((NSNumber*)value).boolValue;
                    binding.uiControl.enabled = boolValue;
                }
            }
                          observationStarter:
            ^BOOL (id __unused target)
            {
                // Read-only binding
                return YES;
            }
                          observationStopper:
            ^BOOL (id __unused target)
            {
                // Read-only binding
                return YES;
            }];
}

#pragma mark - Properties

- (UIControl *)                               uiControl
{
    UIView* result = self.target;
    NSParameterAssert(result == nil || [result isKindOfClass:[UIControl class]]);

    return (UIControl*)result;
}


@end


#pragma mark - AKABinding_UIBarButtonItem_enabledBinding - Private Interface
#pragma mark -

@interface AKABinding_UIBarButtonItem_enabledBinding()

/**
 Convenience property accessing self.target as UIBarButtonItem.
 */
@property(nonatomic, readonly) UIBarButtonItem* uiBarButtonItem;

@end



#pragma mark - AKABinding_UIBarButtonItem_enabledBinding - Implementation
#pragma mark -

@implementation AKABinding_UIBarButtonItem_enabledBinding

+  (AKABindingSpecification *)            specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":              [AKABinding_UIBarButtonItem_enabledBinding class],
           @"targetType":               [UIBarButtonItem class],
           @"expressionType":           @(AKABindingExpressionTypeBoolean),
           @"attributes":
               @{ },
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    return result;
}

#pragma mark - Initialization

- (void)validateTarget:(req_id)target
{
    (void)target;
    NSParameterAssert([target isKindOfClass:[UIBarButtonItem class]]);
}

#pragma mark - Binding Target

- (req_AKAProperty)createTargetValuePropertyForTarget:(req_id)view
{
    NSParameterAssert(view == nil || [view isKindOfClass:[UIBarButtonItem class]]);

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                AKABinding_UIBarButtonItem_enabledBinding* binding = target;
                return @(binding.uiBarButtonItem.enabled);
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_UIBarButtonItem_enabledBinding* binding = target;
                if ([value isKindOfClass:[NSNumber class]])
                {
                    BOOL boolValue = ((NSNumber*)value).boolValue;
                    binding.uiBarButtonItem.enabled = boolValue;
                }
            }
                          observationStarter:
            ^BOOL (id __unused target)
            {
                // Read-only binding
                return YES;
            }
                          observationStopper:
            ^BOOL (id __unused target)
            {
                // Read-only binding
                return YES;
            }];
}

#pragma mark - Properties

- (UIControl *)                               uiBarButtonItem
{
    UIView* result = self.target;
    NSParameterAssert(result == nil || [result isKindOfClass:[UIBarButtonItem class]]);

    return (UIControl*)result;
}


@end

