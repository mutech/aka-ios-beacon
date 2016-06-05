//
//  AKABindingSpecification.m
//  AKABeacon
//
//  Created by Michael Utech on 26.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#include <objc/runtime.h>

#import "AKALog.h"
#import "NSObject+AKAConcurrencyTools.h"

#import "AKABindingSpecification.h"
#import "AKABindingExpression_Internal.h"
#import "AKABinding.h"
#import "AKABindingErrors.h"

NSString*const kAKABindingSpecificationBindingTypeKey = @"bindingType";
NSString*const kAKABindingSpecificationBindingTargetSpecificationKey = @"targetType";
NSString*const kAKABindingSpecificationBindingExpressionType = @"expressionType";
NSString*const kAKABindingSpecificationArrayItemBindingProviderTypeKey = @"arrayItemBindingType";
NSString*const kAKABindingSpecificationAttributesKey = @"attributes";

NSString*const kAKABindingAttributesSpecificationRequiredKey = @"required";
NSString*const kAKABindingAttributesSpecificationPrimaryKey = @"primary";
NSString*const kAKABindingAttributesSpecificationUseKey = @"use";
NSString*const kAKABindingAttributesSpecificationBindingPropertyKey = @"bindingProperty";


#pragma mark - AKABindingSpecification
#pragma mark -

@implementation AKABindingSpecification

#pragma mark - Initialization

- (instancetype)                     specificationExtendedWith:(req_AKABindingSpecification)extension
{
    req_NSMutableDictionary extensionDictionary = [NSMutableDictionary new];
    [extension addToDictionary:extensionDictionary];
    return [[AKABindingSpecification alloc] initWithDictionary:extensionDictionary basedOn:self];
}

- (instancetype)                            initWithDictionary:(req_NSDictionary)dictionary
{
    return [self initWithDictionary:dictionary basedOn:nil];
}

- (instancetype)                            initWithDictionary:(req_NSDictionary)dictionary
                                                       basedOn:(opt_AKABindingSpecification)base
{
    return [self initWithDictionary:dictionary
               basedOnSpecification:base
                expressionSpecification:nil];
}

- (instancetype)                            initWithDictionary:(req_NSDictionary)dictionary
                                          basedOnSpecification:(opt_AKABindingSpecification)base
                                       expressionSpecification:(opt_AKABindingExpressionSpecification)expressionBase
{

    if (self = [super init])
    {
        _bindingType = [AKABindingSpecification classTypeForObject:dictionary[kAKABindingSpecificationBindingTypeKey]
                                                          required:NO];
        if (!_bindingType)
        {
            _bindingType = base.bindingType;
        }

        _bindingTargetSpecification =
            [[AKABindingTargetSpecification alloc] initWithDictionary:dictionary
                                                              basedOn:base.bindingTargetSpecification];

        AKABindingExpressionSpecification* mergedExpressionBase = base.bindingSourceSpecification;
        if (mergedExpressionBase && expressionBase)
        {
            // Quick, dirty & inefficient way to merge expression specs, isn't called often, should be fine.
            NSMutableDictionary* exSpec = [NSMutableDictionary new];
            [expressionBase addToDictionary:exSpec];
            mergedExpressionBase = [[AKABindingExpressionSpecification alloc] initWithDictionary:exSpec
                                                                                         basedOn:mergedExpressionBase];
        }
        else if (expressionBase)
        {
            mergedExpressionBase = expressionBase;
        }
        _bindingSourceSpecification =
            [[AKABindingExpressionSpecification alloc] initWithDictionary:dictionary
                                                                  basedOn:mergedExpressionBase];
    }

    return self;
}

#pragma mark - Conversion

- (void)                                       addToDictionary:(req_NSMutableDictionary)dictionary
{
    if (self.bindingType)
    {
        dictionary[kAKABindingSpecificationBindingTypeKey] = self.bindingType;
    }

    [self.bindingTargetSpecification addToDictionary:dictionary];
    [self.bindingSourceSpecification addToDictionary:dictionary];
}

- (opt_Class)bindingTypeForAttributeWithName:(req_NSString)attributeName
{
    return self.bindingSourceSpecification.attributes[attributeName].bindingType;
}


#pragma mark - Dictionary Access Helpers

+ (Class)classTypeForObject:(id)value required:(BOOL)required
{
    Class result = nil;

    if (object_isClass(value))
    {
        result = (Class)value;
    }
    else if (value == nil && required)
    {
        NSAssert(NO, @"Undefined required value, expected a dictionary", self);
    }
    else if (value != nil)
    {
        NSAssert(NO, @"Invalid type for specification item, expected Class, got: %@", value);
    }

    return result;
}

+ (BOOL)booleanForObject:(id)value withDefault:(BOOL)defaultValue
{
    BOOL result = defaultValue;

    if ([value isKindOfClass:[NSNumber class]])
    {
        NSNumber* number = value;

#if DEBUG
        if (kCFNumberCharType != CFNumberGetType((__bridge CFNumberRef)number))
        {
            AKALogWarn(@"Specification item expected to be a boolean value, however the value %@ is a number of a different number type. This is most proabably not a problem, but take a look at it to be sure and convert the setting to get rid of this warning.", value);
        }
        else if (number != (NSNumber*)(void*)kCFBooleanTrue &&
                 number != (NSNumber*)(void*)kCFBooleanFalse)
        {
            // TODO: remove this later.
            AKALogWarn(@"Specification item expected to be a literal boolean value (YES or NO), got %@. This is most proabably not a problem, but take a look at it to be sure and convert the setting to get rid of this warning.", value);
        }
#endif
        result = number.boolValue;
    }
    else
    {
        NSAssert(value == nil, @"Invalid type for specification item, expected NSNumber(BOOL), got: %@", value);
    }

    return result;
}

+ (NSDictionary*)dictionaryForObject:(id)value required:(BOOL)required
{
    NSDictionary* result = nil;

    if ([value isKindOfClass:[NSDictionary class]])
    {
        result = value;
    }
    else if (value == nil && required)
    {
        NSAssert(NO, @"Undefined required specification item, expected a dictionary");
    }
    else if (value != nil)
    {
        NSAssert(NO, @"Invalid type for specification item, expected NSDictionary, got: %@", value);
    }

    return result;
}

+ (opt_NSNumber)enumValueForObject:(id)value required:(BOOL)required
{
    NSNumber* result = nil;

    if (value == [NSNull null])
    {
        value = nil;
    }

    if ([value isKindOfClass:[NSNumber class]])
    {
        result = value;
    }
    else if (value != nil)
    {
        NSAssert(NO, @"Invalid type for specification item, expected NSDictionary, got: '%@'.", value);
    }
    else if (required)
    {
        NSAssert(NO, @"Undefined required specification item, expected an NSNumber (enumeration value).");
    }

    return result;
}

+ (req_NSNumber)enumValueForObject:(id)value
                      defaultValue:(req_NSNumber)defaultValue
{
    NSNumber* result = [self enumValueForObject:value required:NO];

    if (result == nil)
    {
        result = defaultValue;
    }
    
    return result;
}

@end


#pragma mark - AKABindingTargetSpecification
#pragma mark -

@implementation AKABindingTargetSpecification

#pragma mark - Initialization

- (instancetype)                            initWithDictionary:(req_NSDictionary)dictionary
{
    return [self initWithDictionary:dictionary basedOn:nil];
}

- (instancetype)                            initWithDictionary:(req_NSDictionary)dictionary
                                                       basedOn:(opt_AKABindingTargetSpecification)base
{
    if (self = [super init])
    {
        _typePattern =
            [AKATypePattern typePatternWithObject:dictionary[kAKABindingSpecificationBindingTargetSpecificationKey]
                                          basedOn:base.typePattern
                                         required:NO];
    }

    return self;
}

#pragma mark - Conversion

- (void)                                       addToDictionary:(req_NSMutableDictionary)specDictionary
{
    if (self.typePattern)
    {
        NSMutableDictionary* type = [NSMutableDictionary new];
        [self.typePattern addToDictionary:type];
        specDictionary[kAKABindingSpecificationBindingTargetSpecificationKey] = type;
    }
}

@end


#pragma mark - AKABindingExpressionSpecification
#pragma mark -

@implementation AKABindingExpressionSpecification

#pragma mark - Initialization

- (instancetype)                            initWithDictionary:(req_NSDictionary)dictionary
{
    return [self initWithDictionary:dictionary basedOn:nil];
}

- (instancetype)                            initWithDictionary:(req_NSDictionary)dictionary
                                                       basedOn:(opt_AKABindingExpressionSpecification)base
{
    if (self = [super init])
    {
        _expressionType =
            [AKABindingSpecification enumValueForObject:dictionary[kAKABindingSpecificationBindingExpressionType]
                                           defaultValue:(base
                                                         ? @(base.expressionType)
                                                         : @(AKABindingExpressionTypeAny) )].unsignedLongValue;

        _arrayItemBindingType = [AKABindingSpecification classTypeForObject:dictionary[kAKABindingSpecificationArrayItemBindingProviderTypeKey]
                                                                   required:NO];
        if (_arrayItemBindingType == nil)
        {
            _arrayItemBindingType = base.arrayItemBindingType;
        }

        // May be overriden by attribute with primary==YES:
        _primaryAttribute = base.primaryAttribute;

        NSMutableDictionary* attributeSpecifications = [NSMutableDictionary new];
        NSDictionary* attributes = [AKABindingSpecification dictionaryForObject:dictionary[kAKABindingSpecificationAttributesKey]
                                                                       required:NO];
        [attributes enumerateKeysAndObjectsUsingBlock:
         ^(req_id key, req_id obj, outreq_BOOL stop)
         {
             (void)stop;

             NSAssert([key isKindOfClass:[NSString class]],
                      @"Binding expression attribute specification key is required to be a string (the name of the attribute or '*' representing all unspecified attributes), got: %@", key);
             NSString* attributeName = key;

             if ([obj isKindOfClass:[AKABindingAttributeSpecification class]])
             {
                 attributeSpecifications[attributeName] = obj;
             }
             else if ([obj isKindOfClass:[NSDictionary class]])
             {
                 NSDictionary<NSString*, id>* attributeDictionary = obj;

                 // attribute base is the corresponding attribute specification of a binding providers super class
                 // which is implicitely inherited.
                 AKABindingAttributeSpecification* attributeBase = base.attributes[key];

                 // TODO: refactor this stuff:

                 // expression base is the expression specification defined inside of an attribute specification.
                 // Usually only one of both is defined, but it's possible that spec wants to override the
                 // expression specification of an inherited attribute with an existing binding expression.
                 // That should work.
                 id expressionBase = attributeDictionary[@"base"];
                 if (expressionBase == nil)
                 {
                     expressionBase = [[AKABindingSpecification classTypeForObject:attributeDictionary[kAKABindingSpecificationBindingTypeKey]
                                                                          required:NO] specification].bindingSourceSpecification;
                 }

                 NSAssert(expressionBase == nil || [expressionBase isKindOfClass:[AKABindingExpressionSpecification class]],
                          @"Invalid type for attribute specification item 'base', expected an instance of AKABindingExpressionSpecification, got %@",
                          expressionBase);

                 AKABindingAttributeSpecification* attributeSpecification =
                    [[AKABindingAttributeSpecification alloc] initWithDictionary:attributeDictionary
                                                   basedOnAttributeSpecification:attributeBase
                                                         expressionSpecification:expressionBase];

                 attributeSpecifications[attributeName] = attributeSpecification;

                 if (attributeSpecification.primary)
                 {
                     NSAssert(self->_primaryAttribute.length == 0 || [self->_primaryAttribute isEqualToString:attributeName],
                              @"Invalid attempt to mark attribute %@ as primary, specification already has a defined primary attribute %@",
                              attributeName, self->_primaryAttribute);
                     self->_primaryAttribute = attributeName;
                 }
             }
             else
             {
                 NSAssert(NO,
                          @"Binding expression attribute specification is required to be an attribute specification, a dictionary or a boolean value indicating whether the attribute is supported");
             }
         }];

        // Add base attributes not redefined here:
        [base.attributes enumerateKeysAndObjectsUsingBlock:
         ^(req_NSString                         baseAttributeName,
           req_AKABindingAttributeSpecification baseAttributeValue,
           outreq_BOOL                          stop)
         {
             (void)stop;
             if (attributeSpecifications[baseAttributeName] == nil)
             {
                 attributeSpecifications[baseAttributeName] = baseAttributeValue;
             }
         }];

        _attributes = [NSDictionary dictionaryWithDictionary:attributeSpecifications];

        _allowUnspecifiedAttributes = [AKABindingSpecification booleanForObject:dictionary[@"allowUnspecifiedAttributes"]
                                                                    withDefault:base.allowUnspecifiedAttributes];

        // TODO: check if expression type is enum or options respectively, error handling:
        _enumerationType = [dictionary valueForKey:@"enumerationType"];
        if (_enumerationType == nil)
        {
            _enumerationType = base.enumerationType;
        }
        _optionsType = [dictionary valueForKey:@"optionsType"];
        if (_optionsType == nil)
        {
            _optionsType = base.optionsType;
        }

        NSAssert(_arrayItemBindingType == nil || ((AKABindingExpressionTypeArray & _expressionType) != 0), @"Array item binding provider specified even though the binding expressions type constraints exclude the array binding type. This is by itself not a problem but constitutes an inconsisten binding specification. Please review the specification %@", self);
    }

    return self;
}

- (void)                                       addToDictionary:(req_NSMutableDictionary)specDictionary
{
    NSMutableDictionary* attributes = [NSMutableDictionary new];

    [self.attributes
     enumerateKeysAndObjectsUsingBlock:
     ^(NSString* _Nonnull key, AKABindingAttributeSpecification* _Nonnull obj, BOOL* _Nonnull stop)
     {
         (void)stop;

         NSMutableDictionary* value = [NSMutableDictionary new];
         [obj addToDictionary:value];
         attributes[key] = value;
     }];

    if (attributes.count > 0)
    {
        specDictionary[kAKABindingSpecificationAttributesKey] = attributes;
    }

    specDictionary[@"expressionType"] = @(self.expressionType);


    if (self.arrayItemBindingType)
    {
        specDictionary[kAKABindingSpecificationArrayItemBindingProviderTypeKey] = self.arrayItemBindingType;
    }

    if (self.enumerationType.length > 0)
    {
        specDictionary[@"enumerationType"] = self.enumerationType;
    }

    if (self.optionsType.length > 0)
    {
        specDictionary[@"optionsType"] = self.optionsType;
    }
}

#pragma mark - Enumeration Constant Registry

+ (nonnull NSMutableDictionary<NSString*, NSDictionary<NSString*, id>*>*) registry
{
    static NSMutableDictionary<NSString*, NSDictionary<NSString*, id>*>* result;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result = [NSMutableDictionary new];
    });

    return result;
}

+ (id)resolveEnumeratedValue:(opt_NSString)symbolicValue
                     forType:(opt_NSString)enumerationType
                       error:(out_NSError)error
{
    id result = nil;

    if (enumerationType.length > 0)
    {
        NSDictionary<NSString*, NSNumber*>* valuesByName =
            [self registry][(req_NSString)enumerationType];

        if (valuesByName != nil)
        {
            if (symbolicValue.length > 0)
            {
                result = [valuesByName valueForKeyPath:(req_NSString)symbolicValue];

                if (result == nil && error != nil)
                {
                    *error = [AKABindingErrors unknownSymbolicEnumerationValue:(req_NSString)symbolicValue
                                                            forEnumerationType:(req_NSString)enumerationType
                                                              withValuesByName:valuesByName];
                }
            }
        }
    }

    return result;
}

+ (void)registerEnumerationType:(req_NSString)enumerationType
               withValuesByName:(NSDictionary<NSString*, id>* _Nonnull)valuesByName
{
    __block BOOL result = NO;

    NSAssert([NSThread isMainThread], @"Invalid attempt to register an enumeration type outside of main thread!");

    [enumerationType aka_performBlockInMainThreadOrQueue:^{
        NSMutableDictionary<NSString*, NSDictionary<NSString*, id>*>* registry =
        [self registry];

        if (!registry[enumerationType])
        {
            registry[enumerationType] = valuesByName;
            result = YES;
        }
    }
                                       waitForCompletion:YES];
    
    (void)result; // TODO: add error parameter + handling
}

+ (BOOL)isEnumerationTypeDefined:(NSString *)enumerationType
{
    return [self registry][enumerationType] != nil;
}

#pragma mark - Options Constant Registry

+ (nonnull NSMutableDictionary<NSString*, NSDictionary<NSString*, NSNumber*>*>*) optionsRegistry
{
    static NSMutableDictionary<NSString*, NSDictionary<NSString*, NSNumber*>*>* result;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result = [NSMutableDictionary new];
    });

    return result;
}

+ (NSNumber*)resolveOptionsValue:(opt_AKABindingExpressionAttributes)attributes
                         forType:(opt_NSString)optionsType
                           error:(out_NSError)error
{
    NSNumber* result = nil;

    if (optionsType.length > 0)
    {
        NSDictionary<NSString*, NSNumber*>* valuesByName =
            [self optionsRegistry][(req_NSString)optionsType];

        if (valuesByName != nil)
        {
            __block long long unsigned resultValue = 0;
            [attributes enumerateKeysAndObjectsUsingBlock:
             ^(req_NSString symbolicValue, req_AKABindingExpression notUsed, outreq_BOOL stop)
             {
                 (void)notUsed;
                 NSNumber* value = valuesByName[symbolicValue];

                 if (value != nil)
                 {
                     resultValue |= value.unsignedLongLongValue;
                 }
                 else
                 {
                     if (error)
                     {
                         *stop = YES;
                         *error = [AKABindingErrors unknownSymbolicEnumerationValue:symbolicValue
                                                                 forEnumerationType:(req_NSString)optionsType
                                                                   withValuesByName:valuesByName];
                     }
                 }
             }];
            result = @(resultValue);
        }
    }

    return result;
}

+ (void)registerOptionsType:(req_NSString)enumerationType
            withValuesByName:(NSDictionary<NSString*, NSNumber*>* _Nonnull)valuesByName
{
    __block BOOL result = NO;

    NSAssert([NSThread isMainThread], @"Invalid attempt to register an options type outside of main thread!");

    [enumerationType aka_performBlockInMainThreadOrQueue:^{
        NSMutableDictionary<NSString*, NSDictionary<NSString*, NSNumber*>*>* optionsRegistry =
            [self optionsRegistry];
        NSMutableDictionary<NSString*, NSDictionary<NSString*, id>*>* enumRegistry =
            [self registry];


        if (!enumRegistry[enumerationType] && !optionsRegistry[enumerationType])
        {
            [self registerEnumerationType:enumerationType
                         withValuesByName:valuesByName];
            optionsRegistry[enumerationType] = valuesByName;
            result = YES;
        }
    }
                                       waitForCompletion:YES];

    (void)result;
}

+ (NSArray<NSString*>* _Nullable)registeredOptionNamesForOptionsType:(req_NSString)optionsType
{
    return [self optionsRegistry][optionsType].allKeys;
}

+ (BOOL)isOptionsTypeDefined:(NSString *)optionsType
{
    return [self optionsRegistry][optionsType] != nil;
}

#pragma mark - Expression Type (Set) Names

+ (NSDictionary<NSNumber*, NSString*>*)                        expressionTypeNamesByCode
{
    static NSDictionary<NSNumber*, NSString*>* result = nil;

    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result =
            @{
            @(AKABindingExpressionTypeNone):                     @"None",
            @(AKABindingExpressionTypeUnqualifiedKeyPath):       @"UnqualifiedKeyPath",
            @(AKABindingExpressionTypeDataContextKeyPath):       @"DataContextKeyPath",
            @(AKABindingExpressionTypeRootDataContextKeyPath):   @"RootDataContextKeyPath",
            @(AKABindingExpressionTypeControlKeyPath):           @"ControlKeyPath",
            @(AKABindingExpressionTypeArray):                    @"Array",
            @(AKABindingExpressionTypeClassConstant):            @"ClassConstant",
            @(AKABindingExpressionTypeStringConstant):           @"StringConstant",
            @(AKABindingExpressionTypeBooleanConstant):          @"BooleanConstant",
            @(AKABindingExpressionTypeIntegerConstant):          @"IntegerConstant",
            @(AKABindingExpressionTypeDoubleConstant):           @"DoubleConstant",
            @(AKABindingExpressionTypeOptionsConstant):          @"OptionsConstant",
            @(AKABindingExpressionTypeEnumConstant):             @"EnumConstant",
            @(AKABindingExpressionTypeUIColorConstant):          @"UIColorConstant",
            @(AKABindingExpressionTypeCGColorConstant):          @"CGColorConstant",
            @(AKABindingExpressionTypeCGPointConstant):          @"CGPointConstant",
            @(AKABindingExpressionTypeCGSizeConstant):           @"CGSizeConstant",
            @(AKABindingExpressionTypeCGRectConstant):           @"CGRectConstant",
            @(AKABindingExpressionTypeUIFontConstant):           @"UIFontConstant"
        };
    });

    return result;
}

+ (NSDictionary<NSNumber*, NSString*>*)                        expressionTypeSetNamesByCode
{
    static NSDictionary<NSNumber*, NSString*>* result = nil;

    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result =
            @{ @(AKABindingExpressionTypeAnyKeyPath):               @"AnyKeyPath",
               @(AKABindingExpressionTypeClass):                    @"Class",
               @(AKABindingExpressionTypeString):                   @"String",
               @(AKABindingExpressionTypeBoolean):                  @"Boolean",
               @(AKABindingExpressionTypeInteger):                  @"Integer",
               @(AKABindingExpressionTypeDouble):                   @"Double",
               @(AKABindingExpressionTypeAnyColorConstant):         @"AnyColorConstant",
               @(AKABindingExpressionTypeAnyNumberConstant):        @"AnyNumberConstant",
               @(AKABindingExpressionTypeAnyNumberConstant):        @"Number",
               @(AKABindingExpressionTypeAnyConstant):              @"AnyConstant",
               @(AKABindingExpressionTypeAny):                      @"Any" };
    });

    return result;
}

+ (NSString*)                        expressionTypeDescription:(AKABindingExpressionType)expressionType
{
    NSString* result = [self expressionTypeNamesByCode][@(expressionType)];

    if (result == nil)
    {
        result = [self expressionTypeSetDescription:expressionType];
    }

    return result;
}

+ (NSString*)                     expressionTypeSetDescription:(AKABindingExpressionType)expressionType
{
    NSString* result = nil;

    if (expressionType > 0)
    {
        result = [self expressionTypeSetNamesByCode][@(expressionType)];

        NSMutableArray* options = [NSMutableArray new];

        for (AKABindingExpressionType i = AKABindingExpressionTypeNone;
             i <= expressionType;
             i = i << 1)
        {
            if (expressionType & i)
            {
                NSString* name = [self expressionTypeNamesByCode][@(i)];

                if (name)
                {
                    [options addObject:name];
                }
                else
                {
                    AKALogError(@"expressionTypeSetDescription: Invalid expression type %@", @(i));
                }
            }
        }

        if (options.count > 0)
        {
            if (result.length)
            {
                result = [NSString stringWithFormat:@"%@ {%@}", result, [options componentsJoinedByString:@", "]];
            }
            else
            {
                result = [NSString stringWithFormat:@"{%@}", [options componentsJoinedByString:@", "]];
            }
        }

        return result ? [NSString stringWithString:result] : nil;
    }

    return result;
}

@end


#pragma mark - AKABindingAttributeSpecification
#pragma mark -

@implementation AKABindingAttributeSpecification

#pragma mark - Initialization

- (instancetype)                            initWithDictionary:(req_NSDictionary)dictionary
{
    return [self initWithDictionary:dictionary
      basedOnAttributeSpecification:nil
            expressionSpecification:nil];
}

- (instancetype)                            initWithDictionary:(req_NSDictionary)dictionary
                                 basedOnAttributeSpecification:(opt_AKABindingAttributeSpecification)base
                                       expressionSpecification:(opt_AKABindingExpressionSpecification)expressionBase
{
    if (self = [super initWithDictionary:dictionary
                    basedOnSpecification:base
                 expressionSpecification:expressionBase])
    {
        _required = [AKABindingSpecification booleanForObject:dictionary[kAKABindingAttributesSpecificationRequiredKey]
                                                  withDefault:base ? base.required : NO];
        _primary = [AKABindingSpecification booleanForObject:dictionary [kAKABindingAttributesSpecificationPrimaryKey]
                                                  withDefault:base ? base.primary : NO];
        _attributeUse = [AKABindingSpecification enumValueForObject:dictionary[kAKABindingAttributesSpecificationUseKey]
                                                       defaultValue:(base
                                                                     ? @(base.attributeUse)
                                                                     : @(AKABindingAttributeUseManually))].unsignedIntegerValue;
        switch (self.attributeUse)
        {
            case AKABindingAttributeUseAssignValueToBindingProperty:
            case AKABindingAttributeUseAssignValueToTargetProperty:
            case AKABindingAttributeUseAssignExpressionToBindingProperty:
            case AKABindingAttributeUseAssignEvaluatorToBindingProperty:
            case AKABindingAttributeUseBindToBindingProperty:
            case AKABindingAttributeUseBindToTargetProperty:
            {
                _bindingPropertyName = dictionary[kAKABindingAttributesSpecificationBindingPropertyKey];
                if (_bindingPropertyName == nil)
                {
                    _bindingPropertyName = base.bindingPropertyName;
                }
                break;
            }

            case AKABindingAttributeUseManually:
                NSAssert(dictionary[kAKABindingAttributesSpecificationBindingPropertyKey] == nil,
                         @"bindingProperty specified for AKABindingAttributeUseManually");
                _bindingPropertyName = nil;
                break;

            default:
                @throw [NSException exceptionWithName:@"Unknown binding attribute use" reason:[NSString stringWithFormat:@"Enumeration value %@ is not known", @(self.attributeUse)] userInfo:nil];
                self = nil;
        }
    }

    return self;
}

- (void)                                       addToDictionary:(req_NSMutableDictionary)specDictionary
{
    [super addToDictionary:specDictionary];

    specDictionary[kAKABindingAttributesSpecificationRequiredKey] = @(self.required);
    specDictionary[kAKABindingAttributesSpecificationUseKey] = @(self.attributeUse);

    if (self.attributeUse != AKABindingAttributeUseManually && self.bindingPropertyName.length > 0)
    {
        specDictionary[kAKABindingAttributesSpecificationBindingPropertyKey] = self.bindingPropertyName;
    }
}

@end


#pragma mark - AKATypePattern
#pragma mark -

@implementation AKATypePattern

#pragma mark - Initialization


+ (AKATypePattern*)typePatternWithObject:(id)value required:(BOOL)required
{
    return [self typePatternWithObject:(id)value basedOn:nil required:required];
}

+ (AKATypePattern*)typePatternWithObject:(id)value basedOn:(AKATypePattern*)base required:(BOOL)required
{
    AKATypePattern* result = nil;

    if (value != nil)
    {
        if ([value isKindOfClass:[AKATypePattern class]])
        {
            result = value;
        }
        else if ([value isKindOfClass:[NSDictionary class]])
        {
            result = [[AKATypePattern alloc] initWithDictionary:value basedOn:base];
        }
        else if ([value isKindOfClass:[NSArray class]])
        {
            result = [[AKATypePattern alloc] initWithArrayOfClasses:value basedOn:base];
        }
        else if (object_isClass(value))
        {
            result = [[AKATypePattern alloc] initWithClass:value basedOn:base];
        }
        else
        {
            NSAssert(NO, @"Invalid type for specification item, expected Class, NSArray<Class>, NSDictionary or an instance of AKATypePattern, got: %@", value);
        }
    }
    else if (base != nil)
    {
        result = base;
    }
    else if (required)
    {
        NSAssert(NO, @"Undefined required type pattern, expected Class, NSArray<Class>, NSDictionary or an instance of AKATypePattern.");
    }

    return result;
}

- (instancetype)                            initWithDictionary:(req_NSDictionary)dictionary
{
    return [self initWithDictionary:dictionary basedOn:nil];
}

- (instancetype)                            initWithDictionary:(req_NSDictionary)dictionary
                                                       basedOn:(opt_AKATypePattern)base
{
    if (self = [self init])
    {
        _acceptedTypes = [AKATypePattern setOfClassesFromClassOrArrayOfClasses:dictionary[@"acceptedTypes"]
                                                                       basedOn:nil];
        if (_acceptedTypes == nil)
        {
            _acceptedTypes = base.acceptedTypes;
        }
        else if (base.acceptedTypes.count > 0)
        {

        }
        _acceptedValueTypes = [AKATypePattern setOfValueTypeFromStringOrArrayOfStrings:dictionary[@"acceptedValueTypes"]
                                                                               basedOn:nil];
        if (_acceptedValueTypes == nil)
        {
            _acceptedValueTypes = base.acceptedValueTypes;
        }

        _rejectedTypes = [AKATypePattern setOfClassesFromClassOrArrayOfClasses:dictionary[@"rejectedTypes"]
                                                                       basedOn:base.rejectedTypes];
        _rejectedValueTypes =
            [AKATypePattern setOfValueTypeFromStringOrArrayOfStrings:dictionary[@"acceptedValueTypes"]
                                                             basedOn:base.rejectedValueTypes];
    }

    return self;
}

- (instancetype)                                 initWithClass:(Class)type
{
    return [self initWithClass:type basedOn:nil];
}

- (instancetype)                                 initWithClass:(Class)type
                                                       basedOn:(opt_AKATypePattern)base
{
    if (self = [self init])
    {
        _acceptedTypes = (base.acceptedTypes != nil
                          ? [base.acceptedTypes setByAddingObject:type]
                          : [NSSet setWithObject:type]);
        _acceptedValueTypes = base.acceptedValueTypes;
        _rejectedTypes = base.rejectedTypes;
        _rejectedValueTypes = base.rejectedValueTypes;
    }

    return self;
}

- (instancetype)                        initWithArrayOfClasses:(req_NSArray)array
{
    return [self initWithArrayOfClasses:array basedOn:nil];
}

- (instancetype)                        initWithArrayOfClasses:(req_NSArray)array
                                                       basedOn:(opt_AKATypePattern)base
{
    if (self = [self init])
    {
        _acceptedTypes = (base.acceptedTypes != nil
                          ? [base.acceptedTypes setByAddingObjectsFromArray:array]
                          : [NSSet setWithArray:array]);
        _acceptedValueTypes = base.acceptedValueTypes;
        _rejectedTypes = base.rejectedTypes;
        _rejectedValueTypes = base.rejectedValueTypes;
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

+ (BOOL) setOfTypes:(NSSet<Class>*)typeSet matchesObject:(id)object
{
    BOOL result = NO;
    for (Class type in typeSet)
    {
        if ([[object class] isSubclassOfClass:type])
        {
            result = YES;
            break;
        }
    }
    return result;
}

+ (BOOL) setOfValueTypeCodes:(NSSet<NSString*>*)typeSet matchesValue:(NSValue*)value
{
    NSString* code = [NSString stringWithCString:(value).objCType
                                        encoding:NSASCIIStringEncoding];
    BOOL result = [typeSet containsObject:code];
    return result;
}

- (BOOL)                                         matchesObject:(id)object
{
    BOOL result = YES;

    if (object != nil)
    {
        result = ![AKATypePattern setOfTypes:self.rejectedTypes matchesObject:object];

        if (result && self.acceptedTypes.count > 0)
        {
            result = [AKATypePattern setOfTypes:self.acceptedTypes matchesObject:object];
        }

        if (result && (self.rejectedValueTypes.count > 0 || self.acceptedValueTypes.count > 0))
        {
            if ([object isKindOfClass:[NSValue class]])
            {
                NSValue* value = object;
                result = ![AKATypePattern setOfValueTypeCodes:self.rejectedValueTypes matchesValue:value];

                if (result && self.acceptedTypes.count > 0)
                {
                    result = [AKATypePattern setOfValueTypeCodes:self.acceptedValueTypes matchesValue:value];
                }
            }
        }
    }

    return result;
}

- (NSString*)                                      description
{
    NSMutableString* result = [NSMutableString new];

    [result appendFormat:@"<%@:", NSStringFromClass(self.class)];
    [result appendString:@"accepts"];

    if (self.acceptedTypes.count > 0)
    {
        [result appendFormat:@" objects of type {%@}", [self.acceptedTypes.allObjects componentsJoinedByString:@", "]];

        if (self.acceptedValueTypes.count > 0)
        {
            [result appendString:@" and"];
        }
    }

    if (self.acceptedValueTypes.count > 0)
    {
        [result appendFormat:@" values of type {%@}", [self.acceptedTypes.allObjects componentsJoinedByString:@", "]];
    }

    if (self.acceptedValueTypes.count == 0 && self.acceptedTypes.count == 0)
    {
        [result appendString:@" nothing"];
    }

    if (self.rejectedTypes.count > 0 || self.rejectedValueTypes.count > 0)
    {
        [result appendString:@" except: "];

        if (self.rejectedTypes.count > 0)
        {
            [result appendFormat:@" objects of type {%@}", [self.rejectedTypes.allObjects componentsJoinedByString:@", "]];

            if (self.rejectedValueTypes.count > 0)
            {
                [result appendString:@" and"];
            }
        }

        if (self.rejectedValueTypes.count > 0)
        {
            [result appendFormat:@" values of type {%@}", [self.rejectedValueTypes.allObjects componentsJoinedByString:@", "]];
        }
    }

    [result appendString:@">"];

    return [NSString stringWithString:result];
}

#pragma mark - Implementation

+ (NSSet*)               setOfClassesFromClassOrArrayOfClasses:(id)object
                                                       basedOn:(NSSet*)base
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

    if (!result)
    {
        result = base;
    }
    else if (base)
    {
        result = [base setByAddingObjectsFromSet:result];
    }

    return result;
}

+ (NSSet*)            setOfValueTypeFromStringOrArrayOfStrings:(id)object
                                                       basedOn:(NSSet*)base
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

    if (!result)
    {
        result = base;
    }
    else if (base)
    {
        result = [base setByAddingObjectsFromSet:result];
    }

    return result;
}

@end