//
//  AKABindingProviderBase.m
//  AKAControls
//
//  Created by Michael Utech on 20.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#include <objc/runtime.h>

@import AKACommons.NSString_AKATools;
@import AKACommons.AKAErrors;

#import "AKABindingProvider.h"
#import "AKABindingExpression_Internal.h"

#import "UIView+AKABindingSupport.h"

@implementation AKABindingProvider

#pragma mark - Initialization

+ (instancetype)sharedInstance
{
    // AKABindingProvider should not be instantiated directly, sub classes are not supposed
    // to call [super sharedInstance]
    AKAErrorAbstractMethodImplementationMissing();
}

+ (instancetype)sharedInstanceOfType:(Class)type
{
    NSParameterAssert(type != nil);
    NSParameterAssert([type isSubclassOfClass:[AKABindingProvider class]]);

    AKABindingProvider* result = nil;

    if ([type isSubclassOfClass:[AKABindingProvider class]])
    {
        Class superType = [type superclass];
        if ([type methodForSelector:@selector(sharedInstance)] != [superType methodForSelector:@selector(sharedInstance)])
        {
            result = [type sharedInstance];
        }
        else
        {
            NSAssert(@NO, @"AKABindingProvider class %@ fails to redefine static initializer %@. This will probably cause trouble. Please correct this, or the assumption that all binding providers are stateless singletons", NSStringFromClass(type), NSStringFromSelector(@selector(sharedInstance)));
            result = [[type alloc] init];
        }
    }
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
            NSAssert(@NO, @"Unexpected provider specification %@, expected an instance or sub class of AKABindingProvider", result);
        }
    }
    return result;
}

#pragma mark - Interface Builder Property Support

- (NSString *)       bindingExpressionTextForSelector:(SEL)selector
                                               inView:(UIView *)view
{
    AKABindingExpression* expression = [view aka_bindingExpressionForProperty:selector];

    NSAssert(expression.bindingProvider == self,
             @"Binding expression %@.%@ was created by a different provider %@", view, NSStringFromSelector(selector), expression.bindingProvider);

    return expression.text;
}

- (void)                     setBindingExpressionText:(req_NSString)bindingExpressionText
                                          forSelector:(req_SEL)selector
                                               inView:(req_UIView)view
{
    NSParameterAssert(bindingExpressionText != nil);
    NSParameterAssert(selector != nil);
    NSParameterAssert(view != nil);

    NSString* text = [bindingExpressionText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (text.length > 0)
    {
        NSError* error = nil;
        AKABindingExpression* bindingExpression;

        bindingExpression = [AKABindingExpression bindingExpressionWithString:bindingExpressionText
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
    AKATypePattern* targetTypePattern = self.specification.bindingTargetSpecification.typePattern;
    NSAssert(targetTypePattern == nil || [targetTypePattern matchesObject:bindingTarget], @"bindingTarget %@ does not match the type constraint %@ defined by the binding provider's specification.", bindingTarget, targetTypePattern);

    Class bindingType = self.specification.bindingType;
    NSAssert([bindingType isSubclassOfClass:[AKABinding class]], @"Binding type %@ defined by the binding provider's specification is not a subclass of AKABindingType", NSStringFromClass(bindingType));

    AKABinding* binding = [[bindingType alloc] initWithTarget:bindingTarget
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

- (void)                                 setupBinding:(req_AKABinding)binding
                                       withAttributes:(opt_AKABindingExpressionAttributes)attributes
                                              context:(req_AKABindingContext)bindingContext
{
    [attributes enumerateKeysAndObjectsUsingBlock:
     ^(req_NSString             attributeName,
       req_AKABindingExpression attribute,
       outreq_BOOL              stop)
     {
         AKABindingAttributeSpecification* attributeSpec =
         self.specification.bindingSourceSpecification.attributes[attributeName];

         if (attributeSpec)
         {
             switch (attributeSpec.attributeUse)
             {
                 case AKABindingAttributeUseAsBindingProperty:
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
    return [self.specification bindingProviderForArrayItem];
}

@end
