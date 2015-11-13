//
//  AKABindingSpecification.m
//  AKABeacon
//
//  Created by Michael Utech on 26.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#include <objc/runtime.h>
@import AKACommons.AKALog;

#import "AKABindingSpecification.h"
#import "AKABindingProvider.h"
#import "AKABindingExpression_Internal.h"

NSString*const kAKABindingSpecificationBindingTypeKey = @"bindingType";
NSString*const kAKABindingSpecificationBindingProviderTypeKey = @"bindingProviderType";
NSString*const kAKABindingSpecificationBindingTargetSpecificationKey = @"targetType";
NSString*const kAKABindingSpecificationBindingExpressionType = @"expressionType";
NSString*const kAKABindingSpecificationArrayItemBindingProviderTypeKey = @"arrayItemBindingProviderType";
NSString*const kAKABindingSpecificationAttributesKey = @"attributes";

NSString*const kAKABindingAttributesSpecificationRequiredKey = @"required";
NSString*const kAKABindingAttributesSpecificationUseKey = @"use";
NSString*const kAKABindingAttributesSpecificationBindingPropertyKey = @"bindingProperty";

@interface NSDictionary (AKABindingSpecification)

#pragma mark - Convenience

- (BOOL)aka_booleanForKey:(req_NSString)key withDefault:(BOOL)defaultValue;

- (NSDictionary*)aka_dictionaryForKey:(req_NSString)key required:(BOOL)required;

- (Class)aka_classTypeForKey:(req_NSString)key required:(BOOL)required;

- (opt_NSNumber)aka_enumValueForKey:(req_NSString)key
                           required:(BOOL)required;

- (req_NSNumber)aka_enumValueForKey:(req_NSString)key
                       defaultValue:(req_NSNumber)defaultValue;

- (AKATypePattern*)aka_classTypePatternForKey:(req_NSString)key required:(BOOL)required;

- (AKATypePattern*)aka_classTypePatternForKey:(req_NSString)key basedOn:(AKATypePattern*)base required:(BOOL)required;

- (AKABindingProvider*)aka_bindingProviderForKey:(req_NSString)key required:(BOOL)required;

@end

@implementation NSDictionary (AKABindingSpecification)

- (BOOL)aka_booleanForKey:(req_NSString)key withDefault:(BOOL)defaultValue
{
    BOOL result = defaultValue;
    id value = self[key];

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
    id value = self[key];

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
    id value = self[key];

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

- (opt_NSNumber)aka_enumValueForKey:(req_NSString)key required:(BOOL)required
{
    NSNumber* result = nil;
    id value = self[key];

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
        NSAssert(NO, @"Invalid type for specification %@, expected NSDictionary, got: '%@'.", key, value);
    }
    else if (required)
    {
        NSAssert(NO, @"Dictionary %@ does not contain a value for key '%@', expected an NSNumber (enumeration value).", self, key);
    }

    return result;
}

- (req_NSNumber)aka_enumValueForKey:(req_NSString)key
                       defaultValue:(req_NSNumber)defaultValue
{
    NSNumber* result = [self aka_enumValueForKey:key required:NO];

    if (result == nil)
    {
        result = defaultValue;
    }

    return result;
}

- (AKATypePattern*)aka_classTypePatternForKey:(req_NSString)key required:(BOOL)required
{
    return [self aka_classTypePatternForKey:key basedOn:nil required:required];
}

- (AKATypePattern*)aka_classTypePatternForKey:(req_NSString)key basedOn:(AKATypePattern*)base required:(BOOL)required
{
    AKATypePattern* result = nil;
    id value = self[key];

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
            NSAssert(NO, @"Invalid type for specification %@, expected Class, NSArray<Class>, NSDictionary or an instance of AKATypePattern, got: %@", key, value);
        }
    }
    else if (base != nil)
    {
        result = base;
    }
    else if (required)
    {
        NSAssert(NO, @"Dictionary %@ does not contain a value for key %@, expected Class, NSArray<Class>, NSDictionary or an instance of AKATypePattern.", self, key);
    }

    return result;
}

- (AKABindingProvider*)aka_bindingProviderForKey:(req_NSString)key required:(BOOL)required
{
    AKABindingProvider* result = nil;
    id value = self[key];

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
        _bindingType =
            [dictionary aka_classTypeForKey:kAKABindingSpecificationBindingTypeKey
                                   required:NO];

        if (!_bindingType)
        {
            _bindingType = base.bindingType;
        }

        _bindingProvider =
            [dictionary aka_bindingProviderForKey:kAKABindingSpecificationBindingProviderTypeKey
                                         required:NO];

        if (!_bindingProvider && base.bindingProvider)
        {
            _bindingProvider = (req_AKABindingProvider)base.bindingProvider;
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

        _arrayItemBindingProvider =
            [dictionary aka_bindingProviderForKey:kAKABindingSpecificationArrayItemBindingProviderTypeKey
                                         required:NO];

        if (!_arrayItemBindingProvider)
        {
            _arrayItemBindingProvider = base.arrayItemBindingProvider;
        }
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

    if (self.bindingProvider)
    {
        dictionary[kAKABindingSpecificationBindingProviderTypeKey] = self.bindingProvider.class;
    }

    if (self.arrayItemBindingProvider)
    {
        dictionary[kAKABindingSpecificationArrayItemBindingProviderTypeKey] = self.arrayItemBindingProvider;
    }

    [self.bindingTargetSpecification addToDictionary:dictionary];
    [self.bindingSourceSpecification addToDictionary:dictionary];
}

- (opt_AKABindingProvider) bindingProviderForAttributeWithName:(req_NSString)attributeName
{
    return self.bindingSourceSpecification.attributes[attributeName].bindingProvider;
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
            [dictionary aka_classTypePatternForKey:kAKABindingSpecificationBindingTargetSpecificationKey
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
            [dictionary aka_enumValueForKey:kAKABindingSpecificationBindingExpressionType
                               defaultValue:base ? @(base.expressionType) : @(AKABindingExpressionTypeAny)].unsignedLongValue;

        _arrayItemBindingProvider =
            [dictionary aka_bindingProviderForKey:kAKABindingSpecificationArrayItemBindingProviderTypeKey
                                         required:NO];
        if (_arrayItemBindingProvider == nil)
        {
            _arrayItemBindingProvider = base.arrayItemBindingProvider;
        }

        NSMutableDictionary* attributeSpecifications = [NSMutableDictionary new];
        NSDictionary* attributes = [dictionary aka_dictionaryForKey:kAKABindingSpecificationAttributesKey
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
                     expressionBase = [attributeDictionary aka_bindingProviderForKey:kAKABindingSpecificationBindingProviderTypeKey required:NO].specification.bindingSourceSpecification;
                 }

                 NSAssert(expressionBase == nil || [expressionBase isKindOfClass:[AKABindingExpressionSpecification class]],
                          @"Invalid type for attribute specification item 'base', expected an instance of AKABindingExpressionSpecification, got %@",
                          expressionBase);

                 attributeSpecifications[attributeName] =
                    [[AKABindingAttributeSpecification alloc] initWithDictionary:attributeDictionary
                                                   basedOnAttributeSpecification:attributeBase
                                                         expressionSpecification:expressionBase];
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

        _allowUnspecifiedAttributes = [dictionary aka_booleanForKey:@"allowUnspecifiedAttributes" withDefault:base.allowUnspecifiedAttributes];

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

        NSAssert(_arrayItemBindingProvider == nil || ((AKABindingExpressionTypeArray & _expressionType) != 0), @"Array item binding provider specified even though the binding expressions type constraints exclude the array binding type. This is by itself not a problem but constitutes an inconsisten binding specification. Please review the specification %@", self);
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
        specDictionary[@"attributes"] = attributes;
    }

    specDictionary[@"expressionType"] = @(self.expressionType);

    if (self.arrayItemBindingProvider)
    {
        specDictionary[@"arrayItemBindingProvider"] = self.arrayItemBindingProvider;
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

#pragma mark - Enumeration and Options Constant Registry

+ (void)                               registerEnumerationType:(req_NSString)enumerationTypeName
                                              withValuesByName:(NSDictionary<NSString*, id>* _Nonnull)valuesByName
{
    [AKAEnumConstantBindingExpression registerEnumerationType:enumerationTypeName
                                             withValuesByName:valuesByName];
}

+ (void)                                   registerOptionsType:(req_NSString)optionsTypeName
                                              withValuesByName:(NSDictionary<NSString*, NSNumber*>* _Nonnull)valuesByName
{
    [AKAOptionsConstantBindingExpression registerOptionsType:optionsTypeName
                                            withValuesByName:valuesByName];
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

        return [NSString stringWithString:result];
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
        _required = [dictionary aka_booleanForKey:kAKABindingAttributesSpecificationRequiredKey
                                      withDefault:base ? base.required : NO];
        _attributeUse = [dictionary aka_enumValueForKey:kAKABindingAttributesSpecificationUseKey
                                           defaultValue:base ? @(base.attributeUse) : @(AKABindingAttributeUseIgnore)].unsignedIntegerValue;
        switch (self.attributeUse)
        {
            case AKABindingAttributeUseAssignValueToBindingProperty:
            case AKABindingAttributeUseAssignExpressionToBindingProperty:
            case AKABindingAttributeUseBindToBindingProperty:
            {
                _bindingPropertyName = dictionary[kAKABindingAttributesSpecificationBindingPropertyKey];
                if (_bindingPropertyName == nil)
                {
                    _bindingPropertyName = base.bindingPropertyName;
                }
                break;
            }

            case AKABindingAttributeUseIgnore:
                NSAssert(dictionary[kAKABindingAttributesSpecificationBindingPropertyKey] == nil,
                         @"bindingProperty specified for AKABindingAttributeUseIgnore");
                _bindingPropertyName = nil;
                break;

            default:
                @throw [NSException exceptionWithName:@"Unknown enumeration value" reason:[NSString stringWithFormat:@"Enumeration value %@ is not known", @(self.attributeUse)] userInfo:nil];
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

    if (self.attributeUse != AKABindingAttributeUseIgnore && self.bindingPropertyName.length > 0)
    {
        specDictionary[kAKABindingAttributesSpecificationBindingPropertyKey] = self.bindingPropertyName;
    }
}

@end


#pragma mark - AKATypePattern
#pragma mark -

@implementation AKATypePattern

#pragma mark - Initialization

- (instancetype)                            initWithDictionary:(req_NSDictionary)dictionary
{
    return [self initWithDictionary:dictionary basedOn:nil];
}

- (instancetype)                            initWithDictionary:(req_NSDictionary)dictionary
                                                       basedOn:(opt_AKATypePattern)base
{
    if (self = [self init])
    {
        // Accepted types and value types are not merged but overridden, because type constraints can only be tightened. If empty, the set of types allowed by base will be used (again, for not to allow any type not supported by base).

        NSSet<Class>* acceptedTypes = dictionary[@"acceptedTypes"];
        NSSet<NSString*>* acceptedValueTypes = dictionary[@"acceptedValueTypes"];

        _acceptedTypes = acceptedTypes.count > 0 ? acceptedTypes : base.acceptedTypes;

        _acceptedValueTypes = acceptedValueTypes.count > 0 ? acceptedValueTypes : base.acceptedValueTypes;


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