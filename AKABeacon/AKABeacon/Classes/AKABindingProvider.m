//
//  AKABindingProviderBase.m
//  AKABeacon
//
//  Created by Michael Utech on 20.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#include <objc/runtime.h>

@import AKACommons.NSString_AKATools;
@import AKACommons.AKAErrors;
@import AKACommons.NSObject_AKAAssociatedValues;
@import AKACommons.AKALog;

#import "AKABindingProvider.h"
#import "AKABindingExpression_Internal.h"

#import "UIView+AKABindingSupport.h"


@implementation AKABindingProvider

#pragma mark - Initialization

+ (instancetype)sharedInstance
{
    // Sub classes have to override this method and not call [super sharedInstance]
    AKAErrorAbstractMethodImplementationMissing();
}

+ (instancetype)sharedInstanceOfType:(Class)type
{
    NSParameterAssert(type != nil);
    NSParameterAssert([type isSubclassOfClass:[AKABindingProvider class]]);

#if! TARGET_INTEFACE_BUILDER
    NSAssert([type              methodForSelector:@selector(sharedInstance)] !=
             [[type superclass] methodForSelector:@selector(sharedInstance)],
             @"AKABindingProvider class %@ fails to redefine static initializer %@, the shared instance of its super class %@ will be used instead if assertions are disabled. This will likely cause trouble.",
             NSStringFromClass(type),
             NSStringFromSelector(@selector(sharedInstance)),
             NSStringFromClass([type superclass]));
#endif

    AKABindingProvider* result = [type sharedInstance];
    return result;
}

+ (instancetype)sharedInstanceForSpecificationItem:(id)spec
{
    AKABindingProvider* result = nil;
    if (spec != nil)
    {
        if ([spec isKindOfClass:[AKABindingProvider class]])
        {
            result = spec;
        }
        else if (object_isClass(spec))
        {
            result = [AKABindingProvider sharedInstanceOfType:spec];
        }
        else
        {
            NSAssert(NO, @"Unexpected provider specification %@, expected an instance or sub class of AKABindingProvider", result);
        }
    }
    return result;
}

#pragma mark - Interface Builder Property Support

- (NSString *)       bindingExpressionTextForSelector:(SEL)selector
                                               inView:(UIView *)view
{
    AKABindingExpression* expression = [view aka_bindingExpressionForProperty:selector];

    AKABindingProvider* bindingProvider = expression.bindingProvider;
    NSAssert(bindingProvider == self,
             @"Binding expression %@.%@ was created by a different provider %@",
             view, NSStringFromSelector(selector), bindingProvider);
    (void)bindingProvider;

    return expression.text;
}

- (void)                     setBindingExpressionText:(opt_NSString)bindingExpressionText
                                          forSelector:(req_SEL)selector
                                               inView:(req_UIView)view
{
    NSParameterAssert(selector != nil);
    NSParameterAssert(view != nil);

    NSString* text = [bindingExpressionText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (text.length > 0)
    {
        NSError* error = nil;
        AKABindingExpression* bindingExpression;

        bindingExpression = [AKABindingExpression bindingExpressionWithString:(req_NSString)text
                                                              bindingProvider:self
                                                                        error:&error];
        if (bindingExpression == nil)
        {
            NSString* message = [NSString stringWithFormat:@"Attempt to set invalid binding expression for property %@ in view %@", NSStringFromSelector(selector), view];

#if TARGET_INTEFACE_BUILDER
            AKALogError(@"%@: %@", message, error.localizedDescription);
#else
            @throw ([NSException exceptionWithName:message reason:error.localizedDescription userInfo:nil]);
#endif
        }

        [view aka_setBindingExpression:bindingExpression forProperty:selector];
    }
}

#pragma mark - Creating Bindings

- (req_AKABinding)  bindingWithTarget:(req_id)bindingTarget
                           expression:(req_AKABindingExpression)bindingExpression
                              context:(req_AKABindingContext)bindingContext
                             delegate:(opt_AKABindingDelegate)delegate
{
    AKABinding* binding = [self createBindingWithTarget:bindingTarget
                                             expression:bindingExpression
                                                context:bindingContext
                                               delegate:delegate];
    if (binding)
    {
        [self setupBinding:binding
            withAttributes:bindingExpression.attributes
                   context:bindingContext];
    }

    return binding;
}

- (req_AKABinding)createBindingWithTarget:(req_id)bindingTarget
                               expression:(req_AKABindingExpression)bindingExpression
                                  context:(req_AKABindingContext)bindingContext
                                 delegate:(opt_AKABindingDelegate)delegate
{
    AKATypePattern* targetTypePattern = self.specification.bindingTargetSpecification.typePattern;
    NSAssert(targetTypePattern == nil || [targetTypePattern matchesObject:bindingTarget], @"bindingTarget %@ does not match the type constraint %@ defined by the binding provider's specification.", bindingTarget, targetTypePattern);
    (void)targetTypePattern; // prevent unused warning in release build

    Class bindingType = self.specification.bindingType;
    NSAssert([bindingType isSubclassOfClass:[AKABinding class]], @"Binding type %@ defined by the binding provider's specification is not a subclass of AKABindingType", NSStringFromClass(bindingType));

    AKABinding* binding = [[bindingType alloc] initWithTarget:bindingTarget
                                                   expression:bindingExpression
                                                      context:bindingContext
                                                     delegate:delegate
                                                        error:nil];
    return binding;
}

- (void)                                 setupBinding:(req_AKABinding)binding
                                       withAttributes:(opt_AKABindingExpressionAttributes)attributes
                                              context:(req_AKABindingContext)bindingContext
{
    [attributes enumerateKeysAndObjectsUsingBlock:
     ^(req_NSString             attributeName,
       req_AKABindingExpression attribute,
       outreq_BOOL              stop)
     {
         (void)stop;
         
         AKABindingAttributeSpecification* attributeSpec =
         self.specification.bindingSourceSpecification.attributes[attributeName];

         if (attributeSpec)
         {
             switch (attributeSpec.attributeUse)
             {
                 case AKABindingAttributeUseAssignValueToBindingProperty:
                 {
                     NSString* bindingPropertyName = attributeSpec.bindingPropertyName;
                     if (bindingPropertyName == nil)
                     {
                         bindingPropertyName = attributeName;
                     }
                     if (attribute)
                     {
                         id value = [attribute bindingSourceValueInContext:bindingContext];
                         [binding setValue:value forKey:bindingPropertyName];
                     }
                     break;
                 }

                 case AKABindingAttributeUseAssignExpressionToBindingProperty:
                 {
                     NSString* bindingPropertyName = attributeSpec.bindingPropertyName;
                     if (bindingPropertyName == nil)
                     {
                         bindingPropertyName = attributeName;
                     }
                     if (attribute)
                     {
                         [binding setValue:attribute forKey:bindingPropertyName];
                     }
                     break;
                 }

                 case AKABindingAttributeUseBindToBindingProperty:
                 {
                     NSString* bindingPropertyName = attributeSpec.bindingPropertyName;
                     if (bindingPropertyName == nil)
                     {
                         bindingPropertyName = attributeName;
                     }
                     if (attribute)
                     {
                         AKABindingProvider* provider = attributeSpec.bindingProvider;
                         if (provider != nil)
                         {
                             AKAProperty* targetProperty = [AKAProperty propertyOfWeakKeyValueTarget:binding
                                                                                             keyPath:bindingPropertyName
                                                                                      changeObserver:nil];
                             AKABinding* propertyBinding = [provider bindingWithTarget:targetProperty
                                                                            expression:attribute
                                                                               context:bindingContext
                                                                              delegate:nil];
                             // Keep the property binding alive
                             // TODO: Generalize binding ownership (get rid of associative storage or at least of this local hack).
                             // TODO: Check for retain cycles
                             [binding aka_setAssociatedValue:propertyBinding
                                                      forKey:[NSString stringWithFormat:@"_%@_binding", bindingPropertyName]];
                         }
                     }
                     break;
                 }

                 default:
                     break;
             }
         }
     }];
}

#pragma mark - Binding Expression Validation

- (opt_AKABindingProvider)  providerForAttributeNamed:(req_NSString)attributeName
{
    return [self.specification bindingProviderForAttributeWithName:attributeName];
}

- (opt_AKABindingProvider) providerForBindingExpressionInPrimaryExpressionArray
{
    return self.specification.arrayItemBindingProvider;
}

@end
