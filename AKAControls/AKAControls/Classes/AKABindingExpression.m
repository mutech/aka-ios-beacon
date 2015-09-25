//
//  AKABindingExpression.m
//  AKAControls
//
//  Created by Michael Utech on 18.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABindingExpression_Internal.h"
#import "NSScanner+AKABindingExpressionParser.h"

@import AKACommons.NSMutableString_AKATools;
@import AKACommons.AKALog;
@import AKACommons.AKAErrors;

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
#if DEBUG
        if (result.bindingProvider != nil)
        {
            if (![result.bindingProvider validateBindingExpression:result error:error])
            {
                NSString* message = error ? (*error).description : @"(nothing)";
                AKALogError(@"Failed to validate binding expression %@, binding provider reported: %@", result, message);
                result = nil;
            }
        }
#else
        // Binding expressions are typically defined in story boards and should be tested
        // during development. The overhead of detailed validation for the sake of a better
        // error reporting is most probably not justified. So we skip it in non-DEBUG builds.

#endif
    }

    if (!parser.isAtEnd)
    {
        result = NO;
        [parser registerParseError:error
                          withCode:AKAParseErrorInvalidPrimaryExpressionExpectedAttributesOrEnd
                        atPosition:parser.scanLocation
                          reason:@"Invalid character, expected attributes (starting with '{') or end of binding expression"];
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
        @throw [NSException exceptionWithName:@"Attempt to use AKABindingExpression with a primary binding expression. This is invalid. Use a binding type that can handle the specific type of primary expression." reason:nil userInfo:@{}];
    }
    return self;
}

#pragma mark - Binding Support

- (opt_AKAProperty)bindingSourcePropertyInContext:(req_AKABindingContext)bindingContext
                                    changeObserer:(opt_AKAPropertyChangeObserver)changeObserver
{
    AKAErrorAbstractMethodImplementationMissing();
}

#pragma mark - Diagnostics

- (NSString *)description
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
    return nil;
}

- (NSString*)textForPrimaryExpression
{
    return [self textForPrimaryExpressionWithNestingLevel:0 indent:@""];
}

- (NSString*)textWithNestingLevel:(NSUInteger)level
                           indent:(NSString*)indent
{
    static NSString* const kPrimaryAttributesSeparator = @" ";

    static NSString* const kAttributesOpen = @"{";
    static NSString* const kAttributesClose = @"}";
    static NSString* const kAttributeNameValueSeparator = @": ";
    static NSString* const kAttributeSeparator = @",";


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

        __block NSUInteger i=0;
        NSUInteger count = self.attributes.count;

        [self.attributes enumerateKeysAndObjectsUsingBlock:
         ^(NSString * _Nonnull key, AKABindingExpression * _Nonnull obj, BOOL * _Nonnull stop)
         {
             NSString* attributeValueText = [obj textWithNestingLevel:level+1
                                                               indent:indent];

             [result appendString:attributePrefix];
             [result aka_appendString:indent repeat:level + 1];

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

- (instancetype)initWithArray:(NSArray<AKABindingExpression *> *)array
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


#pragma mark - Binding Support

- (opt_AKAProperty)bindingSourcePropertyInContext:(req_AKABindingContext)bindingContext
                                    changeObserer:(opt_AKAPropertyChangeObserver)changeObserver
{
    AKALogError(@"AKAArrayBindingExpression: bindingSourceProperty not yet implemented properly: We just provide a property to the array of binding expressions. Instead we need to provide a proxy that emulates an array of resolved values, where each binding expression element results in a property delivering an item of the proxy array.");
    return [AKAProperty propertyOfWeakKeyValueTarget:self.array
                                             keyPath:nil
                                      changeObserver:changeObserver];
}

#pragma mark - Serialization

- (NSString*)textForPrimaryExpressionWithNestingLevel:(NSUInteger)level
                                               indent:(NSString*)indent
{
    static NSString* const kArrayOpen = @"[";
    static NSString* const kArrayClose = @"]";
    static NSString* const kArrayItemSeparator = @",";

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
        [self.array enumerateObjectsUsingBlock:
         ^(AKABindingExpression * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
            NSString* itemText = [obj textWithNestingLevel:level+1
                                                    indent:indent];

            [result appendString:itemPrefix];
            [result aka_appendString:indent repeat:level + 1];

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
                      attributes:(NSDictionary<NSString*, AKABindingExpression*>*__nullable)attributes
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

#pragma mark - Binding Support

- (opt_AKAProperty)bindingSourcePropertyInContext:(req_AKABindingContext)bindingContext
                                    changeObserer:(opt_AKAPropertyChangeObserver)changeObserver
{
    return [AKAProperty propertyOfWeakKeyValueTarget:self.constant
                                               keyPath:nil
                                        changeObserver:changeObserver];
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

#pragma mark - Serialization

- (NSString *)textForConstant
{
    NSMutableString* result = nil;

    NSString* string = self.constant;
    if (string != nil)
    {
        result = [NSMutableString stringWithString:@"\""];
        for (NSUInteger i=0; i < string.length; ++i)
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
                 @((unichar)'\?'): @"\\?",
                 };
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

#pragma mark - Serialization

- (NSString *)textForConstant
{
    NSString* result = nil;
    if (self.constant != nil)
    {
        result = [NSString stringWithFormat:@"<%@>", NSStringFromClass(self.constant)];
    }
    return result;
}

@end

#pragma mark - AKANumberConstantBindingExpression
#pragma mark -

@implementation AKANumberConstantBindingExpression

@dynamic constant;

#pragma mark - Initialization

- (instancetype)initWithConstant:(NSNumber*)constant
                      attributes:(NSDictionary<NSString*, AKABindingExpression*>*__nullable)attributes
                        provider:(opt_AKABindingProvider)provider
{
    return [super initWithConstant:constant
                        attributes:attributes
                          provider:provider];
}

#pragma mark - Serialization

- (NSString *)textForConstant
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

#pragma mark - Serialization

- (NSString *)textForConstant
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

#pragma mark - Serialization

- (NSString *)textForConstant
{
    NSString* result = nil;
    if (self.constant)
    {
        result = [NSString stringWithFormat:@"%lld", self.constant.longLongValue];
    }
    return result;
}

@end


#pragma mark - AKADoubleConstantBindingExpression
#pragma mark -

@implementation AKADoubleConstantBindingExpression

#pragma mark - Serialization

- (NSString *)textForConstant
{
    NSString* result = nil;
    if (self.constant)
    {
        result = [NSString stringWithFormat:@"%g", self.constant.doubleValue];
    }
    return result;
}

@end


#pragma mark - AKAKeyPathBindingExpression
#pragma mark -

@implementation AKAKeyPathBindingExpression

#pragma mark - Initialization

- (instancetype)initWithKeyPath:(NSString*)keyPath
                     attributes:(NSDictionary<NSString*, AKABindingExpression*>*__nullable)attributes
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

- (opt_AKAProperty)bindingSourcePropertyInContext:(req_AKABindingContext)bindingContext
                                    changeObserer:(opt_AKAPropertyChangeObserver)changeObserver
{
    // Use data context property if no scope is defined
    return [bindingContext dataContextPropertyForKeyPath:self.keyPath
                                      withChangeObserver:changeObserver];
}

#pragma mark - Serialization

- (NSString*)textForPrimaryExpression
{
    static NSString* const kScopeKeyPathSeparator = @".";

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

#pragma mark - Serialization

- (NSString*)textForScope
{
    return [NSString stringWithFormat:@"$%@", [NSScanner keywordRoot]];;
}

@end


#pragma mark - AKAControlKeyPathBindingExpression
#pragma mark -

@implementation AKAControlKeyPathBindingExpression

#pragma mark - Binding Support

- (opt_AKAProperty)bindingSourcePropertyInContext:(req_AKABindingContext)bindingContext
                                    changeObserer:(opt_AKAPropertyChangeObserver)changeObserver
{
    return [bindingContext controlPropertyForKeyPath:self.keyPath
                                  withChangeObserver:changeObserver];
}

#pragma mark - Serialization

- (NSString*)textForScope
{
    return [NSString stringWithFormat:@"$%@", [NSScanner keywordControl]];
}

@end
