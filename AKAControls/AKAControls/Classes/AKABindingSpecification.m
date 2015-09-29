//
//  AKABindingSpecification.m
//  AKAControls
//
//  Created by Michael Utech on 26.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#include <objc/runtime.h>
@import AKACommons.AKALog;

#import "AKABindingSpecification.h"
#import "AKABindingProvider.h"

@interface NSDictionary (AKABindingSpecification)

#pragma mark - Convenience

- (BOOL)aka_booleanForKey:(req_NSString)key withDefault:(BOOL)defaultValue;

- (NSDictionary*)aka_dictionaryForKey:(req_NSString)key required:(BOOL)required;

- (Class)aka_classTypeForKey:(req_NSString)key required:(BOOL)required;

- (int)aka_enumValueForKey:(req_NSString)key required:(BOOL)required;

- (int)aka_enumValueForKey:(req_NSString)key defaultValue:(int)defaultValue;

- (AKATypePattern*)aka_classTypePatternForKey:(req_NSString)key required:(BOOL)required;

- (AKABindingProvider*)aka_bindingProviderForKey:(req_NSString)key required:(BOOL)required;

@end

@implementation NSDictionary (AKABindingSpecification)

- (BOOL)aka_booleanForKey:(req_NSString)key withDefault:(BOOL)defaultValue
{
    BOOL result = defaultValue;
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSNumber class]])
    {
        NSNumber* number = value;
        if (kCFNumberCharType != CFNumberGetType((__bridge CFNumberRef)number))
        {
            AKALogWarn(@"Specification %@ at key %@ is expected to be a boolean value, however the value is a number of a different number type. This is most proabably not a problem, but take a look at it to be sure and convert the setting to get rid of this warning.", self, key);
        }
        else if (number != (void*)kCFBooleanTrue &&
                 number != (void*)kCFBooleanFalse)
        {
            // Just checking to see if the test works to detect a BOOL constant, going
            // to remove this later.
            AKALogWarn(@"Specification %@ at key %@ is expected to be a boolean value, however the value is neither YES nor NO (it is of type char though). This is most proabably not a problem, but take a look at it to be sure and convert the setting to get rid of this warning.", self, key);
        }
        result = number.boolValue;
    }
    else
    {
        NSAssert(value == nil, @"Invalid type for specification %@, expected NSNumber(BOOL), got: %@", key, value);
    }
    return result;
}

- (NSDictionary*)aka_dictionaryForKey:(req_NSString)key required:(BOOL)required
{
    NSDictionary* result = nil;
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSDictionary class]])
    {
        result = value;
    }
    else if (value == nil && required)
    {
        NSAssert(NO, @"Dictionary %@ does not contain a value for key %@, expected a dictionary", self, key);
    }
    else if (value != nil)
    {
        NSAssert(NO, @"Invalid type for specification %@, expected NSDictionary, got: %@", key, value);
    }
    return result;
}

- (Class)aka_classTypeForKey:(req_NSString)key required:(BOOL)required
{
    Class result = nil;
    id value = [self objectForKey:key];
    if (object_isClass(value))
    {
        result = (Class)value;
    }
    else if (value == nil && required)
    {
        NSAssert(NO, @"Dictionary %@ does not contain a value for key %@, expected a dictionary", self, key);
    }
    else if (value != nil)
    {
        NSAssert(NO, @"Invalid type for specification %@, expected Class, got: %@", key, value);
    }
    return result;
}

- (int)aka_enumValueForKey:(req_NSString)key required:(BOOL)required
{
    int result = NSNotFound;
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSNumber class]])
    {
        NSNumber* number = value;
        result = number.intValue;
    }
    else if (value != nil)
    {
        NSAssert(NO, @"Invalid type for specification %@, expected NSDictionary, got: %@.", key, value);
    }
    else if (required)
    {
        NSAssert(NO, @"Dictionary %@ does not contain a value for key %@, expected an NSNumber (enumeration value).", self, key);
    }
    return result;
}

- (int)aka_enumValueForKey:(req_NSString)key defaultValue:(int)defaultValue
{
    int result = NSNotFound;
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSNumber class]])
    {
        NSNumber* number = value;
        result = number.intValue;
    }
    else if (value != nil)
    {
        NSAssert(NO, @"Invalid type for specification %@, expected NSDictionary, got: %@.", key, value);
    }
    else
    {
        result = defaultValue;
    }
    return result;
}

- (AKATypePattern*)aka_classTypePatternForKey:(req_NSString)key required:(BOOL)required
{
    AKATypePattern* result = nil;
    id value = [self objectForKey:key];
    if (value != nil)
    {
        if ([value isKindOfClass:[AKATypePattern class]])
        {
            result = value;
        }
        else if ([value isKindOfClass:[NSDictionary class]])
        {
            result = [[AKATypePattern alloc] initWithDictionary:value];
        }
        else if ([value isKindOfClass:[NSArray class]])
        {
            result = [[AKATypePattern alloc] initWithArrayOfClasses:value];
        }
        else if (object_isClass(value))
        {
            result = [[AKATypePattern alloc] initWithClass:value];
        }
        else
        {
            NSAssert(NO, @"Invalid type for specification %@, expected Class, NSArray<Class>, NSDictionary or an instance of AKATypePattern, got: %@", key, value);
        }
    }
    else if (required)
    {
        NSAssert(NO, @"Dictionary %@ does not contain a value for key %@, expected Class, NSArray<Class>, NSDictionary or an instance of AKATypePattern.", self, key);
    }
    return result;
}

- (AKABindingProvider *)aka_bindingProviderForKey:(req_NSString)key required:(BOOL)required
{
    AKABindingProvider* result = nil;
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[AKABindingProvider class]])
    {
        result = value;
    }
    else if (object_isClass(value))
    {
        result = [AKABindingProvider sharedInstanceOfType:(Class)value];
    }
    else if (value != nil)
    {
        NSAssert(NO, @"Invalid type for specification %@, expected a subclass (Class) or instance of AKABindingProvider, got: %@.", key, value);
    }
    else if (required)
    {
        NSAssert(NO, @"Dictionary %@ does not contain a value for key %@, a subclass (Class) or instance of AKABindingProvider.", self, key);
    }
    return result;
}

@end


#pragma mark - AKABindingSpecification
#pragma mark -

@implementation AKABindingSpecification

#pragma mark - Initialization

- (instancetype)                            initWithDictionary:(req_NSDictionary)dictionary
{
    if (self = [super init])
    {
        NSDictionary* binding = [dictionary aka_dictionaryForKey:@"binding" required:NO];
        if (binding != nil)
        {
            _bindingType = [binding aka_classTypeForKey:@"type" required:YES];
        }

        _bindingTargetSpecification = [[AKABindingTargetSpecification alloc] initWithDictionary:[dictionary aka_dictionaryForKey:@"target" required:NO]];

        _bindingSourceSpecification = [[AKABindingExpressionSpecification alloc] initWithDictionary:[dictionary aka_dictionaryForKey:@"source" required:YES]];
    }
    return self;
}

- (void)                                       addToDictionary:(req_NSMutableDictionary)dictionary
{
    NSMutableDictionary* binding = [NSMutableDictionary new];
    if (self.bindingType)
    {
        binding[@"binding"] = self.bindingType;
    }
    dictionary[@"binding"] = binding;

    NSMutableDictionary* target = [NSMutableDictionary new];
    [self.bindingTargetSpecification addToDictionary:target];
    dictionary[@"target"] = target;

    NSMutableDictionary* source = [NSMutableDictionary new];
    [self.bindingSourceSpecification addToDictionary:target];
    dictionary[@"source"] = source;
}

- (opt_AKABindingProvider) bindingProviderForAttributeWithName:(req_NSString)attributeName
{
    return self.bindingSourceSpecification.attributes[attributeName].bindingProvider;
}

- (opt_AKABindingProvider)         bindingProviderForArrayItem
{
    return self.bindingSourceSpecification.arrayItemBindingProvider;
}

@end


#pragma mark - AKABindingTargetSpecification
#pragma mark -

@implementation AKABindingTargetSpecification

- (instancetype)                            initWithDictionary:(req_NSDictionary)specDictionary
{
    if (self = [super init])
    {
        _typePattern = [specDictionary aka_classTypePatternForKey:@"type" required:NO];
    }
    return self;
}

- (void)                                       addToDictionary:(req_NSMutableDictionary)specDictionary
{
    if (self.typePattern)
    {
        NSMutableDictionary* type = [NSMutableDictionary new];
        [self.typePattern addToDictionary:type];
        specDictionary[@"type"] = type;
    }
}

@end


#pragma mark - AKABindingExpressionSpecification
#pragma mark -

@implementation AKABindingExpressionSpecification

- (instancetype)                            initWithDictionary:(req_NSDictionary)specDictionary
{
    if (self = [super init])
    {
        NSDictionary* primary = [specDictionary aka_dictionaryForKey:@"primaryExpression" required:NO];
        _expressionType = [primary aka_enumValueForKey:@"expressionType" defaultValue:AKABindingExpressionTypeAny];

        _arrayItemBindingProvider = [specDictionary aka_bindingProviderForKey:@"arrayItemBindingProvider"
                                                                 required:NO];
        NSMutableDictionary* attributeSpecifications = [NSMutableDictionary new];
        NSDictionary* attributes = [specDictionary aka_dictionaryForKey:@"attributes" required:NO];
        [attributes enumerateKeysAndObjectsUsingBlock:
         ^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop)
         {
             NSAssert([key isKindOfClass:[NSString class]],
                      @"Binding expression attribute specification key is required to be a string, the name of the attribute or '*' representing all unspecified attributes: %@", key);
             NSString* attributeName = key;

             NSAssert([obj isKindOfClass:[NSDictionary class]] | [obj isKindOfClass:[NSNumber class]],
                      @"Binding expression attribute specification is required to be a dictionary or a boolean value indicating whether the attribute is supported");
             NSDictionary* attributeSpec = ([obj isKindOfClass:[NSDictionary class]]
                                            ? obj
                                            : @{ @"expressionType": @(AKABindingExpressionTypeNone),
                                                 @"suported":       @NO,
                                                 });
             attributeSpecifications[attributeName] = [[AKABindingAttributeSpecification alloc] initWithDictionary:attributeSpec];
         }];
        _attributes = [NSDictionary dictionaryWithDictionary:attributeSpecifications];

        NSAssert(_arrayItemBindingProvider == nil || ((AKABindingExpressionTypeArray & _expressionType) == 0), @"Array item binding provider specified even though the binding expressions type constraints exclude the array binding type. This is by itself not a problem but constitutes an inconsisten binding specification. Please review the specification %@", self);

    }
    return self;
}

- (void)                                       addToDictionary:(req_NSMutableDictionary)specDictionary
{
    NSMutableDictionary* attributes = [NSMutableDictionary new];
    [self.attributes enumerateKeysAndObjectsUsingBlock:
     ^(NSString * _Nonnull key, AKABindingAttributeSpecification * _Nonnull obj, BOOL * _Nonnull stop)
     {
         NSMutableDictionary* value = [NSMutableDictionary new];
         [obj addToDictionary:value];
         attributes[key] = value;

    }];
    specDictionary[@"attributes"] = attributes;

    NSMutableDictionary* primaryExpression = [NSMutableDictionary new];
    primaryExpression[@"expressionType"] = @(self.expressionType);
    if (self.arrayItemBindingProvider)
    {
        primaryExpression[@"arrayItemBindingProvider"] = self.arrayItemBindingProvider;
    }
    specDictionary[@"primaryExpression"] = primaryExpression;
}

@end


#pragma mark - AKABindingAttributeSpecification
#pragma mark -

@implementation AKABindingAttributeSpecification

- (instancetype)                            initWithDictionary:(req_NSDictionary)specDictionary
{
    AKABindingExpressionType expressionType = [specDictionary aka_enumValueForKey:@"expressionType" defaultValue:AKABindingExpressionTypeAny];
    NSDictionary* attributes = [specDictionary aka_dictionaryForKey:@"attributes"
                                                           required:YES];
    NSDictionary* adhocSpec =
    @{ @"source":
           @{ @"primaryExpression": @{ @"expressionType": @(expressionType) },
              @"attributes": attributes }
       };

    if (self = [super initWithDictionary:adhocSpec])
    {
        _required = [specDictionary aka_booleanForKey:@"required" withDefault:NO];
        _attributeUse = [specDictionary aka_enumValueForKey:@"use" required:YES];
        switch (self.attributeUse)
        {
            case AKABindingAttributeUseAsBindingProperty:
            {
                _bindingPropertyName = [specDictionary objectForKey:@"bindingProperty"];
                break;
            }
            default:
                self = nil;
        }
    }

    return self;
}

- (void)                                       addToDictionary:(req_NSMutableDictionary)specDictionary
{
    [super addToDictionary:specDictionary];

    specDictionary[@"required"] = @(self.required);
}

@end


#pragma mark - AKATypePattern
#pragma mark -

@implementation AKATypePattern

// TODO: refactor this (create a cluster of sub types to save memory and make checking more efficient).

+ (NSSet*)               setOfClassesFromClassOrArrayOfClasses:(id)object
{
    NSSet* result = nil;
    if ([object isKindOfClass:[NSArray class]])
    {
        result = [NSSet setWithArray:object];
    }
    else if (object_isClass(object))
    {
        result = [NSSet setWithObject:object];
    }
    else if ([object isKindOfClass:[NSSet class]])
    {
        result = object;
    }
    else if (object != nil)
    {
        NSAssert(NO, @"Expected a Class or NSArray for AKATypePattern, got %@", object);
    }
    return result;
}

+ (NSSet*)            setOfValueTypeFromStringOrArrayOfStrings:(id)object
{
    NSSet* result = nil;
    if ([object isKindOfClass:[NSArray class]])
    {
        result = [NSSet setWithArray:object];
    }
    else if ([object isKindOfClass:[NSString class]])
    {
        result = [NSSet setWithObject:object];
    }
    else if ([object isKindOfClass:[NSSet class]])
    {
        result = object;
    }
    else if (object != nil)
    {
        NSAssert(NO, @"Expected a Class or NSArray for AKATypePattern, got %@", object);
    }
    return result;
}

- (instancetype)                                 initWithClass:(Class)type
{
    if (self = [self init])
    {
        _acceptedTypes = [NSSet setWithObject:type];
    }
    return self;
}

- (instancetype)                        initWithArrayOfClasses:(req_NSArray)array
{
    if (self = [self init])
    {
        // TODO: check array items
        _acceptedTypes = [NSSet setWithArray:array];
    }
    return self;
}

- (instancetype)                            initWithDictionary:(req_NSDictionary)dictionary
{
    if (self = [self init])
    {
        _acceptedTypes = [AKATypePattern setOfClassesFromClassOrArrayOfClasses:[dictionary objectForKey:@"acceptedTypes"]];
        _rejectedTypes = [AKATypePattern setOfClassesFromClassOrArrayOfClasses:[dictionary objectForKey:@"rejectedTypes"]];
        _acceptedValueTypes = [AKATypePattern setOfValueTypeFromStringOrArrayOfStrings:[dictionary objectForKey:@"acceptedValueTypes"]];
        _rejectedValueTypes = [AKATypePattern setOfValueTypeFromStringOrArrayOfStrings:[dictionary objectForKey:@"acceptedValueTypes"]];
    }
    return self;
}

- (void)                                       addToDictionary:(req_NSMutableDictionary)specDictionary
{
    if (self.acceptedTypes.count > 0)
    {
        specDictionary[@"acceptedTypes"] = self.acceptedTypes.allObjects;
    }
    if (self.rejectedTypes.count > 0)
    {
        specDictionary[@"rejectedTypes"] = self.rejectedTypes.allObjects;
    }
    if (self.acceptedValueTypes.count > 0)
    {
        specDictionary[@"acceptedValueTypes"] = self.acceptedValueTypes;
    }
    if (self.rejectedValueTypes.count > 0)
    {
        specDictionary[@"rejectedValueTypes"] = self.rejectedValueTypes;
    }
}

- (BOOL)                                         matchesObject:(id)object
{
    BOOL result = YES;

    if (object != nil)
    {
        for (Class type in self.rejectedTypes)
        {
            if ([[object class] isSubclassOfClass:type])
            {
                return NO;
            }
        }
        if (self.acceptedTypes.count > 0)
        {
            result = NO;
            for (Class type in self.acceptedTypes)
            {
                if ([[object class] isSubclassOfClass:type])
                {
                    result = YES;
                    break;
                }
            }
        }
        if (result && (self.rejectedValueTypes.count > 0 || self.acceptedValueTypes.count > 0))
        {
            if ([object isKindOfClass:[NSValue class]])
            {
                NSValue* value = object;
                NSString* objcType = @(value.objCType);
                if ([self.rejectedValueTypes containsObject:objcType])
                {
                    return NO;
                }
                else if (self.acceptedValueTypes.count > 0)
                {
                    return [self.acceptedValueTypes containsObject:objcType];
                }
            }
        }
    }

    return result;
}

@end