//
//  AKATapGestureRecognizerBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 28.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKATapGestureRecognizerBinding.h"
#import "AKABinding_Protected.h"

@implementation AKATapGestureRecognizerBinding

+ (AKABindingSpecification*)                         specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":                  [AKATapGestureRecognizerBinding class],
           @"targetType":                   [AKAProperty class],
           @"expressionType":               @(AKABindingExpressionTypeNone),
           @"attributes":                   @{
                   @"target":                   @{
                           @"use":              @(AKABindingAttributeUseBindToBindingProperty),
                           @"expressionType":   @(AKABindingExpressionTypeAnyKeyPath),
                           // target is required to have a defined value but defaults to the root data context,
                           // so the corresponding target attribute is not required:
                           @"required":         @NO
                           },
                   @"action":                   @{
                           @"use":              @(AKABindingAttributeUseBindToBindingProperty),
                           @"expressionType":   @(AKABindingExpressionTypeString),
                           @"bindingProperty":  @"actionSelectorName",
                           @"required":         @YES
                           },
                   @"enabled":              @{
                           @"use":              @(AKABindingAttributeUseBindToTargetProperty),
                           @"expressionType":   @(AKABindingExpressionTypeBoolean)
                           },
                   @"cancelsTouchesInView": @{
                           @"use":              @(AKABindingAttributeUseBindToTargetProperty),
                           @"expressionType":   @(AKABindingExpressionTypeBoolean)
                           },
                   @"delaysTouchesBegan":   @{
                           @"use":              @(AKABindingAttributeUseBindToTargetProperty),
                           @"expressionType":   @(AKABindingExpressionTypeBoolean)
                           },
                   @"delaysTouchesEnded":   @{
                           @"use":              @(AKABindingAttributeUseBindToTargetProperty),
                           @"expressionType":   @(AKABindingExpressionTypeBoolean)
                           },
                   @"delegate":             @{
                           @"use":              @(AKABindingAttributeUseBindToTargetProperty),
                           @"expressionType":   @(AKABindingExpressionTypeAnyKeyPath)
                           }
                   },
           @"allowUnspecifiedAttributes":   @YES
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

+ (AKABindingAttributeSpecification*)                         defaultAttributeSpecification
{
    static AKABindingAttributeSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{

        NSDictionary* spec = @{ @"use": @(AKABindingAttributeUseBindToTargetProperty) };
        result = [[AKABindingAttributeSpecification alloc] initWithDictionary:spec basedOn:[AKAPropertyBinding specification]];
    });

    return result;
}

#pragma mark - Initialization

- (AKAProperty *)      defaultBindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                                 context:(req_AKABindingContext)bindingContext
                                          changeObserver:(AKAPropertyChangeObserver)changeObserver
                                                   error:(out_NSError)error
{
    (void)bindingExpression;
    (void)bindingContext;
    (void)error;

    AKAProperty* result = [AKAProperty propertyOfWeakKeyValueTarget:self
                                                            keyPath:@"syntheticTargetValue"
                                                     changeObserver:changeObserver];
    return result;
}

- (BOOL)initializeUnspecifiedAttribute:(req_NSString)attributeName
                   attributeExpression:(req_AKABindingExpression)attributeExpression
                        bindingContext:(req_AKABindingContext)bindingContext
                                 error:(out_NSError)error
{
    return [self initializeTargetPropertyBindingAttribute:attributeName
                                        withSpecification:[self.class defaultAttributeSpecification]
                                      attributeExpression:attributeExpression
                                           bindingContext:bindingContext error:error];
}

#pragma mark - Conversion

- (BOOL)                              convertSourceValue:(id __unused)sourceValue
                                           toTargetValue:(id  _Nullable __autoreleasing *)targetValueStore
                                                   error:(NSError *__autoreleasing  _Nullable *)error
{
    (void)error;

    if (self.syntheticTargetValue == nil)
    {
        self.syntheticTargetValue = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(handleGestureRecognizerAction:)];
    }

    if (targetValueStore != nil)
    {
        *targetValueStore = self.syntheticTargetValue;
    }

    return YES;
}

#pragma mark - Change Propagation

- (BOOL)           shouldUpdateSourceValueForTargetValue:(opt_id)oldTargetValue
                                                changeTo:(opt_id)newTargetValue
                                             validatedTo:(opt_id)targetValue
{
    (void)oldTargetValue;
    (void)newTargetValue;
    (void)targetValue;

    // No source value (expression type is NONE)
    return NO;
}

#pragma mark - Properties

- (NSObject *)target
{
    NSObject* result = _target;
    if (result == nil)
    {
        // If no target was specified, use $root (the root data context which typically is the view
        // controller) as default:
        result = [self.bindingContext rootDataContextValueForKeyPath:nil];
    }
    return result;
}

- (SEL)action
{
    return self.actionSelectorName.length > 0 ? NSSelectorFromString(self.actionSelectorName) : NULL;
}

#pragma mark - Handling Actions

- (IBAction)handleGestureRecognizerAction:(id)sender
{
    // We might not want/need to require this, check if it first happens to fail:
    NSAssert(sender == self.syntheticTargetValue,
             @"Unexpected sender %@, expected %@", sender, self.syntheticTargetValue);

    id target = self.target;
    SEL action = self.action;
    if ([target respondsToSelector:action])
    {
        IMP imp = [target methodForSelector:action];
        void (*func)(id, SEL, id) = (void *)imp;
        func(target, action, sender);
    }
}

@end
