//
//  AKAKeyPathBindingExpression.m
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAKeyPathBindingExpression.h"
#import "AKABindingExpression_Internal.h"
#import "AKABindingExpressionParser.h"


#pragma mark - AKAKeyPathBindingExpression
#pragma mark -

@implementation AKAKeyPathBindingExpression

#pragma mark - Initialization

- (instancetype)initWithKeyPath:(NSString*)keyPath
                     attributes:(NSDictionary<NSString*, AKABindingExpression*>* __nullable)attributes
                  specification:(opt_AKABindingSpecification)specification
{
    if (self = [super initWithAttributes:attributes specification:specification])
    {
        _keyPath = keyPath;
    }

    return self;
}

- (instancetype _Nullable)initWithPrimaryExpression:(opt_id)primaryExpression
                                         attributes:(opt_AKABindingExpressionAttributes)attributes
                                      specification:(opt_AKABindingSpecification)specification
{
    return [self initWithKeyPath:primaryExpression
                      attributes:attributes
                   specification:specification];
}

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeUnqualifiedKeyPath;
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

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeDataContextKeyPath;
}

#pragma mark - Diagnostics

- (NSString*)constantStringValueOrDescription
{
    return [NSString stringWithFormat:@"(key path: %@.%@)", self.textForScope, self.keyPath];
}

#pragma mark - Serialization

- (NSString*)textForScope
{
    return [NSString stringWithFormat:@"$%@", [AKABindingExpressionParser keywordData]];
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

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeRootDataContextKeyPath;
}

#pragma mark - Diagnostics

- (NSString*)constantStringValueOrDescription
{
    return [NSString stringWithFormat:@"(key path: %@.%@)", self.textForScope, self.keyPath];
}

#pragma mark - Serialization

- (NSString*)textForScope
{
    return [NSString stringWithFormat:@"$%@", [AKABindingExpressionParser keywordRoot]];
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

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeControlKeyPath;
}

#pragma mark - Diagnostics

- (NSString*)constantStringValueOrDescription
{
    return [NSString stringWithFormat:@"(key path: %@.%@)", self.textForScope, self.keyPath];
}

#pragma mark - Serialization

- (NSString*)textForScope
{
    return [NSString stringWithFormat:@"$%@", [AKABindingExpressionParser keywordControl]];
}

@end

