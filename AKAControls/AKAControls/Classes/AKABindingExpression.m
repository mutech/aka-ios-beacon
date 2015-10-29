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
        if (!parser.isAtEnd)
        {
            result = nil;
            [parser registerParseError:error
                              withCode:AKAParseErrorInvalidPrimaryExpressionExpectedAttributesOrEnd
                            atPosition:parser.scanLocation
                                reason:@"Invalid character, expected attributes (starting with '{') or end of binding expression"];
        }
        // TODO: perform semantic validation (using bindingProvider.specification)
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
    // Implemented by subclasses if supported
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
             (void)stop;

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
    (void)bindingContext;
    opt_AKAProperty result = nil;
    opt_id target = self.array;
    if (target)
    {
        AKALogError(@"AKAArrayBindingExpression: bindingSourceProperty not yet implemented properly: We just provide a property to the array of binding expressions. Instead we need to provide a proxy that emulates an array of resolved values, where each binding expression element results in a property delivering an item of the proxy array.");
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
             (void)stop;
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
    (void)bindingContext;

    opt_id target = self.constant;
    opt_AKAProperty result = nil;

    if (target)
    {
        result =  [AKAProperty propertyOfWeakKeyValueTarget:(req_id)target
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
        if (integerValue < 0 ||  integerValue > 255)
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
                                                                           required:YES].floatValue / 255.0;
        CGFloat green = [AKAUIColorConstantBindingExpression colorComponentWithKeys:@[ @"g", @"green" ]
                                                                       fromAttributes:attributes
                                                                             required:YES].floatValue / 255.0;
        CGFloat blue = [AKAUIColorConstantBindingExpression colorComponentWithKeys:@[ @"b", @"blue" ]
                                                                      fromAttributes:attributes
                                                                            required:YES].floatValue / 255.0;
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

#pragma mark - Serialization

- (NSString*)keyword
{
    AKAErrorAbstractMethodImplementationMissing();
}

- (NSString*)textForConstant
{
    NSString* result = nil;
    if (self.constant)
    {
        UIColor* color = self.constant;
        CGFloat red;
        CGFloat green;
        CGFloat blue;
        CGFloat alpha;
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        result = [NSString stringWithFormat:@"$%@ { r:%f, g:%f, b:%f, a:%f }", [self keyword], red, green, blue, alpha];
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

- (instancetype)initWithConstant:(opt_id)constant
                      attributes:(opt_AKABindingExpressionAttributes)attributes
                        provider:(opt_AKABindingProvider)provider
{
    AKAErrorMethodNotImplemented();
}

#pragma mark - Serialization

- (NSString*)keyword
{
    return [NSScanner keywordUIFont];
}

- (NSString*)textForConstant
{
    AKAErrorMethodNotImplemented();
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
        result = [NSString stringWithFormat:@"$%@ { x:%f, y:%f }", [self keyword], value.x, value.y];
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
    return [NSScanner keywordCGRect];
}

- (NSString*)textForConstant
{
    NSString* result = nil;
    if (self.constant)
    {
        CGRect value = ((NSValue*)self.constant).CGRectValue;
        result = [NSString stringWithFormat:@"$%@ { x:%f, y:%f, w:%f, h:%f }", [self keyword], value.origin.x, value.origin.y, value.size.width, value.size.height];
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
    return [NSScanner keywordCGSize];
}

- (NSString*)textForConstant
{
    NSString* result = nil;
    if (self.constant)
    {
        CGSize value = ((NSValue*)self.constant).CGSizeValue;
        result = [NSString stringWithFormat:@"$%@ { w:%f, h:%f }", [self keyword], value.width, value.height];
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

- (opt_AKAUnboundProperty)bindingSourceUnboundPropertyInContext:(req_AKABindingContext)bindingContext
{
    (void)bindingContext; // Not used yet, this will most likely be needed for computations requiring the context in addition to a property target
    
    opt_AKAUnboundProperty result = nil;
    opt_NSString keyPath = self.keyPath;
    if (keyPath.length > 0)
    {
        result =  [AKAProperty unboundPropertyWithKeyPath:(req_NSString)keyPath];
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
