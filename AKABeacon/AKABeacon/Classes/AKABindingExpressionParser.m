//
//  NSScanner+AKABindingExpressionParser.m
//  AKABeacon
//
//  Created by Michael Utech on 19.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKAMutableOrderedDictionary;

#import "AKABindingExpressionParser.h"

#import "AKABindingExpression_Internal.h"
#import "AKAArrayBindingExpression.h"
#import "AKAConstantBindingExpression.h"
#import "AKAClassConstantBindingExpression.h"
#import "AKABooleanConstantBindingExpression.h"
#import "AKAEnumConstantBindingExpression.h"
#import "AKAOptionsConstantBindingExpression.h"
#import "AKAStringConstantBindingExpression.h"
#import "AKADoubleConstantBindingExpression.h"
#import "AKAColorConstantBindingExpression.h"
#import "AKAUIFontConstantBindingExpression.h"
#import "AKACGPointConstantBindingExpression.h"
#import "AKACGSizeConstantBindingExpression.h"
#import "AKACGRectConstantBindingExpression.h"
#import "AKAKeyPathBindingExpression.h"

@implementation AKABindingExpressionParser

#pragma mark - Initialization

+ (instancetype)parserWithString:(NSString*)string
{
    return [[AKABindingExpressionParser alloc] initWithString:string];
}

- (instancetype)initWithString:(NSString*)string
{
    if (self = [super init])
    {
        _scanner = [NSScanner scannerWithString:string];
    }

    return self;
}

#pragma mark - Configuration

static NSString*const   keywordTrue = @"true";
static NSString*const   keywordFalse = @"false";
static NSString*const   keywordEnum = @"enum";
static NSString*const   keywordOptions = @"options";
static NSString*const   keywordData = @"data";
static NSString*const   keywordRoot = @"root";
static NSString*const   keywordControl = @"control";
+ (NSString*)           keywordTrue       { return keywordTrue; }
+ (NSString*)           keywordFalse      { return keywordFalse; }
+ (NSString*)           keywordEnum       { return keywordEnum; }
+ (NSString*)           keywordOptions    { return keywordOptions; }
+ (NSString*)           keywordData       { return keywordData; }
+ (NSString*)           keywordRoot       { return keywordRoot; }
+ (NSString*)           keywordControl    { return keywordControl; }

static NSString*const   keywordColor = @"color";
static NSString*const   keywordUIColor = @"UIColor";
static NSString*const   keywordCGColor = @"CGColor";
+ (NSString*)           keywordColor      { return keywordColor; }
+ (NSString*)           keywordUIColor    { return keywordUIColor; }
+ (NSString*)           keywordCGColor    { return keywordCGColor; }

static NSString*const   keywordFont = @"font";
static NSString*const   keywordUIFont = @"UIFont";
+ (NSString*)           keywordFont       { return keywordFont; }
+ (NSString*)           keywordUIFont     { return keywordUIFont; }

static NSString*const   keywordPoint = @"point";
static NSString*const   keywordCGPoint = @"CGPoint";
static NSString*const   keywordSize = @"size";
static NSString*const   keywordCGSize = @"CGSize";
static NSString*const   keywordRect = @"rect";
static NSString*const   keywordCGRect = @"CGRect";
+ (NSString*)           keywordPoint      { return keywordPoint; }
+ (NSString*)           keywordCGPoint    { return keywordCGPoint; }
+ (NSString*)           keywordSize       { return keywordSize; }
+ (NSString*)           keywordCGSize     { return keywordCGSize; }
+ (NSString*)           keywordRect       { return keywordRect; }
+ (NSString*)           keywordCGRect     { return keywordCGRect; }

+ (NSDictionary<NSString*, NSDictionary<NSString*, Class>*>*)namedScopesAndConstants
{
    static NSDictionary* namedScopes;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        namedScopes =
            @{ keywordTrue:    @{ @"value": @(YES),
                                  @"type":  [AKABooleanConstantBindingExpression class] },
               keywordFalse:   @{ @"value": @(NO),
                                  @"type":  [AKABooleanConstantBindingExpression class] },

               keywordEnum:    @{ @"value": [NSNull null],
                                  @"type":  [AKAEnumConstantBindingExpression class] },
               keywordOptions: @{ @"value": [NSNull null],
                                  @"type":  [AKAOptionsConstantBindingExpression class] },

               keywordData:    @{ @"value": [NSNull null],
                                  @"type":  [AKADataContextKeyPathBindingExpression class] },
               keywordRoot:    @{ @"value": [NSNull null],
                                  @"type":  [AKARootDataContextKeyPathBindingExpression class] },
               keywordControl: @{ @"value": [NSNull null],
                                  @"type":  [AKAControlKeyPathBindingExpression class] },

               keywordColor:   @{ @"value": [NSNull null],
                                  @"type":  [AKAUIColorConstantBindingExpression class] },
               keywordUIColor: @{ @"value": [NSNull null],
                                  @"type":  [AKAUIColorConstantBindingExpression class] },
               keywordCGColor: @{ @"value": [NSNull null],
                                  @"type":  [AKACGColorConstantBindingExpression class] },

               keywordFont:    @{ @"value": [NSNull null],
                                  @"type":  [AKAUIFontConstantBindingExpression class] },
               keywordUIFont:  @{ @"value": [NSNull null],
                                  @"type":  [AKAUIFontConstantBindingExpression class] },

               keywordPoint:   @{ @"value": [NSNull null],
                                  @"type":  [AKACGPointConstantBindingExpression class] },
               keywordCGPoint: @{ @"value": [NSNull null],
                                  @"type":  [AKACGPointConstantBindingExpression class] },

               keywordSize:   @{ @"value": [NSNull null],
                                 @"type":  [AKACGSizeConstantBindingExpression class] },
               keywordCGSize: @{ @"value": [NSNull null],
                                 @"type":  [AKACGSizeConstantBindingExpression class] },

               keywordRect:    @{ @"value": [NSNull null],
                                  @"type":  [AKACGRectConstantBindingExpression class] },
               keywordCGRect:  @{ @"value": [NSNull null],
                                  @"type":  [AKACGRectConstantBindingExpression class] }, };
    });

    return namedScopes;
}

- (NSDictionary<NSString*, NSNumber*>*)keyPathOperators
{
    static NSDictionary* operators;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        // Used to recognize invalid operators and to decide if an operator requires
        // a subsequent key as in: "...@avg.salary" vs. "...@count"
        operators = @{ @"count": @NO,
                       @"avg": @YES,
                       @"min": @YES,
                       @"max": @YES,
                       @"sum": @YES,
                       @"distinctUnionOfObjects": @YES,
                       @"unionOfObjects": @YES,
                       @"distinctUnionOfArrays": @YES,
                       @"unionOfArrays": @YES,
                       @"distinctUnionOfSets": @YES,
                       @"unionOfSets": @YES };
    });

    return operators;
}

#pragma mark - Binding Expression Parser

- (BOOL)                     parseBindingExpression:(out_AKABindingExpression)store
                                  withSpecification:(opt_AKABindingSpecification)specification
                                              error:(out_NSError)error
{
    id primaryExpression = nil;
    NSDictionary* attributes = nil;
    Class bindingExpressionType = nil;

    [self skipWhitespaceAndNewlineCharacters];

    // Parse constant of scope
    BOOL result = [self parseConstantOrScope:&primaryExpression
                           withSpecification:specification
                                        type:&bindingExpressionType
                                       error:error];

    // Optionally, parse a key path following a scope.
    if (result)
    {

        // Order is relevant:
        BOOL requireKeyPath = [self skipCharacter:'.'];
        BOOL possiblyKeyPath = [self isAtValidFirstIdentifierCharacter] || [self isAtCharacter:'@'];

        if (requireKeyPath && !possiblyKeyPath)
        {
            result = NO;
            [self registerParseError:error
                            withCode:AKAParseErrorUnterminatedKeyPathAfterDot
                          atPosition:self.scanner.scanLocation
                              reason:@"Expected a key (path component) following trailing dot."];
        }
        else if (possiblyKeyPath)
        {
            if (bindingExpressionType != nil &&
                ![bindingExpressionType isSubclassOfClass:[AKAKeyPathBindingExpression class]] &&
                ![bindingExpressionType isSubclassOfClass:[AKAEnumConstantBindingExpression class]] &&
                ![bindingExpressionType isSubclassOfClass:[AKAOptionsConstantBindingExpression class]])
            {
                [self registerParseError:error
                                withCode:AKAParseErrorKeyPathNotSupportedForExpressionType
                              atPosition:self.scanner.scanLocation
                                  reason:[NSString stringWithFormat:@"Key path following expression type '%@' is not supported", [[NSStringFromClass(bindingExpressionType) stringByReplacingOccurrencesOfString:@"AKA" withString:@""] stringByReplacingOccurrencesOfString:@"BindingExpression" withString:@""]]];
            }
            else
            {
                result = [self parseKeyPath:&primaryExpression error:error];

                if (result && bindingExpressionType == nil)
                {
                    bindingExpressionType = [AKAKeyPathBindingExpression class];
                }
            }
        }
    }

    // Parse attributes
    if (result)
    {
        [self skipWhitespaceAndNewlineCharacters];

        if ([self isAtCharacter:'{'])
        {
            BOOL isOptions = [bindingExpressionType isSubclassOfClass:[AKAOptionsConstantBindingExpression class]];
            BOOL hasOptionsValues = NO;

            result = [self parseAttributes:&attributes
                         withSpecification:specification
                                 asOptions:isOptions
                          hasOptionsValues:&hasOptionsValues
                                     error:error];

            if (hasOptionsValues)
            {
                if (bindingExpressionType == nil)
                {
                    bindingExpressionType = [AKAOptionsConstantBindingExpression class];
                }
                else if (bindingExpressionType != [AKAOptionsConstantBindingExpression class])
                {
                    result = [self registerParseError:error
                                             withCode:AKAParseErrorUnexpectedOptionsValueForNonOptionsExpressionType
                                           atPosition:self.scanner.scanLocation
                                               reason:[NSString stringWithFormat:@"Options constant values are not allowed as attributes for expression type '%@'.", [[NSStringFromClass(bindingExpressionType) stringByReplacingOccurrencesOfString:@"AKA" withString:@""] stringByReplacingOccurrencesOfString:@"BindingExpression" withString:@""]]];
                }
            }
        }

        // Binding expression consisting of only attributes (no primary) will have the type AKABindingExpression
        if (result && bindingExpressionType == nil)
        {
            bindingExpressionType = [AKABindingExpression class];
        }
    }

    if (result && store != nil)
    {
        // TODO: add error parameter to binding expression constructor
        AKABindingExpression* bindingExpression = [bindingExpressionType alloc];
        bindingExpression = [bindingExpression initWithPrimaryExpression:primaryExpression
                                                              attributes:attributes
                                                           specification:specification];
        *store = bindingExpression;
    }

    return result;
}

- (BOOL)                       parseConstantOrScope:(out_id)constantStore
                                  withSpecification:(opt_AKABindingSpecification)specification
                                               type:(out_Class)typeStore
                                              error:(out_NSError)error
{
    BOOL result = YES;
    Class type = nil;
    id constant = nil;

    BOOL explicitScope = [self skipCharacter:'$'];

    if ([self isAtCharacter:'"'])
    {
        type = [AKAStringConstantBindingExpression class];
        result = [self parseStringConstant:&constant error:error];
    }
    else if ([self skipCharacter:'('])
    {
        if ([self isAtValidFirstNumberCharacter])
        {
            result = [self parseNumberConstant:&constant
                                          type:&type
                                         error:error];
        }

        if (result)
        {
            result = [self skipCharacter:')'];

            if (!result)
            {
                [self registerParseError:error
                                withCode:AKAParseErrorUnterminatedParenthizedExpression
                              atPosition:self.scanner.scanLocation
                                  reason:@"Unterminated parenthisized expression"];
            }
        }
    }
    else if ([self skipCharacter:'<'])
    {
        type = [AKAClassConstantBindingExpression class];
        NSString* className;
        result = [self parseIdentifier:&className error:error];

        if (result)
        {
            constant = NSClassFromString(className);

            if (constant == nil)
            {
                result = NO;
                [self registerParseError:error
                                withCode:AKAParseErrorUnknownClass
                              atPosition:self.scanner.scanLocation
                                  reason:[NSString stringWithFormat:@"There is no class loaded with the name %@", className]];
            }

            if (result)
            {
                result = [self skipCharacter:'>'];

                if (!result)
                {
                    [self registerParseError:error
                                    withCode:AKAParseErrorUnterminatedClassReference
                                  atPosition:self.scanner.scanLocation
                                      reason:@"Unterminated class reference, expected '>'"];
                }
            }
        }
    }
    else if ([self skipCharacter:'['])
    {
        type = [AKAArrayBindingExpression class];
        NSMutableArray* array = [NSMutableArray new];

        [self skipWhitespaceAndNewlineCharacters];
        BOOL done = (self.scanner.isAtEnd || [self skipCharacter:']']);
        for (NSUInteger i = 0; result && !done; ++i)
        {
            AKABindingExpression* item = nil;

            // TODO: get item specification from specification (add a property there)
            opt_Class itemBindingType = specification.bindingSourceSpecification.arrayItemBindingType;
            opt_AKABindingSpecification itemSpecification = [itemBindingType specification];
            result = [self parseBindingExpression:&item
                                withSpecification:itemSpecification
                                            error:error];

            if (result)
            {
                [array addObject:item];

                result = [self parseListSeparator:','
                                     orTerminator:']'
                                  terminatorFound:&done
                                            error:error];
            }
        }

        if (result && array.count > 0)
        {
            constant = [NSArray arrayWithArray:array];
        }
    }
    else if ([self isAtValidEnumerationStart]) // has to be tested before isAtValidFirstNumberCharacter!
    {
        result = [self parseEnumerationConstant:&constant
                                           type:&type
                                          error:error];
    }
    else if ([self isAtValidFirstNumberCharacter])
    {
        result = [self parseNumberConstant:&constant
                                      type:&type
                                     error:error];
    }
    else if (explicitScope && [self isAtValidFirstIdentifierCharacter])
    {
        NSUInteger savedScanLocation = self.scanner.scanLocation;
        NSString* identifier;
        result = [self parseIdentifier:&identifier error:error];

        if (result)
        {
            NSDictionary<NSString*, id>* namedScope = [AKABindingExpressionParser namedScopesAndConstants][identifier];

            if (namedScope != nil)
            {
                type = namedScope[@"type"];
                constant = namedScope[@"value"];

                if (constant == [NSNull null])
                {
                    constant = nil;
                }
            }
            else
            {
                result = [AKABindingExpressionSpecification isEnumerationTypeDefined:identifier];
                if (result)
                {
                    // Alternate enumeration syntax $EnumType.Value: Enumeration type will be re-parsed as key path
                    self.scanner.scanLocation = savedScanLocation;

                    if ([AKABindingExpressionSpecification isOptionsTypeDefined:identifier])
                    {
                        type = [AKAOptionsConstantBindingExpression class];
                    }
                    else
                    {
                        type = [AKAEnumConstantBindingExpression class];
                    }
                    constant = nil;
                }
                else
                {
                    [self registerParseError:error
                                    withCode:AKAParseErrorInvalidConstantOrScopeName
                                  atPosition:self.scanner.scanLocation
                                      reason:[NSString stringWithFormat:@"Invalid binding scope or named constant '$%@'", identifier]];
                }
            }
        }
    }

    if (result)
    {
        NSAssert(constant != nil ? type != nil : YES, @"Expected a defined binding expression type if a constant was found");

        if (typeStore != nil)
        {
            *typeStore = type;
        }

        if (constantStore != nil && ([type isSubclassOfClass:[AKAConstantBindingExpression class]] ||
                                     [type isSubclassOfClass:[AKAArrayBindingExpression class]]))
        {
            *constantStore = constant;
        }
    }

    return result;
}

- (BOOL)                               parseKeyPath:(out_NSString)store
                                              error:(out_NSError)error
{
    NSUInteger start = self.scanner.scanLocation;
    NSUInteger length = 0;

    BOOL expectKey = NO; // most @-operators (all but @count) require a subsequent key
    NSString* lastOperator = nil;

    BOOL done = self.scanner.isAtEnd;
    BOOL result = YES;

    while (result && !done)
    {
        // Record start of component for error reporting
        NSUInteger pathComponentStart = self.scanner.scanLocation;

        // Parse operator (@), key or extension path component:
        if ([self skipCharacter:'@'])
        {
            if (expectKey)
            {
                result = NO;
                [self registerParseError:error
                                withCode:AKAParseErrorKeyPathOperatorRequiresSubsequentKey
                              atPosition:self.scanner.scanLocation
                                  reason:[NSString stringWithFormat:@"Key path operator '@%@' requires a subsequent key, not another operator", lastOperator]];
            }
            else if ([self isAtValidFirstIdentifierCharacter])
            {
                result = [self parseIdentifier:&lastOperator error:error];

                if (result)
                {
                    NSNumber* needsKey = self.keyPathOperators[lastOperator];

                    if (needsKey != nil)
                    {
                        expectKey = needsKey.boolValue;
                    }
                    else
                    {
                        result = NO;
                        [self registerParseError:error
                                        withCode:AKAParseErrorInvalidKeyPathOperator
                                      atPosition:pathComponentStart
                                          reason:[NSString stringWithFormat:@"Invalid (unknown) key path operator '@%@'", lastOperator]];
                    }
                }
            }
            else
            {
                result = NO;
                [self registerParseError:error
                                withCode:AKAParseErrorKeyPathOperatorNameExpectedAfterAtSign
                              atPosition:self.scanner.scanLocation
                                  reason:@"Operator name expected after @"];
            }
        }
        else if ([self isAtValidFirstIdentifierCharacter])
        {
            if (expectKey)
            {
                expectKey = NO;
            }
            result = [self parseIdentifier:nil error:error];
        }
        else
        {
            [self registerParseError:error
                            withCode:AKAParseErrorInvalidKeyPathComponent
                          atPosition:pathComponentStart
                              reason:[NSString stringWithFormat:@"Invalid key path component starting with '%C'", [self.scanner.string characterAtIndex:pathComponentStart]]];
            result = NO;
        }

        if (result)
        {
            // Record end of last valid component
            length = self.scanner.scanLocation - start;

            // Done when there is no other path component separated by '.', skip separator
            done = ![self skipCharacter:'.'];
        }
    }

    if (result && expectKey)
    {
        result = NO;
        [self registerParseError:error
                        withCode:AKAParseErrorKeyPathOperatorRequiresSubsequentKey
                      atPosition:self.scanner.scanLocation
                          reason:[NSString stringWithFormat:@"Key path operator '@%@' requires a subsequent key, not another operator", lastOperator]];
    }

    if (result && store)
    {
        *store = [self.scanner.string substringWithRange:NSMakeRange(start, length)];
    }

    return result;
}

- (BOOL)                            parseAttributes:(out_NSDictionary)attributesStore
                                  withSpecification:(opt_AKABindingSpecification)specification
                                          asOptions:(BOOL)isOptions
                                   hasOptionsValues:(BOOL* _Nullable)hasOptionsValuesStore
                                              error:(out_NSError)error
{
    NSMutableDictionary* attributes = [AKAMutableOrderedDictionary new];
    BOOL result = [self skipCharacter:'{'];
    BOOL done = NO;
    BOOL hasOptionsValues = NO;

    while (result && !done)
    {
        NSString* identifier = nil;
        AKABindingExpression* attributeExpression = nil;

        [self skipWhitespaceAndNewlineCharacters];

        if (attributes.count == 0 && [self isAtCharacter:'}'])
        {
            // Allow for empty { }
            [self skipCharacter:'}'];
            done = YES;
            break;
        }

        BOOL isOptionValue = [self skipCharacter:'.'];
        hasOptionsValues = hasOptionsValues || isOptionValue;

        result = [self isAtValidFirstIdentifierCharacter];

        if (result)
        {
            result = [self parseIdentifier:&identifier
                                     error:error];
        }
        else
        {
            [self registerParseError:error
                            withCode:AKAParseErrorInvalidAttributeName
                          atPosition:self.scanner.scanLocation
                              reason:[NSString stringWithFormat:@"Invalid attribute name, expected a valid identifier, got '%C'", [self.scanner.string characterAtIndex:self.scanner.scanLocation ]]];
        }

        if (result)
        {
            [self skipWhitespaceAndNewlineCharacters];

            if ([self skipCharacter:':'])
            {
                if (isOptions || isOptionValue)
                {
                    [self registerParseError:error
                                    withCode:AKAParseErrorUnexpectedColonForEnumerationValue
                                  atPosition:self.scanner.scanLocation
                                      reason:@"Invalid attempt to specify an attribute value for an enumeration constant"];
                }
                else
                {
                    [self skipWhitespaceAndNewlineCharacters];

                    AKABindingAttributeSpecification* attributeSpecification =
                        specification.bindingSourceSpecification.attributes[identifier];
                    result = [self parseBindingExpression:&attributeExpression
                                        withSpecification:attributeSpecification
                                                    error:error];
                }
            }
            else
            {
                // "attributeName" is equivalent to "attributeName: $true"
                attributeExpression = [AKABooleanConstantBindingExpression constantTrue];
            }
        }

        if (result)
        {
            attributes[identifier] = attributeExpression;
            result = [self parseListSeparator:','
                                 orTerminator:'}'
                              terminatorFound:&done
                                        error:error];
            [self skipWhitespaceAndNewlineCharacters];
        }
    }

    if (result)
    {
        if (attributesStore != nil)
        {
            *attributesStore = attributes;
        }
        if (hasOptionsValuesStore != nil)
        {
            *hasOptionsValuesStore = hasOptionsValues;
        }
    }

    return result;
}

- (BOOL)                         parseListSeparator:(unichar)separator
                                       orTerminator:(unichar)terminator
                                    terminatorFound:(BOOL* _Nonnull)terminatorFound
                                              error:(out_NSError)error
{
    BOOL result = YES;

    [self skipWhitespaceAndNewlineCharacters];
    BOOL done = [self skipCharacter:terminator];

    if (!done)
    {
        [self skipWhitespaceAndNewlineCharacters];
        result = [self skipCharacter:separator];

        if (result)
        {
            // Allow for trailing ','
            [self skipWhitespaceAndNewlineCharacters];
            done = [self skipCharacter:terminator];
        }
        else
        {
            [self registerParseError:error
                            withCode:AKAParseErrorUnterminatedBindingExpressionList
                          atPosition:self.scanner.scanLocation
                              reason:[NSString stringWithFormat:@"Unterminated binding expression list, expected '%C' or '%C'", separator, terminator]];
        }
    }
    *terminatorFound = done;

    return result;
}

- (BOOL)                            parseIdentifier:(out_NSString)store
                                              error:(out_NSError)error
{
    BOOL result = [self isAtValidFirstIdentifierCharacter];

    if (result)
    {
        NSUInteger start = self.scanner.scanLocation++;
        while ([self isAtValidIdentifierCharacter])
        {
            ++self.scanner.scanLocation;
        }

        if (result && store)
        {
            *store = [self.scanner.string substringWithRange:NSMakeRange(start, self.scanner.scanLocation - start)];
        }
    }

    if (!result)
    {
        [self registerParseError:error
                        withCode:AKAParseErrorInvalidIdentifierCharacter
                      atPosition:self.scanner.scanLocation
                          reason:@"Invalid character, expected a valid identifier character"];
    }

    return result;
}

- (BOOL)                        parseStringConstant:(out_NSString)stringStorage
                                              error:(out_NSError)error
{
    BOOL done = NO;
    BOOL result = [self skipCharacter:'"'];

    if (result)
    {
        NSMutableString* string = [NSMutableString new];

        while (result && !done)
        {
            if (self.scanner.isAtEnd)
            {
                [self registerParseError:error
                                withCode:AKAParseErrorUnterminatedStringConstant
                              atPosition:self.scanner.scanLocation
                                  reason:@"Unterminated string constant"];
                done = YES;
                result = NO;
            }
            else if ([self skipCharacter:'"'])
            {
                done = YES;
            }
            else if ([self skipCharacter:'\\'])
            {
                unichar escapedCharacter;

                if ([self parseEscapedCharacter:&escapedCharacter error:error])
                {
                    [string appendFormat:@"%C", escapedCharacter];
                }
                else
                {
                    done = YES;
                    result = NO;
                }
            }
            else
            {
                unichar c = [self.scanner.string characterAtIndex:self.scanner.scanLocation];
                self.scanner.scanLocation += 1;

                [string appendFormat:@"%C", c];
            }
        }

        if (result && stringStorage)
        {
            *stringStorage = [NSString stringWithString:string];
        }
    }
    else if (error != nil)
    {
        [self registerParseError:error
                        withCode:AKAParseErrorInvalidStringDelimiter
                      atPosition:self.scanner.scanLocation
                          reason:[NSString stringWithFormat:@"Invalid character introducting expected string: %U, expected \".", [self.scanner.string characterAtIndex:self.scanner.scanLocation]]];
    }


    return result;
}

- (BOOL)                      parseEscapedCharacter:(out_unichar)unicharStorage
                                              error:(out_NSError)error
{
    BOOL result = YES;
    unichar unescaped = '\0';
    unichar c = [self.scanner.string characterAtIndex:self.scanner.scanLocation];

    switch (c)
    {
        case 'a':
            unescaped = 0x07;
            break;

        case 'b':
            unescaped = 0x08;
            break;

        case 'f':
            unescaped = 0x0C;
            break;

        case 'n':
            unescaped = 0x0A;
            break;

        case 'r':
            unescaped = 0x0D;
            break;

        case 't':
            unescaped = 0x09;
            break;

        case 'v':
            unescaped = 0x0B;
            break;

        case '\\':
            unescaped = 0x5C;
            break;

        case '\'':
            unescaped = 0x27;
            break;

        case '\"':
            unescaped = 0x22;
            break;

        case '?':
            unescaped = 0x3F;
            break;

        case '0':
        case 'x':
        case 'u':
        case 'U':
            [self registerParseError:error
                            withCode:AKAParseErrorUnsupportedCharacterEscapeSequence
                          atPosition:self.scanner.scanLocation
                              reason:[NSString stringWithFormat:@"Character escape sequence starting with '%c' is valid but not (yet) supported by this implementation", (char)c]];
            result = NO;
            break;
    }

    if (result && unicharStorage != nil)
    {
        *unicharStorage = unescaped;
    }

    return result;
}

- (BOOL)                        parseNumberConstant:(out_id)constantStore
                                               type:(out_Class)typeStore
                                              error:(out_NSError)error
{
    BOOL result = YES;
    Class type = nil;

    NSUInteger savedLocation = self.scanner.scanLocation;

    if ([self isAtValidFirstIntegerCharacter])
    {
        // Try to parse integer first
        long long longValue;
        type = [AKAIntegerConstantBindingExpression class];
        result = [self.scanner scanLongLong:&longValue];

        if (result && constantStore != nil)
        {
            *constantStore = @(longValue);
        }
        // TODO: decide whether to support smaller integer types and if so, down cast if possible
    }

    if (!result || [self isAtValidDoubleCharacter])
    {
        self.scanner.scanLocation = savedLocation;

        type = [AKADoubleConstantBindingExpression class];

        double doubleValue;
        result = [self.scanner scanDouble:&doubleValue];

        if (result && constantStore != nil)
        {
            *constantStore = @(doubleValue);
        }

        if (!result)
        {
            [self registerParseError:error
                            withCode:AKAParseErrorInvalidNumberConstant
                          atPosition:self.scanner.scanLocation
                              reason:@"Invalid number constant"];
        }
    }

    if (result && typeStore)
    {
        *typeStore = type;
    }

    return result;
}

- (BOOL)                   parseEnumerationConstant:(out_id)constantStore
                                               type:(out_Class)typeStore
                                              error:(out_NSError)error
{
    BOOL result = [self isAtCharacter:'.'];

    if (result)
    {
        // Enumeration value (.Value) is parsed as key path (as if it had the form $enum.Value where $enum would be consumed)
        // which in turn will be interpreted by AKAEnumConstantBindingExpression, so constantValue is initialized as nil
        
        if (constantStore)
        {
            *constantStore = nil;
        }
        if (typeStore)
        {
            *typeStore = [AKAEnumConstantBindingExpression class];
        }
    }
    else
    {
        [self registerParseError:error
                        withCode:AKAParseErrorInvalidNumberConstant
                      atPosition:self.scanner.scanLocation
                          reason:@"Invalid enumeration constant"];
    }
    
    return result;
}

#pragma mark - Error Handling

- (NSString*)                        contextMessage
{
    return [self contextMessageWithMaxLeading:16
                                  maxTrailing:10];
}

- (NSString*)          contextMessageWithMaxLeading:(NSUInteger)maxLeading
                                        maxTrailing:(NSUInteger)maxTrailing
{
    NSString* result = nil;

    NSString* leadingContextElipsis = @"";
    NSString* leadingContext = @"";

    if (self.scanner.scanLocation > 0)
    {
        // Number of characters to the left of current location;
        NSUInteger leadingContextLength = self.scanner.scanLocation;

        if (leadingContextLength > maxLeading)
        {
            leadingContextLength = maxLeading;
            leadingContextElipsis = @"…";
        }

        NSRange range = NSMakeRange(self.scanner.scanLocation - leadingContextLength,
                                    leadingContextLength);

        leadingContext = [self.scanner.string substringWithRange:range];
    }

    NSString* trailingContextElipsis = @"";
    NSString* trailingContext = @"";

    if (self.scanner.string.length >= self.scanner.scanLocation + 1)
    {
        NSUInteger trailingContextLength = self.scanner.string.length - (self.scanner.scanLocation + 1);

        if (trailingContextLength > maxTrailing)
        {
            trailingContextLength = maxTrailing;
            trailingContextElipsis = @"…";
        }

        NSRange range = NSMakeRange(self.scanner.scanLocation + 1, trailingContextLength);

        trailingContext = [self.scanner.string substringWithRange:range];
    }

    if (self.scanner.scanLocation < self.scanner.string.length)
    {
        result = [NSString stringWithFormat:@"“%@%@»%C«%@%@”",
                  leadingContextElipsis,
                  leadingContext,

                  [self.scanner.string characterAtIndex:self.scanner.scanLocation],

                  trailingContext,
                  trailingContextElipsis];
    }
    else
    {
        result = [NSString stringWithFormat:@"“%@%@»«%@%@”",
                  leadingContextElipsis,
                  leadingContext,

                  trailingContext,
                  trailingContextElipsis];
    }

    return result;
}

- (BOOL)                         registerParseError:(out_NSError)error
                                           withCode:(AKABindingExpressionParseErrorCode)errorCode
                                         atPosition:(NSUInteger)position
                                             reason:(NSString*)reason
{
    BOOL result = (error != nil);

    if (result)
    {
        NSString* context = @"";
        BOOL isOff = self.scanner.scanLocation > self.scanner.string.length;

        if (!isOff)
        {
            context = [self contextMessage];
        }
        NSString* description = [NSString stringWithFormat:@"%@\nPosition %lu%@%@", reason, (unsigned long)position, (context.length ? @": " : @""), context];
        *error = [NSError errorWithDomain:@"AKABindingExpressionParseError"
                                     code:errorCode
                                 userInfo:@{ NSLocalizedDescriptionKey: description,
                                             NSLocalizedFailureReasonErrorKey: reason }];
    }

    return result;
}

#pragma mark - Scanner Tools (Convenience)

- (BOOL)                              isAtCharacter:(unichar)character
{
    BOOL result = NO;

    if (!self.scanner.isAtEnd)
    {
        result = [self.scanner.string characterAtIndex:self.scanner.scanLocation] == character;
    }

    return result;
}

- (BOOL)    isAtValidKeyPathComponentFirstCharacter
{
    return [self isAtCharacter:'@'] || [self isAtValidFirstIdentifierCharacter];
}

- (BOOL)              isAtValidFirstNumberCharacter
{
    BOOL result = !self.scanner.isAtEnd;

    if (result)
    {
        unichar c = [self.scanner.string characterAtIndex:self.scanner.scanLocation];
        result = ((c >= '0' && c <= '9') || c == '-' || c == '+' || c == '.');
    }

    return result;
}

- (BOOL)                   isAtValidDoubleCharacter
{
    BOOL result = !self.scanner.isAtEnd;

    if (result)
    {
        unichar c = [self.scanner.string characterAtIndex:self.scanner.scanLocation];
        result = ((c >= '0' && c <= '9') || c == '-' || c == '+' || c == '.' || c == 'e' || c == 'E');
    }

    return result;
}

- (BOOL)            isAtValidEnumerationStart
{
    NSUInteger savedLocation = self.scanner.scanLocation;
    BOOL result = [self skipCharacter:'.'];

    if (result)
    {
        result = [self isAtValidFirstIdentifierCharacter];
    }

    self.scanner.scanLocation = savedLocation;

    return result;
}

- (BOOL)             isAtValidFirstIntegerCharacter
{
    BOOL result = !self.scanner.isAtEnd;

    if (result)
    {
        unichar c = [self.scanner.string characterAtIndex:self.scanner.scanLocation];
        result = ((c >= '0' && c <= '9') || c == '-');
    }

    return result;
}

- (BOOL)                  isAtValidIntegerCharacter
{
    BOOL result = !self.scanner.isAtEnd;

    if (result)
    {
        unichar c = [self.scanner.string characterAtIndex:self.scanner.scanLocation];
        result = (c >= '0' && c <= '9');
    }

    return result;
}

- (BOOL)          isAtValidFirstIdentifierCharacter
{
    BOOL result = !self.scanner.isAtEnd;

    if (result)
    {
        unichar c = [self.scanner.string characterAtIndex:self.scanner.scanLocation];
        result = ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z'));
    }

    return result;
}

- (BOOL)               isAtValidIdentifierCharacter
{
    BOOL result = !self.scanner.isAtEnd;

    if (result)
    {
        unichar c = [self.scanner.string characterAtIndex:self.scanner.scanLocation];
        result = ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
    }

    return result;
}

- (BOOL)                              skipCharacter:(unichar)character
{
    BOOL result = [self isAtCharacter:character];

    if (result)
    {
        [self skipCurrentCharacter];
    }

    return result;
}

- (BOOL)                       skipCurrentCharacter
{
    BOOL result = !self.scanner.isAtEnd;

    if (result)
    {
        self.scanner.scanLocation += 1;
    }

    return result;
}

- (BOOL)                    isAtWhitespaceCharacter
{
    BOOL result = !self.scanner.isAtEnd;

    if (result)
    {
        result = [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[self.scanner.string characterAtIndex:self.scanner.scanLocation]];
    }

    return result;
}

- (BOOL)                   skipWhitespaceCharacters
{
    BOOL result = NO;

    while ([self isAtWhitespaceCharacter])
    {
        result |= [self skipCurrentCharacter];
    }

    return result;
}

- (BOOL)           isAtWhitespaceOrNewlineCharacter
{
    BOOL result = !self.scanner.isAtEnd;

    if (result)
    {
        result = [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[self.scanner.string characterAtIndex:self.scanner.scanLocation]];
    }

    return result;
}

- (BOOL)    skipWhitespaceAndNewlineCharacters
{
    BOOL result = NO;

    while ([self isAtWhitespaceOrNewlineCharacter])
    {
        result |= [self skipCurrentCharacter];
    }

    return result;
}

@end