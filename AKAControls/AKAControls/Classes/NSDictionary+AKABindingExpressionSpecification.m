//
//  NSDictionary+AKABindingExpressionSpecification.m
//  AKAControls
//
//  Created by Michael Utech on 25.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "NSDictionary+AKABindingExpressionSpecification.h"
#include <objc/runtime.h>

@interface NSObject (AKAExtendedTypeConformance)

- (BOOL)aka_class:(Class)candidate isSubClassOfAnyClassIn:(NSArray<Class>*)types;

@end

@implementation NSObject (AKAExtendedTypeConformance)

- (BOOL)                    aka_class:(Class)candidate
               isSubClassOfAnyClassIn:(NSArray<Class>*)types
{
    BOOL result = NO;

    for (Class type in types)
    {
        result = [candidate isSubclassOfClass:type];
        if (result)
        {
            break;
        }
    }
    return result;
}

@end

@implementation NSDictionary (AKABindingExpressionSpecification)

static NSString* const kTypeKey = @"type";
static NSString* const kAcceptKey = @"accept";
static NSString* const kRejectKey = @"reject";

static NSString* const kAcceptUnspecifiedAttributesKey = @"acceptUnspecifiedAttributes";
static NSString* const kAttributesKey = @"attributes";

#pragma mark - Primary Expression Specification

/**
 * Tests whether the specified candidate type conforms to the type
 * specification in this dictionary.
 *
 * The type specification can be a class or an array of classes to accept
 * or a dictionary with either or any of the keys "accept" and "reject", which
 * likewise can be associated with a class or an array of classes, like so:
 * @code
 * @"type": [NSNumber class],
 * @"type": @[ [NSNumber class], [NSString class] ],
 * @"type": @{ @"accept": @[ [NSValue class], [NSString class] ],
 *             @"reject":  @[ [NSMutableString class], [NSNumber class] ] }
 * @endcode
 *
 * @param candidateType the type to test
 *
 * @return YES if the type conforms to any specified "accept" rule and no
 *         specified "reject" rule.
 */
- (BOOL)aka_typeConformsToSpecification:(Class)candidateType
{
    BOOL result = YES;

    id typeSpec = [self objectForKey:kTypeKey];
    if (object_isClass(typeSpec))
    {
        result = [candidateType isSubclassOfClass:typeSpec];
    }
    else if ([typeSpec isKindOfClass:[NSArray class]])
    {
        result = [self aka_class:candidateType isSubClassOfAnyClassIn:typeSpec];
    }
    else if ([typeSpec isKindOfClass:[NSDictionary class]])
    {
        id rejectSpec = [typeSpec objectForKey:kRejectKey];
        if (object_isClass(rejectSpec))
        {
            result = ![candidateType isSubclassOfClass:rejectSpec];
        }
        else if ([rejectSpec isKindOfClass:[NSArray class]])
        {
            result = ![self aka_class:candidateType isSubClassOfAnyClassIn:rejectSpec];
        }

        if (result)
        {
            id acceptSpec = [typeSpec objectForKey:kAcceptKey];
            if (object_isClass(acceptSpec))
            {
                result = [candidateType isSubclassOfClass:acceptSpec];
            }
            else if ([acceptSpec isKindOfClass:[NSArray class]])
            {
                result = [self aka_class:candidateType isSubClassOfAnyClassIn:acceptSpec];
            }
        }
    }
    return result;
}

#pragma mark - Attribute Expression Specification

- (BOOL)aka_acceptsUnspecifiedAttributes
{
    return [self aka_booleanForKey:kAcceptUnspecifiedAttributesKey
                       withDefault:NO];
}

- (NSDictionary*)aka_specificationForAttributeWithName:(req_NSString)attributeName
{
    NSDictionary* result = nil;
    NSDictionary* attributes = [self aka_dictionaryForKey:kAttributesKey];
    if (attributes)
    {
        result = [self aka_dictionaryForKey:attributeName];
    }
    return result;
}

#pragma mark - Convenience

- (BOOL)aka_booleanForKey:(req_NSString)key withDefault:(BOOL)defaultValue
{
    BOOL result = defaultValue;
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSNumber class]])
    {
        result = ((NSNumber*)value).boolValue;
    }
    else
    {
        NSAssert(value == nil, @"Invalid type for specification %@, expected NSNumber(BOOL), got: %@", key, value);
    }
    return result;
}

- (NSDictionary*)aka_dictionaryForKey:(req_NSString)key
{
    NSDictionary* result = nil;
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSDictionary class]])
    {
        result = value;
    }
    else
    {
        NSAssert(value == nil, @"Invalid type for specification %@, expected NSDictionary, got: %@", key, value);
    }
    return result;
}

@end
