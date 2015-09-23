//
//  AKABindingProviderRegistry.m
//  AKAControls
//
//  Created by Michael Utech on 20.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKALog;

#import "AKABindingProvider.h"
#import "AKABindingProviderRegistry.h"

typedef NSMutableDictionary<NSString*, NSMutableSet<Class>*>* _TypesBySelectorMap;
typedef NSMutableDictionary<NSString*, AKABindingProvider*>* _BindingBySelectorMap;
typedef NSMutableDictionary<Class, _BindingBySelectorMap>* _BindingBySelectorMapByTypeMap;

@interface AKABindingProviderRegistry()

@property(nonatomic, readonly) _TypesBySelectorMap            typesBySelector;
@property(nonatomic, readonly) _BindingBySelectorMapByTypeMap selectorMapsByType;

@end

@implementation AKABindingProviderRegistry

- (void)registerBindingProvider:(req_AKABindingProvider)provider
                    forProperty:(req_SEL)selector
                         inType:(req_Class)type
{
    NSAssert([NSThread isMainThread],
             @"Binding providers can only be registered from the main thread");
    NSParameterAssert(provider != nil);
    NSParameterAssert(selector != nil);
    NSParameterAssert(type != nil);

    NSString* key = [self _keyForProperty:selector];

    AKABindingProvider* exisingProvider = [self bindingProviderForProperty:selector
                                                                    inType:type];
    if (exisingProvider == nil)
    {
        NSMutableSet* matchingTypes = self.typesBySelector[key];
        if (matchingTypes == nil)
        {
            matchingTypes = [NSMutableSet new];
            self.typesBySelector[key] = matchingTypes;
        }

        [self _registerBindingProvider:provider
                                forKey:key
                                inType:type
                     withMatchingTypes:matchingTypes];
    }
    else if (provider == exisingProvider)
    {
        AKALogWarn(@"Attempt to register binding provider %@ for property %@ in %@, but the provider is already registered. This is not critical but hints to a potential bug.", provider, key, NSStringFromClass(type));
    }
    else
    {
        NSString* message = [NSString stringWithFormat:@"Attempt to register binding provider '%@' for property '%@' in type '%@', but there is already another provider (%@) registered for the property in the type or one of its super classes. This is probably caused by a conflicting definition of the property.", provider, key, NSStringFromClass(type), exisingProvider];
        AKALogError(@"%@", message);
        @throw ([NSException exceptionWithName:@"Conflicting binding provider registration"
                                        reason:message
                                      userInfo:nil]);
    }
}

- (AKABindingProvider*)bindingProviderForProperty:(req_SEL)selector
                                           inType:(req_Class)type
{
    NSString* key = [self _keyForProperty:selector];

    return [self _bindingProviderForKey:key inType:type];
}

- (AKABindingProvider*)_bindingProviderForKey:(NSString*)key
                                       inType:(req_Class)type
{
    NSAssert([NSThread isMainThread],
             @"Binding providers can only be accessed from the main thread");
    NSParameterAssert(key.length > 0);
    NSParameterAssert(type != nil);

    AKABindingProvider* result = self.selectorMapsByType[type][key];

    if (!result)
    {
        // The following implementation is not very efficient. However, there should
        // be no reason to search a binding provider for a property in a type, if it
        // is not registered for either the type of a super class of the type. If it
        // is registered for a super type, the following code will register the binding
        // for all types in the inheritance chain of the specified type, so that the
        // next lookup will succeed directly.
        //
        // If lookup with negative results occur frequently, we can also cache negative
        // results (as [NSNull null] values for results) to speed up the process.

        NSMutableSet<Class>* matchingTypes = self.typesBySelector[key];
        result = [self _bindingProviderForPropertyKey:key
                                              inType:type
                                   withMatchingTypes:matchingTypes];
    }

    return result;
}





#pragma mark - Tools

- (req_NSString)_keyForProperty:(req_SEL)selector
{
    NSString* result = NSStringFromSelector(selector);

#if DEBUG
    if (![result hasSuffix:@"Binding"])
    {
        AKALogWarn(@"IB binding property names should end in \"Binding\" to clearly indicate the usage and to make it less likely that a binding property added to a view by a category conflicts with native properties or such added by other modules.\n\nPlease consider renaming the property \"%@\" accordingly.", result);
    }
#endif

    return result;
}

- (void)_registerBindingProvider:(req_AKABindingProvider)provider
                          forKey:(NSString*)key
                          inType:(req_Class)type
               withMatchingTypes:(NSMutableSet<Class>*)matchingTypes
{
    _BindingBySelectorMap selectorMap = self.selectorMapsByType[type];
    if (selectorMap == nil)
    {
        selectorMap = [NSMutableDictionary new];
        [self.selectorMapsByType setObject:selectorMap forKey:(id)type];
    }
    [selectorMap setObject:provider forKeyedSubscript:key];
    [matchingTypes addObject:type];
}

- (AKABindingProvider*)_bindingProviderForPropertyKey:(NSString*)key
                                               inType:(req_Class)type
                                    withMatchingTypes:(NSMutableSet<Class>*)matchingTypes
{
    AKABindingProvider* result = nil;
    if (type != nil)
    {
        if ([matchingTypes containsObject:type])
        {
            result = self.selectorMapsByType[type][key];
        }
        else
        {
            result = [self _bindingProviderForPropertyKey:key
                                                   inType:[type superclass]
                                        withMatchingTypes:matchingTypes];
            if (result)
            {
                [self _registerBindingProvider:result forKey:key
                                        inType:type
                             withMatchingTypes:matchingTypes];
            }
        }
    }
    return result;
}

@end
