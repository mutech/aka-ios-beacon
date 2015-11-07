//
//  AKABindingExpression.m
//  AKABeacon
//
//  Created by Michael Utech on 18.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABindingExpression_Internal.h"
#import "NSScanner+AKABindingExpressionParser.h"
#import "AKABindingErrors.h"
#import "AKANSEnumerations.h"
#import "AKABindingSpecification.h"

@import AKACommons.AKANullability;
@import AKACommons.NSMutableString_AKATools;
@import AKACommons.AKALog;
@import AKACommons.AKAErrors;
@import AKACommons.NSObject_AKAConcurrencyTools;

@class AKAProperty;
@class AKAControl;
@class AKACompositeControl;

@interface AKABindingExpression (Implementation)

@property(nonatomic, readonly) NSString* textForPrimaryExpression;

@end

#pragma mark - AKABindingExpression
#pragma mark -

@implementation AKABindingExpression

#pragma mark - Initialization

+ (instancetype)bindingExpressionWithString:(req_NSString)expressionText
                            bindingProvider:(req_AKABindingProvider)bindingProvider
                                      error:(out_NSError)error
{
    NSScanner* parser = [NSScanner scannerWithString:expressionText];
    AKABindingExpression* result = nil;

    if ([parser parseBindingExpression:&result
                          withProvider:bindingProvider
                                 error:error])
    {
        if (!parser.isAtEnd)
        {
            result = nil;
            [parser registerParseError:error
                              withCode:AKAParseErrorInvalidPrimaryExpressionExpectedAttributesOrEnd
                            atPosition:parser.scanLocation
                                reason:@"Invalid character, expected attributes (starting with '{') or end of binding expression"];
        }

        if (result)
        {
            NSError* localError = nil;
            opt_AKABindingExpressionSpecification sourceSpec =
            bindingProvider.specification.bindingSourceSpecification;

            if (![result validateWithSpecification:sourceSpec error:&localError])
            {
                if (error)
                {
                    *error = localError;
                }
                else
                {
                    @throw [NSException exceptionWithName:@"BindingExpressionValidationFailed"
                                                   reason:localError.localizedDescription
                                                 userInfo:@{ @"error": localError }];
                }
                result = nil;
            }
        }
    }

    return result;
}

- (instancetype)initWithAttributes:(opt_AKABindingExpressionAttributes)attributes
                          provider:(opt_AKABindingProvider)provider;
{
    if (self = [super init])
    {
        _attributes = attributes;
        _bindingProvider = provider;
    }

    return self;
}

- (instancetype _Nullable)initWithPrimaryExpression:(opt_id)primaryExpression
                                         attributes:(opt_AKABindingExpressionAttributes)attributes
                                           provider:(opt_AKABindingProvider)provider
{
    if (primaryExpression == nil)
    {
        self = [self initWithAttributes:attributes provider:provider];
    }
    else
    {
        @throw [NSException exceptionWithName:@"Attempt to use AKABindingExpression with a primary binding expression. This is invalid. Use a binding type that can handle the specific type of primary expression." reason:nil userInfo:@{ }];
    }

    return self;
}

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeNone;
}

#pragma mark - Validation

- (BOOL)validateWithSpecification:(opt_AKABindingExpressionSpecification)specification
                            error:(out_NSError)error
{
    BOOL result = YES;

    if (result)
    {
        if (specification)
        {
            result = [self validatePrimaryExpressionType:specification.expressionType
                                                   error:error];
        }
        else
        {
            result = [self validatePrimaryExpressionType:AKABindingExpressionTypeNone
                                                   error:error];
        }
    }

    if (result)
    {
        result = [self validateAttributesWithSpecification:specification
                                                     error:error];
    }

    return result;
}

- (BOOL)validatePrimaryExpressionType:(AKABindingExpressionType)expressionType
                                error:(out_NSError)error
{
    BOOL result = (self.expressionType & expressionType) != 0;

    if (!result && error)
    {
        *error = [AKABindingErrors invalidBindingExpression:self
                               invalidPrimaryExpressionType:self.expressionType
                                                   expected:expressionType];
    }

    return result;
}

- (BOOL)validateAttributesWithSpecification:(opt_AKABindingExpressionSpecification)specification
                                      error:(out_NSError)error
{
    __block BOOL result = YES;
    __block NSError* localError = nil;

    BOOL allowUnspecified = specification.allowUnspecifiedAttributes;

    [self.attributes
     enumerateKeysAndObjectsUsingBlock:
     ^(req_NSString attributeName,
       req_AKABindingExpression bindingExpression,
       outreq_BOOL stop)
     {
         // Check for invalidly unknown attributes, note that if specification is nil, validation will fail:
         AKABindingAttributeSpecification* attributeSpecification =
             specification.attributes[attributeName];

         if (result && !allowUnspecified && attributeSpecification == nil)
         {
             localError = [AKABindingErrors invalidBindingExpression:self
                                                    unknownAttribute:attributeName];
             result = NO;
         }

         // perform attribute validation
         if (result)
         {
             AKABindingExpressionSpecification* attributeExpressionSpecification =
                 attributeSpecification.bindingSourceSpecification;

             if (attributeExpressionSpecification)
             {
                 result = [bindingExpression validateWithSpecification:attributeExpressionSpecification
                                                                 error:&localError];
             }
         }
         *stop = !result;
     }];

    if (result)
    {
        // Check that all required attributes are present
        [specification.attributes
         enumerateKeysAndObjectsUsingBlock:
         ^(req_NSString attributeName,
           req_AKABindingAttributeSpecification bindingSpecification,
           outreq_BOOL stop)
         {
             if (bindingSpecification.required)
             {
                 if (self.attributes[attributeName] == nil)
                 {
                     localError = [AKABindingErrors invalidBindingExpression:self
                                                    missingRequiredAttribute:attributeName];
                     result = NO;
                 }
             }
             *stop = !result;
         }];
    }

    if (!result)
    {
        if (error)
        {
            *error = localError;
        }
        else
        {
            @throw [NSException exceptionWithName:@"BindingExpressionAttributeValidationFailed"
                                           reason:localError.localizedDescription
                                         userInfo:@{ @"error": localError }];
        }
    }

    return result;
}

#pragma mark - Binding Support

- (opt_AKAUnboundProperty)bindingSourceUnboundPropertyInContext:(req_AKABindingContext)bindingContext
{
    (void)bindingContext;

    // Implemented by subclasses if supported
    return nil;
}

- (opt_AKAProperty)bindingSourcePropertyInContext:(req_AKABindingContext)bindingContext
                                    changeObserer:(opt_AKAPropertyChangeObserver)changeObserver
{
    (void)bindingContext;
    (void)changeObserver;

    // The default implementation returns nil which is the result when a binding expression does not
    // define a primary expression. Please note that this is the only case where this method delivers
    // an undefined value.

    return nil;
}

- (opt_id)bindingSourceValueInContext:(req_AKABindingContext)bindingContext
{
    (void)bindingContext;
    // Has to be implemented by subclasses
    AKAErrorAbstractMethodImplementationMissing();
}

#pragma mark - Diagnostics

- (BOOL)isConstant
{
    return NO;
}

- (NSString*)constantStringValueOrDescription
{
    AKAErrorAbstractMethodImplementationMissing();
}

- (NSString*)description
{
    return [self textWithNestingLevel:0
                               indent:@"\t"];
}

#pragma mark - Serialization

- (NSString*)text
{
    return [self textWithNestingLevel:0
                               indent:@""];
}

- (NSString*)textForPrimaryExpressionWithNestingLevel:(NSUInteger)level
                                               indent:(NSString*)indent
{
    (void)level;
    (void)indent;

    // Implemented by subclasses if supported
    return nil;
}

- (NSString*)textForPrimaryExpression
{
    return [self textForPrimaryExpressionWithNestingLevel:0 indent:@""];
}

- (NSString*)textWithNestingLevel:(NSUInteger)level
                           indent:(NSString*)indent
{
    static NSString*const kPrimaryAttributesSeparator = @" ";

    static NSString*const kAttributesOpen = @"{";
    static NSString*const kAttributesClose = @"}";
    static NSString*const kAttributeNameValueSeparator = @": ";
    static NSString*const kAttributeSeparator = @",";

    NSMutableString* result = [NSMutableString new];

    NSString* textForPrimaryExpression = self.textForPrimaryExpression;

    if (textForPrimaryExpression.length > 0)
    {
        [result appendString:textForPrimaryExpression];
    }

    if (self.attributes.count > 0)
    {
        if (result.length > 0)
        {
            [result appendString:kPrimaryAttributesSeparator];
        }

        NSString* attributePrefix;

        if (indent.length > 0)
        {
            attributePrefix = @"\n";
        }
        else
        {
            attributePrefix = @" ";
        }

        [result appendString:kAttributesOpen];

        __block NSUInteger i = 0;
        NSUInteger count = self.attributes.count;

        [self.attributes
         enumerateKeysAndObjectsUsingBlock:
         ^(NSString* _Nonnull key, AKABindingExpression* _Nonnull obj, BOOL* _Nonnull stop)
         {
             (void)stop;

             NSString* attributeValueText = [obj textWithNestingLevel:level + 1
                                                               indent:indent];

             [result appendString:attributePrefix];
             [result aka_appendString:indent
                               repeat:level + 1];

             [result appendString:key];

             [result appendString:kAttributeNameValueSeparator];

             [result appendString:attributeValueText];

             if (i < count - 1)
             {
                 [result appendString:kAttributeSeparator];
             }
             ++i;
         }];

        [result appendString:attributePrefix];
        [result aka_appendString:indent repeat:level];
        [result appendString:kAttributesClose];
    }

    return result;
}

@end

#pragma mark - AKAArrayBindingExpression
#pragma mark -

@implementation AKAArrayBindingExpression

#pragma mark - Initialization

- (instancetype)initWithArray:(NSArray<AKABindingExpression*>*)array
                   attributes:(opt_AKABindingExpressionAttributes)attributes
                     provider:(opt_AKABindingProvider)provider
{
    if (self = [super initWithAttributes:attributes
                                provider:provider])
    {
        _array = array;
    }

    return self;
}

- (instancetype)initWithPrimaryExpression:(opt_id)primaryExpression
                               attributes:(opt_AKABindingExpressionAttributes)attributes
                                 provider:(opt_AKABindingProvider)provider
{
    NSAssert(primaryExpression == nil || [primaryExpression isKindOfClass:[NSArray class]], @"AKAArrayBindingExpression requires a primary expression of type NSArray, got %@", primaryExpression);

    return [self initWithArray:(NSArray*)primaryExpression
                    attributes:attributes
                      provider:provider];
}

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeArray;
}

#pragma mark - Binding Support

- (opt_AKAProperty)bindingSourcePropertyInContext:(req_AKABindingContext)bindingContext
                                    changeObserer:(opt_AKAPropertyChangeObserver)changeObserver
{
    (void)bindingContext;
    opt_AKAProperty result = nil;
    opt_id target = self.array;

    NSAssert(target != nil, @"Array binding expression delivered an undefined (nil) array, the binding's source will, probably unexpectedly, be undefined.");

    if (target)
    {
        AKALogWarn(@"AKAArrayBindingExpression: bindingSourceProperty not yet implemented properly: We just provide a property to the array of binding expressions. Instead we need to provide a proxy that emulates an array of resolved values, where each binding expression element results in a property delivering an item of the proxy array.");
        result = [AKAProperty propertyOfWeakKeyValueTarget:(req_id)target
                                                   keyPath:nil
                                            changeObserver:changeObserver];
    }

    return result;
}

- (opt_id)bindingSourceValueInContext:(req_AKABindingContext)bindingContext
{
    (void)bindingContext;
    AKALogError(@"AKAArrayBindingExpression: bindingSourceProperty not yet implemented properly: We just provide a property to the array of binding expressions. Instead we need to provide a proxy that emulates an array of resolved values, where each binding expression element results in a property delivering an item of the proxy array.");

    return self.array;
}

#pragma mark - Diagnostics

- (NSString*)constantStringValueOrDescription
{
    return @"(array expression)";
}

#pragma mark - Serialization

- (NSString*)textForPrimaryExpressionWithNestingLevel:(NSUInteger)level
                                               indent:(NSString*)indent
{
    static NSString*const kArrayOpen = @"[";
    static NSString*const kArrayClose = @"]";
    static NSString*const kArrayItemSeparator = @",";

    NSMutableString* result = [NSMutableString new];

    [result appendString:kArrayOpen];
    NSString* itemPrefix;

    if (indent.length > 0)
    {
        itemPrefix = @"\n";
    }
    else
    {
        itemPrefix = @" ";
    }

    if (self.array.count > 0)
    {
        NSUInteger count = self.array.count;
        [self.array
         enumerateObjectsUsingBlock:
         ^(AKABindingExpression* _Nonnull obj, NSUInteger idx, BOOL* _Nonnull stop)
         {
             (void)stop;
             NSString* itemText = [obj textWithNestingLevel:level + 1
                                                     indent:indent];

             [result appendString:itemPrefix];
             [result aka_appendString:indent
                               repeat:level + 1];

             [result appendString:itemText];

             if (idx < count - 1)
             {
                 [result appendString:kArrayItemSeparator];
             }
         }];
    }

    [result appendString:itemPrefix];
    [result aka_appendString:indent repeat:level];
    [result appendString:kArrayClose];

    return result;
}

@end


#pragma mark - AKAConstantBindingExpression
#pragma mark -

@implementation AKAConstantBindingExpression

#pragma mark - Initialization

- (instancetype)initWithConstant:(id)constant
                      attributes:(NSDictionary<NSString*, AKABindingExpression*>* __nullable)attributes
                        provider:(opt_AKABindingProvider)provider
{
    if (self = [super initWithAttributes:attributes
                                provider:provider])
    {
        _constant = constant;
    }

    return self;
}

- (instancetype _Nullable)initWithPrimaryExpression:(opt_id)primaryExpression
                                         attributes:(opt_AKABindingExpressionAttributes)attributes
                                           provider:(opt_AKABindingProvider)provider
{
    return [self initWithConstant:primaryExpression
                       attributes:attributes
                         provider:provider];
}

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeAbstract;
}

#pragma mark - Binding Support

- (opt_AKAProperty)bindingSourcePropertyInContext:(req_AKABindingContext)bindingContext
                                    changeObserer:(opt_AKAPropertyChangeObserver)changeObserver
{
    (void)bindingContext;

    opt_id target = self.constant;
    opt_AKAProperty result = nil;

    if (target)
    {
        result = [AKAProperty propertyOfWeakKeyValueTarget:(req_id)target
                                                   keyPath:nil
                                            changeObserver:changeObserver];
    }

    return result;
}

- (opt_id)bindingSourceValueInContext:(req_AKABindingContext)bindingContext
{
    (void)bindingContext;

    return self.constant;
}

#pragma mark - Diagnostics

- (BOOL)isConstant
{
    return YES;
}

- (NSString*)constantStringValueOrDescription
{
    return [self.constant description];
}

#pragma mark - Serialization

- (NSString*)textForConstant
{
    AKAErrorAbstractMethodImplementationMissing();
}

- (NSString*)textForPrimaryExpression
{
    return self.textForConstant;
}

@end


#pragma mark - AKAStringConstantBindingExpression
#pragma mark -

@implementation AKAStringConstantBindingExpression

@dynamic constant;

#pragma mark - Initialization

- (instancetype _Nonnull)initWithConstant:(opt_NSString)constant
                               attributes:(opt_AKABindingExpressionAttributes)attributes
                                 provider:(opt_AKABindingProvider)provider
{
    self = [super initWithConstant:constant
                        attributes:attributes
                          provider:provider];

    return self;
}

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeStringConstant;
}

#pragma mark - Serialization

- (NSString*)textForConstant
{
    NSMutableString* result = nil;

    NSString* string = self.constant;

    if (string != nil)
    {
        result = [NSMutableString stringWithString:@"\""];
        for (NSUInteger i = 0; i < string.length; ++i)
        {
            unichar c = [string characterAtIndex:i];
            [AKAStringConstantBindingExpression appendEscapeSequenceForCharacter:c
                                                                 inMutableString:result];
        }
        [result appendString:@"\""];
    }

    return result;
}

+ (void)appendEscapeSequenceForCharacter:(unichar)character
                         inMutableString:(NSMutableString*)storage
{
    static NSDictionary<NSNumber*, NSString*>* map;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        map = @{ @((unichar)'\a'): @"\\a",
                 @((unichar)'\b'): @"\\b",
                 @((unichar)'\f'): @"\\f",
                 @((unichar)'\n'): @"\\n",
                 @((unichar)'\r'): @"\\r",
                 @((unichar)'\t'): @"\\t",
                 @((unichar)'\v'): @"\\v",
                 @((unichar)'\\'): @"\\\\",
                 @((unichar)'\''): @"\\'",
                 @((unichar)'"'):  @"\\\"",
                 @((unichar)'\?'): @"\\?", };
    });

    NSString* replacement = map[@(character)];

    if (replacement != nil)
    {
        [storage appendString:replacement];
    }
    else
    {
        [storage appendFormat:@"%C", character];
    }
}

@end


#pragma mark - AKAClassConstantBindingExpression
#pragma mark -

@implementation AKAClassConstantBindingExpression

@dynamic constant;

#pragma mark - Initialization

- (instancetype _Nonnull)initWithConstant:(opt_Class)constant
                               attributes:(opt_AKABindingExpressionAttributes)attributes
                                 provider:(opt_AKABindingProvider)provider
{
    self = [super initWithConstant:constant
                        attributes:attributes
                          provider:provider];

    return self;
}

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeClassConstant;
}

#pragma mark - Serialization

- (NSString*)textForConstant
{
    NSString* result = nil;
    opt_Class type = self.constant;

    if (type != nil)
    {
        result = [NSString stringWithFormat:@"<%@>", NSStringFromClass((req_Class)type)];
    }

    return result;
}

@end

#pragma mark - AKANumberConstantBindingExpression
#pragma mark -

@implementation AKANumberConstantBindingExpression

@dynamic constant;

#pragma mark - Initialization

- (instancetype)  initWithNumber:(NSNumber*)constant
                      attributes:(NSDictionary<NSString*, AKABindingExpression*>* __nullable)attributes
                        provider:(opt_AKABindingProvider)provider
{
    return [super initWithConstant:constant
                        attributes:attributes
                          provider:provider];
}

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeAbstract;
}

#pragma mark - Serialization

- (NSString*)textForConstant
{
    NSString* result = nil;

    if (self.constant)
    {
        result = self.constant.stringValue;
    }

    return result;
}

@end


#pragma mark - AKABooleanConstantBindingExpression
#pragma mark -

@implementation AKABooleanConstantBindingExpression

+ (AKABooleanConstantBindingExpression*)constantTrue
{
    static AKABooleanConstantBindingExpression* result;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result = [[AKABooleanConstantBindingExpression alloc] initWithConstant:YES];
    });

    return result;
}

+ (AKABooleanConstantBindingExpression*)constantFalse
{
    static AKABooleanConstantBindingExpression* result;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result = [[AKABooleanConstantBindingExpression alloc] initWithConstant:NO];
    });

    return result;
}

- (instancetype)initWithConstant:(BOOL)value
{
    self = [super initWithConstant:@(value)
                        attributes:nil
                          provider:nil];

    return self;
}

- (instancetype)initWithConstant:(opt_NSNumber)constant
                      attributes:(opt_AKABindingExpressionAttributes)attributes
                        provider:(opt_AKABindingProvider)provider
{
    if (constant == nil || attributes.count > 0)
    {
        self = [super initWithConstant:constant attributes:attributes provider:provider];
    }
    else if (constant.boolValue)
    {
        self = [AKABooleanConstantBindingExpression constantTrue];
    }
    else
    {
        self = [AKABooleanConstantBindingExpression constantFalse];
    }

    return self;
}

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeBooleanConstant;
}

#pragma mark - Serialization

- (NSString*)textForConstant
{
    NSString* result = nil;

    if (self.constant)
    {
        if (self.constant.boolValue)
        {
            result = [NSString stringWithFormat:@"$%@", [NSScanner keywordTrue]];
        }
        else
        {
            result = [NSString stringWithFormat:@"$%@", [NSScanner keywordFalse]];
        }
    }

    return result;
}

@end


#pragma mark - AKAIntegerConstantBindingExpression
#pragma mark -

@implementation AKAIntegerConstantBindingExpression


#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeIntegerConstant;
}

#pragma mark - Serialization

- (NSString*)textForConstant
{
    NSString* result = nil;

    if (self.constant)
    {
        result = [NSString stringWithFormat:@"%lld", self.constant.longLongValue];
    }

    return result;
}

@end


#pragma mark - AKAOptionsConstantBindingExpression
#pragma mark -

@implementation AKAOptionsConstantBindingExpression

+ (nonnull NSMutableDictionary<NSString*, NSDictionary<NSString*, NSNumber*>*>*) registry
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
            [AKAOptionsConstantBindingExpression registry][(req_NSString)optionsType];

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
        }
    }

    return result;
}

+ (BOOL)registerOptionsType:(req_NSString)enumerationType
           withValuesByName:(NSDictionary<NSString*, NSNumber*>* _Nonnull)valuesByName
{
    __block BOOL result = NO;

    NSAssert([NSThread isMainThread], @"Invalid attempt to register an enumeration type outside of main thread!");

    [enumerationType aka_performBlockInMainThreadOrQueue:^{
         NSMutableDictionary<NSString*, NSDictionary<NSString*, NSNumber*>*>* registry =
             [AKAOptionsConstantBindingExpression registry];

         if (!registry[enumerationType])
         {
             registry[enumerationType] = valuesByName;
             result = YES;
         }
     }
                                       waitForCompletion:YES];

    return result;
}

- (instancetype)initWithConstant:(opt_id)constant
                      attributes:(opt_AKABindingExpressionAttributes)attributes
                        provider:(opt_AKABindingProvider)provider
{
    NSString* optionsType;
    NSString* symbolicValue;
    NSNumber* value;
    NSDictionary* effectiveAttributes = attributes;

    if ([constant isKindOfClass:[NSString class]])
    {
        NSArray* components = [((NSString*)constant) componentsSeparatedByString:@"."];

        if (components.count == 1)
        {
            // If only one component is given, it is interpreted either as type or value
            if (attributes.count > 0)
            {
                // If there are attributes, the only reasonable interpretation is that the
                // constant is meant to be the enumeration type.
                optionsType = components.firstObject;
            }
            else
            {
                // If there are no attributes, the constant is interpreted as symbolic value
                symbolicValue = components.firstObject;
            }
        }
        else if (components.count == 2)
        {
            optionsType = components[0];
            symbolicValue = components[1];
        }
        else
        {
            NSString* reason = @"Too many dot-separated components, use $options {VALUE, ...}, $options.TYPE {VALUE, ...}, $options.VALUE or $options.TYPE.VALUE";
            NSString* name = [NSString stringWithFormat:@"Invalid options primary expression: %@: %@", constant, reason];

            [NSException exceptionWithName:name reason:reason userInfo:nil];
        }
    }
    else if ([constant isKindOfClass:[NSNumber class]])
    {
        value = constant;
    }
    else if (constant != nil)
    {
        NSString* reason = @"Invalid primary expression type, expected nil or an instance of NSString or NSNumber";
        NSString* name = [NSString stringWithFormat:@"Invalid options primary expression: %@: %@", constant, reason];

        [NSException exceptionWithName:name reason:reason userInfo:nil];
    }

    if (value != nil)
    {
        if (symbolicValue.length > 0)
        {
            if (effectiveAttributes.count == 0)
            {
                effectiveAttributes = @{ symbolicValue: [AKABooleanConstantBindingExpression constantTrue] };
            }
            else
            {
                NSMutableDictionary* tmp = [NSMutableDictionary dictionaryWithDictionary:effectiveAttributes];
                tmp[symbolicValue] = [AKABooleanConstantBindingExpression constantTrue];
            }
        }

        NSError* error;
        value = [AKAOptionsConstantBindingExpression resolveOptionsValue:effectiveAttributes
                                                                 forType:optionsType
                                                                   error:&error];

        if (!value && error) // if error is not set, value is validly undefined (f.e. no enumeration type yet)
        {
            @throw [NSException exceptionWithName:error.localizedDescription
                                           reason:error.localizedFailureReason
                                         userInfo:nil];
        }
    }

    if (self = [super initWithConstant:value attributes:attributes provider:provider])
    {
        self.optionsType = optionsType;
    }

    return self;
}

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeOptionsConstant;
}

#pragma mark - Serialization

- (NSString*)keyword
{
    return [NSScanner keywordOptions];
}

- (NSString*)textForConstant
{
    NSString* result = nil;

    if (self.constant)
    {
        if (self.attributes.count > 0)
        {
            NSString* optionsType = self.optionsType;

            if (optionsType == nil)
            {
                optionsType = @"";
            }
            result = [NSString stringWithFormat:@"$%@%@%@",
                      [self keyword],
                      (optionsType.length > 0 ? @"." : @""),
                      optionsType];
        }
    }

    return result;
}

@end


#pragma mark - AKAEnumConstantBindingExpression
#pragma mark -

@implementation AKAEnumConstantBindingExpression

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
            [AKAEnumConstantBindingExpression registry][(req_NSString)enumerationType];

        if (valuesByName != nil)
        {
            if (symbolicValue.length > 0)
            {
                result = valuesByName[(req_NSString)symbolicValue];

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

+ (BOOL)registerEnumerationType:(req_NSString)enumerationType
               withValuesByName:(NSDictionary<NSString*, id>* _Nonnull)valuesByName
{
    __block BOOL result = NO;

    NSAssert([NSThread isMainThread], @"Invalid attempt to register an enumeration type outside of main thread!");

    [enumerationType aka_performBlockInMainThreadOrQueue:^{
         NSMutableDictionary<NSString*, NSDictionary<NSString*, id>*>* registry =
             [AKAEnumConstantBindingExpression registry];

         if (!registry[enumerationType])
         {
             registry[enumerationType] = valuesByName;
             result = YES;
         }
     }
                                       waitForCompletion:YES];

    return result;
}

- (instancetype)initWithConstant:(opt_id)constant
                      attributes:(opt_AKABindingExpressionAttributes)attributes
                        provider:(opt_AKABindingProvider)provider
{
    NSString* enumerationType;
    NSString* symbolicValue;
    id value;

    if (attributes)
    {
        value = attributes[@"value"];
    }

    if ([constant isKindOfClass:[NSString class]])
    {
        NSArray* components = [((NSString*)constant) componentsSeparatedByString:@"."];

        if (components.count == 1)
        {
            // If only one component is given, it is interpreted either as type or value
            if (attributes[@"value"] != nil)
            {
                // If there are attributes, the only reasonable interpretation is that the
                // constant is meant to be the enumeration type.
                enumerationType = components.firstObject;
            }
            else
            {
                // If there are no attributes, the constant is interpreted as symbolic value
                symbolicValue = components.firstObject;
            }
        }
        else if (components.count == 2)
        {
            enumerationType = components[0];
            symbolicValue = components[1];
        }
        else
        {
            NSString* reason = @"Too many dot-separated components, use $enum, $enum.TYPE, $enum.VALUE, $enum.TYPE.VALUE or use $enum or $enum.TYPE { value: <constant expression> } to specify a non-symbolic value; note that an unspecified value is interpreted as nil or zero in numeric contexts";
            NSString* name = [NSString stringWithFormat:@"Invalid enumeration primary expression: %@: %@", constant, reason];

            [NSException exceptionWithName:name reason:reason userInfo:nil];
        }
    }
    else if (constant != nil)
    {
        NSString* reason = @"Invalid primary expression type, expected nil or an instance of NSString or NSNumber";
        NSString* name = [NSString stringWithFormat:@"Invalid enumeration primary expression: %@: %@", constant, reason];

        [NSException exceptionWithName:name reason:reason userInfo:nil];
    }

    if (value == nil && symbolicValue.length > 0 && enumerationType.length > 0)
    {
        NSError* error;
        value = [AKAEnumConstantBindingExpression resolveEnumeratedValue:symbolicValue
                                                                 forType:enumerationType
                                                                   error:&error];

        if (!value && error) // if error is not set, value is validly undefined (f.e. no enumeration type yet)
        {
            @throw [NSException exceptionWithName:error.localizedDescription
                                           reason:error.localizedFailureReason
                                         userInfo:nil];
        }
    }

    if (self = [super initWithConstant:value attributes:attributes provider:provider])
    {
        self.enumerationType = enumerationType;
        self.symbolicValue = symbolicValue;
    }

    return self;
}

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeEnumConstant;
}

- (NSString*)keyword
{
    return [NSScanner keywordEnum];
}

- (NSString*)textForConstant
{
    NSString* result = nil;

    if (self.constant)
    {
        if (self.attributes.count > 0)
        {
            NSString* enumerationType = self.enumerationType;

            if (enumerationType == nil)
            {
                enumerationType = @"";
            }
            NSString* symbolicValue = self.symbolicValue;

            if (symbolicValue == nil)
            {
                symbolicValue = @"";
            }
            result = [NSString stringWithFormat:@"$%@%@%@%@%@",
                      [self keyword],
                      (enumerationType.length > 0 ? @"." : @""),
                      enumerationType,
                      (symbolicValue.length > 0 ? @"." : @""),
                      symbolicValue];
        }
    }

    return result;
}

@end


#pragma mark - AKADoubleConstantBindingExpression
#pragma mark -

@implementation AKADoubleConstantBindingExpression

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeDouble;
}

#pragma mark - Serialization

- (NSString*)textForConstant
{
    NSString* result = nil;

    if (self.constant)
    {
        result = [NSString stringWithFormat:@"%g", self.constant.doubleValue];
    }

    return result;
}

@end


#pragma mark - AKAColorConstantBindingExpression
#pragma mark -

@implementation AKAColorConstantBindingExpression

#pragma mark - Initialization

+ (NSNumber*) colorComponentWithKeys:(NSArray<NSString*>*)keys
                      fromAttributes:(opt_AKABindingExpressionAttributes)attributes
                            required:(BOOL)required
{
    NSNumber* result = nil;
    AKABindingExpression* expression = nil;
    NSString* providedKey = nil;

    for (NSString* key in keys)
    {
        expression = attributes[key];

        if (expression)
        {
            providedKey = key;
            break;
        }
    }

    if ([expression isKindOfClass:[AKADoubleConstantBindingExpression class]])
    {
        AKANumberConstantBindingExpression* numberExpression = (id)expression;
        double doubleValue = numberExpression.constant.doubleValue;

        if (doubleValue < 0 || doubleValue > 1.0)
        {
            NSString* message = [NSString stringWithFormat:@"Invalid value %lf for color component %@ (valid aliases: %@), floating point values have to be in range [0 .. 1.0]", doubleValue, keys.firstObject, [keys componentsJoinedByString:@", "]];
            @throw [NSException exceptionWithName:message reason:message userInfo:nil];
        }
        else
        {
            // normalize double values to range [0 .. 255.0], this will be undone when both integer and
            // double values get normalized to range 0 .. 1.0.
            result = @(doubleValue * 255);
        }
    }
    else if ([expression isKindOfClass:[AKAIntegerConstantBindingExpression class]])
    {
        AKANumberConstantBindingExpression* numberExpression = (id)expression;
        NSInteger integerValue = numberExpression.constant.integerValue;

        if (integerValue < 0 || integerValue > 255)
        {
            NSString* message = [NSString stringWithFormat:@"Invalid value %ld for color component %@ (valid aliases: %@), integer values have to be in range [0 .. 255]", (long)integerValue, keys.firstObject, [keys componentsJoinedByString:@", "]];
            @throw [NSException exceptionWithName:message reason:message userInfo:nil];
        }
        else
        {
            result = numberExpression.constant;
        }
    }
    else if (expression)
    {
        NSString* message = [NSString stringWithFormat:@"Invalid type %@ for color component %@, expected a numeric constant in range [0 .. 1.0]", NSStringFromClass(expression.class), providedKey];
        @throw [NSException exceptionWithName:message reason:message userInfo:nil];
    }

    if (result == nil && required)
    {
        NSString* message = [NSString stringWithFormat:@"No value for color component %@ (valid aliases: %@), expected a numeric constant in range [0 .. 1.0] (floating point) or [0 .. 255] (integer)", keys.firstObject, [keys componentsJoinedByString:@", "]];
        @throw [NSException exceptionWithName:message reason:message userInfo:nil];
    }

    return result;
}

- (instancetype)initWithConstant:(opt_id)constant
                      attributes:(opt_AKABindingExpressionAttributes)attributes
                        provider:(opt_AKABindingProvider)provider
{
    UIColor* color = nil;

    if ([constant isKindOfClass:[UIColor class]])
    {
        color = constant;
    }

    if ((color && attributes.count > 0) || (!color && attributes.count == 0))
    {
        // TODO: add error parameter instead of throwing exception
        @throw [NSException exceptionWithName:@"Invalid specification of attributes for color definition. Attributes are required when no color is defined as primary expression and forbidden otherwise" reason:@"Attributes are required when no color is defined as primary expression and forbidden otherwise" userInfo:nil];
        self = nil;
    }
    else if (!color)
    {
        // colorComponentWithKeys... normalizes values to double or long long values to the range 0 .. 255(.0)
        // using the type information available from numeric constant binding expressions:

        CGFloat red = [AKAUIColorConstantBindingExpression colorComponentWithKeys:@[ @"r", @"red" ]
                                                                   fromAttributes:attributes
                                                                         required:YES].floatValue / 255.0f;
        CGFloat green = [AKAUIColorConstantBindingExpression colorComponentWithKeys:@[ @"g", @"green" ]
                                                                     fromAttributes:attributes
                                                                           required:YES].floatValue / 255.0f;
        CGFloat blue = [AKAUIColorConstantBindingExpression colorComponentWithKeys:@[ @"b", @"blue" ]
                                                                    fromAttributes:attributes
                                                                          required:YES].floatValue / 255.0f;
        NSNumber* nalpha = [AKAUIColorConstantBindingExpression colorComponentWithKeys:@[ @"a", @"alpha" ]
                                                                        fromAttributes:attributes
                                                                              required:NO];
        CGFloat alpha = nalpha ? nalpha.floatValue : 1.0;

        color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];

        // TODO: we could/should validate attributes to warn/fail on unknown keys
        if (attributes.count != (nalpha ? 4 : 3))
        {
            NSString* message = [NSString stringWithFormat:@"Unsupported color attribute (one of: %@); supported attributes are 'r' or 'red', 'g' or 'green', 'b' or 'blue' and 'a' or 'alpha'; (HSB/CMY not yet supported)", [attributes.allKeys componentsJoinedByString:@", "]];
            @throw [NSException exceptionWithName:message reason:message userInfo:nil];
        }
    }
    self = [super initWithConstant:color attributes:nil provider:provider];

    return self;
}

#pragma mark - Access

- (UIColor*)UIColor
{
    return self.constant;
}

#pragma mark - Serialization

- (NSString*)keyword
{
    AKAErrorAbstractMethodImplementationMissing();
}

- (NSString*)textForColorComponent:(CGFloat)component
{
    NSString* result = nil;

    // Convert component to byte value and determine if distance from  next integer is small enough
    // to allow representation as int:
    CGFloat channel = component * 255.0f;
    double integral;
    double fractional = modf(channel, &integral);

    // Greatest double/char conversion error in range [0..255] is for 128 with 0.000007569
    if (fractional < .00001)
    {
        // We represent numbers with a smaller error (leaving some margin for differences on
        // iOS hardware) as integer...
        result = [NSString stringWithFormat:@"%d", (int)integral];
    }
    else
    {
        // ... and everything else as double
        result = [NSString stringWithFormat:@"%lg", (double)component];
    }

    return result;
}

- (NSString*)textForConstant
{
    NSString* result = nil;

    if (self.constant)
    {
        UIColor* color = [self UIColor];
        CGFloat red;
        CGFloat green;
        CGFloat blue;
        CGFloat alpha;
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        result = [NSString stringWithFormat:@"$%@ { r:%@, g:%@, b:%@, a:%@ }",
                  [self keyword],
                  [self textForColorComponent:red],
                  [self textForColorComponent:green],
                  [self textForColorComponent:blue],
                  [self textForColorComponent:alpha]];
    }

    return result;
}

@end


#pragma mark - AKAUIColorConstantBindingExpression
#pragma mark -

@implementation AKAUIColorConstantBindingExpression

#pragma mark - Serialization

- (NSString*)keyword
{
    return [NSScanner keywordUIColor];
}

@end


#pragma mark - AKACGColorConstantBindingExpression
#pragma mark -

@implementation AKACGColorConstantBindingExpression

- (id)constant
{
    id result = super.constant;

    if ([result isKindOfClass:[UIColor class]])
    {
        // TODO: does it have to be retained here? Don't think so, check later
        result = (__bridge id)[(UIColor*)result CGColor];
    }

    return result;
}

- (UIColor*)UIColor
{
    return super.constant;
}

#pragma mark - Serialization

- (NSString*)keyword
{
    return [NSScanner keywordCGColor];
}

@end


#pragma mark - AKAUIFontConstantBindingExpression
#pragma mark -

@implementation AKAUIFontConstantBindingExpression

#pragma mark - Initialization

+ (UIFont*)fontForDescriptor:(UIFontDescriptor*)descriptor
{
    UIFont* result = nil;
    NSString* fontName = nil;
    CGFloat fontSize = 0;
    NSString* textStyle = nil;

    fontName = descriptor.fontAttributes[UIFontDescriptorNameAttribute];
    fontSize = ((NSNumber*)descriptor.fontAttributes[UIFontDescriptorSizeAttribute]).floatValue;

    if (textStyle != nil)
    {
        result = [UIFont preferredFontForTextStyle:textStyle];
    }
    else if (fontName && fontSize > 0)
    {
        result = [UIFont fontWithName:fontName size:fontSize];
    }
    else
    {
        // TODO: error handling or "best match" selection
        NSAssert(NO, @"Insufficient font specification in descriptor %@", descriptor);
    }

    return result;
}

+ (NSString*)stringForAttribute:(NSString*)attributeName
              bindingExpression:(AKABindingExpression*)bindingExpression
                          error:(out_NSError)error
{
    NSString* result = nil;

    if ([bindingExpression isKindOfClass:[AKAStringConstantBindingExpression class]])
    {
        result = ((AKAStringConstantBindingExpression*)bindingExpression).constant;
    }
    else if (error)
    {
        *error = [AKABindingErrors invalidBindingExpression:bindingExpression
                                          forAttributeNamed:attributeName
                                        invalidTypeExpected:@[ [AKAStringConstantBindingExpression class] ]];
    }

    return result;
}

+ (NSNumber*)numberForAttribute:(NSString*)attributeName
              bindingExpression:(AKABindingExpression*)bindingExpression
                          error:(out_NSError)error
{
    NSNumber* result = nil;

    if ([bindingExpression isKindOfClass:[AKANumberConstantBindingExpression class]])
    {
        result = ((AKANumberConstantBindingExpression*)bindingExpression).constant;
    }
    else if (error)
    {
        *error = [AKABindingErrors invalidBindingExpression:bindingExpression
                                          forAttributeNamed:attributeName
                                        invalidTypeExpected:@[ [AKANumberConstantBindingExpression class] ]];
    }

    return result;
}

+ (NSNumber*)doubleNumberInRangeMin:(double)min
                                max:(double)max
                       forAttribute:(NSString*)attributeName
                  bindingExpression:(AKABindingExpression*)bindingExpression
                              error:(out_NSError)error
{
    NSNumber* result = nil;

    if ([bindingExpression isKindOfClass:[AKANumberConstantBindingExpression class]])
    {
        result = ((AKANumberConstantBindingExpression*)bindingExpression).constant;

        if (result)
        {
            double value = result.doubleValue;

            if (value < min || value > max)
            {
                // TODO: out of range error
            }
        }
    }
    else if (error)
    {
        *error = [AKABindingErrors invalidBindingExpression:bindingExpression
                                          forAttributeNamed:attributeName
                                        invalidTypeExpected:@[ [AKANumberConstantBindingExpression class] ]];
    }

    return result;
}

+ (id)enumeratedValueOfType:(req_NSString)enumerationType
               forAttribute:(NSString*)attributeName
          bindingExpression:(AKABindingExpression*)bindingExpression
                      error:(out_NSError)error
{
    NSNumber* result = nil;

    NSError* localError = nil;

    if ([bindingExpression isKindOfClass:[AKAEnumConstantBindingExpression class]])
    {
        AKAEnumConstantBindingExpression* enumExpression = (id)bindingExpression;

        if (enumExpression.enumerationType.length == 0 ||
            [enumerationType isEqualToString:(req_NSString)enumExpression.enumerationType])
        {
            result = enumExpression.constant;

            if (result == nil && enumExpression.symbolicValue.length > 0)
            {
                result = [AKAEnumConstantBindingExpression resolveEnumeratedValue:enumExpression.symbolicValue
                                                                          forType:enumerationType
                                                                            error:&localError];
            }
        }
    }
    else if ([bindingExpression isKindOfClass:[AKAConstantBindingExpression class]])
    {
        result = ((AKAConstantBindingExpression*)bindingExpression).constant;
    }
    else
    {
        localError =
            [AKABindingErrors invalidBindingExpression:bindingExpression
                                     forAttributeNamed:attributeName
                                   invalidTypeExpected:@[ [AKAEnumConstantBindingExpression class],
                                                          [AKAConstantBindingExpression class] ]];
    }

    if (!result && localError != nil)
    {
        if (error)
        {
            *error = localError;
        }
        else
        {
            @throw [NSException exceptionWithName:localError.localizedDescription
                                           reason:localError.localizedFailureReason
                                         userInfo:nil];
        }
    }

    return result;
}

+ (NSNumber*)optionsValueOfType:(req_NSString)optionsType
                   forAttribute:(NSString*)attributeName
              bindingExpression:(AKABindingExpression*)bindingExpression
                          error:(out_NSError)error
{
    NSNumber* result = nil;

    NSError* localError = nil;

    if ([bindingExpression isKindOfClass:[AKAOptionsConstantBindingExpression class]])
    {
        AKAOptionsConstantBindingExpression* enumExpression = (id)bindingExpression;

        if (enumExpression.optionsType.length == 0 ||
            [optionsType isEqualToString:(req_NSString)enumExpression.optionsType])
        {
            result = enumExpression.constant;

            if (result == nil && enumExpression.attributes.count > 0)
            {
                result = [AKAOptionsConstantBindingExpression resolveOptionsValue:enumExpression.attributes
                                                                          forType:optionsType
                                                                            error:&localError];
            }
        }
    }
    else if ([bindingExpression isKindOfClass:[AKANumberConstantBindingExpression class]])
    {
        result = ((AKANumberConstantBindingExpression*)bindingExpression).constant;
    }
    else if (bindingExpression.class == [AKABindingExpression class])
    {
        result = [AKAOptionsConstantBindingExpression resolveOptionsValue:bindingExpression.attributes
                                                                  forType:optionsType
                                                                    error:&localError];
    }
    else
    {
        localError =
            [AKABindingErrors invalidBindingExpression:bindingExpression
                                     forAttributeNamed:attributeName
                                   invalidTypeExpected:@[ [AKAOptionsConstantBindingExpression class],
                                                          [AKANumberConstantBindingExpression class],
                                                          [AKABindingExpression class] ]];
    }

    if (!result && localError != nil)
    {
        if (error)
        {
            *error = localError;
        }
        else
        {
            @throw [NSException exceptionWithName:localError.localizedDescription
                                           reason:localError.localizedFailureReason
                                         userInfo:nil];
        }
    }

    return result;
}

+ (NSNumber*)uifontSymbolicTraitForAttribute:(NSString*)attributeName
                           bindingExpression:(AKABindingExpression*)bindingExpression
                                       error:(out_NSError)error
{
    NSString* optionsType = @"UIFontDescriptorSymbolicTraits";
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        [AKAOptionsConstantBindingExpression registerOptionsType:optionsType
                                                withValuesByName:[AKANSEnumerations uifontDescriptorTraitsByName]];
    });

    return [self optionsValueOfType:optionsType
                       forAttribute:attributeName
                  bindingExpression:bindingExpression
                              error:error];
}

+ (NSNumber*)uifontWeightTraitForAttribute:(NSString*)attributeName
                         bindingExpression:(AKABindingExpression*)bindingExpression
                                     error:(out_NSError)error
{
    NSString* enumerationType = @"AKAUIFontDescriptorWeightTraits";
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        [AKAEnumConstantBindingExpression registerEnumerationType:enumerationType
                                                 withValuesByName:[AKANSEnumerations uifontWeightsByName]];
    });

    return [self enumeratedValueOfType:enumerationType
                          forAttribute:attributeName
                     bindingExpression:bindingExpression
                                 error:error];
}

+ (NSNumber*)uifontWidthTraitForAttribute:(NSString*)attributeName
                        bindingExpression:(AKABindingExpression*)bindingExpression
                                    error:(out_NSError)error
{
    return [self doubleNumberInRangeMin:-1.0
                                    max:1.0
                           forAttribute:attributeName
                      bindingExpression:bindingExpression
                                  error:error];
}

+ (NSNumber*)uifontSlantTraitForAttribute:(NSString*)attributeName
                        bindingExpression:(AKABindingExpression*)bindingExpression
                                    error:(out_NSError)error
{
    return [self doubleNumberInRangeMin:-1.0
                                    max:1.0
                           forAttribute:attributeName
                      bindingExpression:bindingExpression
                                  error:error];
}

+ (NSDictionary<NSString*, BOOL (^)(NSMutableDictionary*, AKABindingExpression*, out_NSError)>*)fontAttributesParsersByAttributeName
{
    static NSDictionary<NSString*, BOOL (^)(NSMutableDictionary*, AKABindingExpression*, out_NSError)>* result;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result =
            @{ @"family":
               ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error)
               {
                   NSString* string = fa[UIFontDescriptorFamilyAttribute] =
                                          [AKAUIFontConstantBindingExpression stringForAttribute:@"family"
                                                                               bindingExpression:bindingExpression
                                                                                           error:error];

                   return string != nil;
               },

               @"name":
               ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error)
               {
                   NSString* string = fa[UIFontDescriptorNameAttribute] =
                                          [AKAUIFontConstantBindingExpression stringForAttribute:@"name"
                                                                               bindingExpression:bindingExpression
                                                                                           error:error];

                   return string != nil;
               },

               @"face":
               ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error)
               {
                   NSString* string = fa[UIFontDescriptorFaceAttribute] =
                                          [AKAUIFontConstantBindingExpression stringForAttribute:@"face"
                                                                               bindingExpression:bindingExpression
                                                                                           error:error];

                   return string != nil;
               },

               @"size":
               ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error)
               {
                   NSNumber* number = fa[UIFontDescriptorSizeAttribute] =
                                          [AKAUIFontConstantBindingExpression numberForAttribute:@"size"
                                                                               bindingExpression:bindingExpression
                                                                                           error:error];

                   return number != nil;
               },

               @"visibleName":
               ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error)
               {
                   NSString* string = fa[UIFontDescriptorVisibleNameAttribute] =
                                          [AKAUIFontConstantBindingExpression stringForAttribute:@"visibleName"
                                                                               bindingExpression:bindingExpression
                                                                                           error:error];

                   return string != nil;
               },

               @"traits":
               ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error) {
                   NSError* localError = nil;
                   NSDictionary* dictionary = fa[UIFontDescriptorTraitsAttribute] =
                                                  [AKAUIFontConstantBindingExpression uifontTraitsForBindingExpression:bindingExpression
                                                                                                                 error:&localError];

                   if (!dictionary && localError != nil && error != nil)
                   {
                       *error = [AKABindingErrors invalidBindingExpression:bindingExpression
                                                         forAttributeNamed:@"traits"
                                                         uifontTraitsError:localError];
                   }

                   return dictionary != nil;
               },

               @"fixedAdvance":
               ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error) {
                   NSNumber* number = fa[UIFontDescriptorFixedAdvanceAttribute] =
                                          [AKAUIFontConstantBindingExpression numberForAttribute:@"fixedAdvance"
                                                                               bindingExpression:bindingExpression
                                                                                           error:error];

                   return number != nil;
               },

               @"textStyle":
               ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error) {
                   NSString* textStyle =
                       [AKAUIFontConstantBindingExpression stringForAttribute:@"textStyle"
                                                            bindingExpression:bindingExpression
                                                                        error:error];
                   fa[UIFontDescriptorTextStyleAttribute] =
                       [AKANSEnumerations textStyleForName:textStyle];

                   return textStyle != nil;
               },

               /*
                  // TODO: decide whether we have to implement these:
                  @"matrix":
                  ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error) {
                   AKAErrorMethodNotImplemented();
                  },
                  @"characterSet":
                  ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error) {
                   AKAErrorMethodNotImplemented();
                  },
                  @"cascadeList":
                  ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error) {
                   AKAErrorMethodNotImplemented();
                  },
                  @"featureSettings":
                  ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error) {
                   AKAErrorMethodNotImplemented();
                  },
                */
        };
    });

    return result;
}

+ (NSDictionary<NSString*, BOOL (^)(NSMutableDictionary*, AKABindingExpression*, out_NSError)>*)fontTraitsParsersByAttributeName
{
    static NSDictionary<NSString*, BOOL (^)(NSMutableDictionary*, AKABindingExpression*, out_NSError)>* result;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result =
            @{ @"symbolic":
               ^BOOL (NSMutableDictionary* traits, AKABindingExpression* bindingExpression, out_NSError error)
               {
                   NSNumber* number = traits[UIFontSymbolicTrait] =
                                          [AKAUIFontConstantBindingExpression uifontSymbolicTraitForAttribute:@"symbolic"
                                                                                            bindingExpression:bindingExpression
                                                                                                        error:error];

                   return number != nil;
               },

               @"weight":
               ^BOOL (NSMutableDictionary* traits, AKABindingExpression* bindingExpression, out_NSError error)
               {
                   NSNumber* number = traits[UIFontWeightTrait] =
                                          [AKAUIFontConstantBindingExpression uifontWeightTraitForAttribute:@"weight"
                                                                                          bindingExpression:bindingExpression
                                                                                                      error:error];

                   return number != nil;
               },

               @"width":
               ^BOOL (NSMutableDictionary* traits, AKABindingExpression* bindingExpression, out_NSError error)
               {
                   NSNumber* number = traits[UIFontWidthTrait] =
                                          [AKAUIFontConstantBindingExpression uifontWidthTraitForAttribute:@"width"
                                                                                         bindingExpression:bindingExpression
                                                                                                     error:error];

                   return number != nil;
               },

               @"slant":
               ^BOOL (NSMutableDictionary* traits, AKABindingExpression* bindingExpression, out_NSError error)
               {
                   NSNumber* number = traits[UIFontSlantTrait] =
                                          [AKAUIFontConstantBindingExpression uifontSlantTraitForAttribute:@"slant"
                                                                                         bindingExpression:bindingExpression
                                                                                                     error:error];

                   return number != nil;
               }
        };
    });

    return result;
}

+ (NSDictionary*)uifontTraitsForBindingExpression:(AKABindingExpression*)bindingExpression
                                            error:(out_NSError)error
{
    __block NSMutableDictionary* result = [NSMutableDictionary new];

    if (bindingExpression.class != [AKABindingExpression class])
    {
        // TODO: add error parameter instead of throwing exception
        NSString* message = @"Invalid specification of traits for UIFont, traits cannot be specified using a binding expression's primary expression.";
        @throw [NSException exceptionWithName:message reason:message userInfo:nil];
    }
    else if (bindingExpression.attributes.count > 0)
    {
        NSDictionary<NSString*, BOOL (^)(NSMutableDictionary*, AKABindingExpression*, out_NSError)>* spec =
            [AKAUIFontConstantBindingExpression fontAttributesParsersByAttributeName];

        NSMutableDictionary* traits = [NSMutableDictionary new];

        [bindingExpression.attributes
         enumerateKeysAndObjectsUsingBlock:
         ^(req_NSString traitAttributeName,
           req_AKABindingExpression traitBindingExpression,
           outreq_BOOL stop)
         {
             BOOL (^processAttribute)(NSMutableDictionary*, AKABindingExpression*, out_NSError error) =
                 spec[traitAttributeName];

             if (processAttribute)
             {
                 if (!processAttribute(traits, traitBindingExpression, error))
                 {
                     *stop = YES;
                     result = nil;
                 }
             }
             else
             {
                 *stop = YES;
                 result = nil;

                 if (error)
                 {
                     *error = [AKABindingErrors invalidBindingExpression:traitBindingExpression
                                                        unknownAttribute:traitAttributeName];
                 }
             }
         }];
    }

    return result;
}

- (instancetype)initWithConstant:(opt_id)constant
                      attributes:(opt_AKABindingExpressionAttributes)attributes
                        provider:(opt_AKABindingProvider)provider
{
    UIFont* font = nil;

    if ([constant isKindOfClass:[UIFont class]])
    {
        font = constant;
    }
    else if ([constant isKindOfClass:[UIFontDescriptor class]])
    {
        font = [AKAUIFontConstantBindingExpression fontForDescriptor:constant];
    }

    if ((font && attributes.count > 0) || (!font && attributes.count == 0))
    {
        // TODO: add error parameter instead of throwing exception
        NSString* message = @"Invalid specification of attributes for UIFont. Attributes are required when no font or font descriptor is defined as primary expression and forbidden otherwise";
        @throw [NSException exceptionWithName:message reason:message userInfo:nil];
        self = nil;
    }
    else if (!font)
    {
        NSDictionary<NSString*, BOOL (^)(NSMutableDictionary*, AKABindingExpression*, out_NSError)>* spec =
            [AKAUIFontConstantBindingExpression fontAttributesParsersByAttributeName];

        NSMutableDictionary* fontAttributes = [NSMutableDictionary new];

        [attributes enumerateKeysAndObjectsUsingBlock:
         ^(req_NSString attributeName,
           req_AKABindingExpression bindingExpression,
           outreq_BOOL stop)
         {
             BOOL (^processAttribute)(NSMutableDictionary*, AKABindingExpression*, out_NSError error) =
                 spec[attributeName];

             if (processAttribute)
             {
                 NSError* error;

                 if (!processAttribute(fontAttributes, bindingExpression, &error))
                 {
                     *stop = YES;
                     // TODO: add error parameter instead of throwing exception
                     @throw [NSException exceptionWithName:error.localizedDescription
                                                    reason:error.localizedFailureReason
                                                  userInfo:nil];
                 }
             }
             else
             {
                 // TODO: add error parameter instead of throwing exception
                 @throw [NSException exceptionWithName:@"Invalid (unknown) font descriptor specification attribute"
                                                reason:nil
                                              userInfo:nil];
             }
         }];

        UIFontDescriptor* descriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:fontAttributes];
        font = [AKAUIFontConstantBindingExpression fontForDescriptor:descriptor];
    }

    self = [super initWithConstant:font attributes:nil provider:provider];

    return self;
}

#pragma mark - Serialization

- (NSString*)keyword
{
    return [NSScanner keywordUIFont];
}

- (NSString*)textForConstant
{
    NSString* result = nil;

    if (self.constant)
    {
        UIFont* font = ((UIFont*)self.constant);
        result = [NSString stringWithFormat:@"$%@ { name: \"%@\", size: %lg", [self keyword], font.fontName, font.pointSize];
    }

    return result;
}

@end


#pragma mark - AKACGPointConstantBindingExpression
#pragma mark -

@implementation AKACGPointConstantBindingExpression

#pragma mark - Initialization

+ (NSNumber*) coordinateWithKeys:(NSArray<NSString*>*)keys
                  fromAttributes:(opt_AKABindingExpressionAttributes)attributes
                        required:(BOOL)required
{
    NSNumber* result = nil;
    AKABindingExpression* expression = nil;
    NSString* providedKey = nil;

    for (NSString* key in keys)
    {
        expression = attributes[key];

        if (expression)
        {
            providedKey = key;
            break;
        }
    }

    if ([expression isKindOfClass:[AKANumberConstantBindingExpression class]])
    {
        AKANumberConstantBindingExpression* numberExpression = (id)expression;
        result = numberExpression.constant;
    }
    else
    {
        NSString* message = [NSString stringWithFormat:@"Invalid type %@ for coordinate %@, expected a numeric constant", NSStringFromClass(expression.class), providedKey];
        @throw [NSException exceptionWithName:message reason:message userInfo:nil];
    }

    if (result == nil && required)
    {
        NSString* message = [NSString stringWithFormat:@"No value for coordinate %@ (valid aliases: %@), expected a numeric constant", keys.firstObject, [keys componentsJoinedByString:@", "]];
        @throw [NSException exceptionWithName:message reason:message userInfo:nil];
    }

    return result;
}

- (instancetype)initWithConstant:(opt_id)constant
                      attributes:(opt_AKABindingExpressionAttributes)attributes
                        provider:(opt_AKABindingProvider)provider
{
    NSValue* value = nil;

    if ([constant isKindOfClass:[NSValue class]])
    {
        NSParameterAssert(strcmp([((NSValue*)constant) objCType], @encode(CGPoint)) == 0);
        value = constant;
    }

    if ((value && attributes.count > 0) || (!value && attributes.count == 0))
    {
        // TODO: add error parameter instead of throwing exception
        NSString* message = @"Invalid specification of attributes for CGPoint. Attributes are required when no point is defined as primary expression and forbidden otherwise";
        @throw [NSException exceptionWithName:message reason:message userInfo:nil];
        self = nil;
    }
    else if (!value)
    {
        CGFloat x = [AKACGPointConstantBindingExpression coordinateWithKeys:@[ @"x" ]
                                                             fromAttributes:attributes
                                                                   required:YES].floatValue;
        CGFloat y = [AKACGPointConstantBindingExpression coordinateWithKeys:@[ @"y" ]
                                                             fromAttributes:attributes
                                                                   required:YES].floatValue;
        value = [NSValue valueWithCGPoint:CGPointMake(x, y)];
    }
    self = [super initWithConstant:value attributes:nil provider:provider];

    return self;
}

#pragma mark - Serialization

- (NSString*)keyword
{
    return [NSScanner keywordCGPoint];
}

- (NSString*)textForConstant
{
    NSString* result = nil;

    if (self.constant)
    {
        CGPoint value = ((NSValue*)self.constant).CGPointValue;
        result = [NSString stringWithFormat:@"$%@ { x:%g, y:%g }", [self keyword], value.x, value.y];
    }

    return result;
}

@end


#pragma mark - AKACGSizeConstantBindingExpression
#pragma mark -

@implementation AKACGSizeConstantBindingExpression

#pragma mark - Initialization

- (instancetype)initWithConstant:(opt_id)constant
                      attributes:(opt_AKABindingExpressionAttributes)attributes
                        provider:(opt_AKABindingProvider)provider
{
    NSValue* value = nil;

    if ([constant isKindOfClass:[NSValue class]])
    {
        NSParameterAssert(strcmp([((NSValue*)constant) objCType], @encode(CGRect)) == 0);
        value = constant;
    }

    if ((value && attributes.count > 0) || (!value && attributes.count == 0))
    {
        // TODO: add error parameter instead of throwing exception
        NSString* message = @"Invalid specification of attributes for CGRect. Attributes are required when no rectangle is defined as primary expression and forbidden otherwise";
        @throw [NSException exceptionWithName:message reason:message userInfo:nil];
        self = nil;
    }
    else if (!value)
    {
        CGFloat w = [AKACGPointConstantBindingExpression coordinateWithKeys:@[ @"w", @"width" ]
                                                             fromAttributes:attributes
                                                                   required:YES].floatValue;
        CGFloat h = [AKACGPointConstantBindingExpression coordinateWithKeys:@[ @"h", @"height" ]
                                                             fromAttributes:attributes
                                                                   required:YES].floatValue;
        value = [NSValue valueWithCGSize:CGSizeMake(w, h)];
    }
    self = [super initWithConstant:value attributes:nil provider:provider];

    return self;
}

#pragma mark - Serialization

- (NSString*)keyword
{
    return [NSScanner keywordCGSize];
}

- (NSString*)textForConstant
{
    NSString* result = nil;

    if (self.constant)
    {
        CGSize value = ((NSValue*)self.constant).CGSizeValue;
        result = [NSString stringWithFormat:@"$%@ { w:%g, h:%g }", [self keyword], value.width, value.height];
    }

    return result;
}

@end


#pragma mark - AKACGRectConstantBindingExpression
#pragma mark -

@implementation AKACGRectConstantBindingExpression

#pragma mark - Initialization

- (instancetype)initWithConstant:(opt_id)constant
                      attributes:(opt_AKABindingExpressionAttributes)attributes
                        provider:(opt_AKABindingProvider)provider
{
    NSValue* value = nil;

    if ([constant isKindOfClass:[NSValue class]])
    {
        NSParameterAssert(strcmp([((NSValue*)constant) objCType], @encode(CGRect)) == 0);
        value = constant;
    }

    if ((value && attributes.count > 0) || (!value && attributes.count == 0))
    {
        // TODO: add error parameter instead of throwing exception
        NSString* message = @"Invalid specification of attributes for CGRect. Attributes are required when no rectangle is defined as primary expression and forbidden otherwise";
        @throw [NSException exceptionWithName:message reason:message userInfo:nil];
        self = nil;
    }
    else if (!value)
    {
        CGFloat x = [AKACGPointConstantBindingExpression coordinateWithKeys:@[ @"x" ]
                                                             fromAttributes:attributes
                                                                   required:YES].floatValue;
        CGFloat y = [AKACGPointConstantBindingExpression coordinateWithKeys:@[ @"y" ]
                                                             fromAttributes:attributes
                                                                   required:YES].floatValue;
        CGFloat w = [AKACGPointConstantBindingExpression coordinateWithKeys:@[ @"w", @"width" ]
                                                             fromAttributes:attributes
                                                                   required:YES].floatValue;
        CGFloat h = [AKACGPointConstantBindingExpression coordinateWithKeys:@[ @"h", @"height" ]
                                                             fromAttributes:attributes
                                                                   required:YES].floatValue;
        value = [NSValue valueWithCGRect:CGRectMake(x, y, w, h)];
    }
    self = [super initWithConstant:value attributes:nil provider:provider];

    return self;
}

#pragma mark - Serialization

- (NSString*)keyword
{
    return [NSScanner keywordCGRect];
}

- (NSString*)textForConstant
{
    NSString* result = nil;

    if (self.constant)
    {
        CGRect value = ((NSValue*)self.constant).CGRectValue;
        result = [NSString stringWithFormat:@"$%@ { x:%g, y:%g, w:%g, h:%g }", [self keyword], value.origin.x, value.origin.y, value.size.width, value.size.height];
    }

    return result;
}

@end


#pragma mark - AKAKeyPathBindingExpression
#pragma mark -

@implementation AKAKeyPathBindingExpression

#pragma mark - Initialization

- (instancetype)initWithKeyPath:(NSString*)keyPath
                     attributes:(NSDictionary<NSString*, AKABindingExpression*>* __nullable)attributes
                       provider:(opt_AKABindingProvider)provider
{
    if (self = [super initWithAttributes:attributes
                                provider:provider])
    {
        _keyPath = keyPath;
    }

    return self;
}

- (instancetype _Nullable)initWithPrimaryExpression:(opt_id)primaryExpression
                                         attributes:(opt_AKABindingExpressionAttributes)attributes
                                           provider:(opt_AKABindingProvider)provider
{
    return [self initWithKeyPath:primaryExpression
                      attributes:attributes
                        provider:provider];
}

#pragma mark - Binding Support

- (opt_AKAUnboundProperty)bindingSourceUnboundPropertyInContext:(req_AKABindingContext)bindingContext
{
    (void)bindingContext; // Not used yet, this will most likely be needed for computations requiring the context in addition to a property target

    opt_AKAUnboundProperty result = nil;
    opt_NSString keyPath = self.keyPath;

    if (keyPath.length > 0)
    {
        result = [AKAProperty unboundPropertyWithKeyPath:(req_NSString)keyPath];
    }

    return result;
}

- (opt_AKAProperty)bindingSourcePropertyInContext:(req_AKABindingContext)bindingContext
                                    changeObserer:(opt_AKAPropertyChangeObserver)changeObserver
{
    AKAProperty* result;

    // Use data context property if no scope is defined
    result = [bindingContext dataContextPropertyForKeyPath:self.keyPath
                                        withChangeObserver:changeObserver];

    return result;
}

- (opt_id)bindingSourceValueInContext:(req_AKABindingContext)bindingContext
{
    opt_id result = nil;
    opt_NSString keyPath = self.keyPath;

    if (keyPath.length > 0)
    {
        result = [bindingContext dataContextValueForKeyPath:(req_NSString)keyPath];
    }

    return result;
}

#pragma mark - Diagnostics

- (NSString*)constantStringValueOrDescription
{
    return [NSString stringWithFormat:@"(key path: %@)", self.keyPath];
}

#pragma mark - Serialization

- (NSString*)textForPrimaryExpression
{
    static NSString*const kScopeKeyPathSeparator = @".";

    NSString* result = self.keyPath;
    NSString* textForScope = self.textForScope;

    if (textForScope.length > 0)
    {
        result = result.length > 0 ? [NSString stringWithFormat:@"%@%@%@", textForScope, kScopeKeyPathSeparator, result] : textForScope;
    }

    return result;
}

- (NSString*)textForScope
{
    return nil;
}

@end


#pragma mark - AKADataContextKeyPathBindingExpression
#pragma mark -

@implementation AKADataContextKeyPathBindingExpression

#pragma mark - Binding Support

- (opt_AKAProperty)bindingSourcePropertyInContext:(req_AKABindingContext)bindingContext
                                    changeObserer:(opt_AKAPropertyChangeObserver)changeObserver
{
    return [bindingContext dataContextPropertyForKeyPath:self.keyPath
                                      withChangeObserver:changeObserver];
}

- (opt_id)bindingSourceValueInContext:(req_AKABindingContext)bindingContext
{
    opt_id result = nil;
    opt_NSString keyPath = self.keyPath;

    if (keyPath.length > 0)
    {
        result = [bindingContext dataContextValueForKeyPath:(req_NSString)keyPath];
    }

    return result;
}

#pragma mark - Diagnostics

- (NSString*)constantStringValueOrDescription
{
    return [NSString stringWithFormat:@"(key path: %@.%@)", self.textForScope, self.keyPath];
}

#pragma mark - Serialization

- (NSString*)textForScope
{
    return [NSString stringWithFormat:@"$%@", [NSScanner keywordData]];
}

@end


#pragma mark - AKARootDataContextKeyPathBindingExpression
#pragma mark -

@implementation AKARootDataContextKeyPathBindingExpression

#pragma mark - Binding Support

- (opt_AKAProperty)bindingSourcePropertyInContext:(req_AKABindingContext)bindingContext
                                    changeObserer:(opt_AKAPropertyChangeObserver)changeObserver
{
    return [bindingContext rootDataContextPropertyForKeyPath:self.keyPath
                                          withChangeObserver:changeObserver];
}

- (opt_id)bindingSourceValueInContext:(req_AKABindingContext)bindingContext
{
    opt_id result = nil;
    opt_NSString keyPath = self.keyPath;

    if (keyPath.length > 0)
    {
        result = [bindingContext rootDataContextValueForKeyPath:(req_NSString)keyPath];
    }

    return result;
}

#pragma mark - Diagnostics

- (NSString*)constantStringValueOrDescription
{
    return [NSString stringWithFormat:@"(key path: %@.%@)", self.textForScope, self.keyPath];
}

#pragma mark - Serialization

- (NSString*)textForScope
{
    return [NSString stringWithFormat:@"$%@", [NSScanner keywordRoot]];
}

@end


#pragma mark - AKAControlKeyPathBindingExpression
#pragma mark -

@implementation AKAControlKeyPathBindingExpression

#pragma mark - Binding Support

- (opt_AKAProperty)bindingSourcePropertyInContext:(req_AKABindingContext)bindingContext
                                    changeObserer:(opt_AKAPropertyChangeObserver)changeObserver
{
    opt_AKAProperty result = nil;
    opt_NSString keyPath = self.keyPath;

    if (keyPath.length > 0)
    {
        result = [bindingContext controlPropertyForKeyPath:(req_NSString)keyPath
                                        withChangeObserver:changeObserver];
    }

    return result;
}

- (opt_id)bindingSourceValueInContext:(req_AKABindingContext)bindingContext
{
    opt_id result = nil;
    opt_NSString keyPath = self.keyPath;

    if (keyPath.length > 0)
    {
        result = [bindingContext controlValueForKeyPath:(req_NSString)keyPath];
    }

    return result;
}

#pragma mark - Diagnostics

- (NSString*)constantStringValueOrDescription
{
    return [NSString stringWithFormat:@"(key path: %@.%@)", self.textForScope, self.keyPath];
}

#pragma mark - Serialization

- (NSString*)textForScope
{
    return [NSString stringWithFormat:@"$%@", [NSScanner keywordControl]];
}

@end
