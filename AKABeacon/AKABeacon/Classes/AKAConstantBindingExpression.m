//
//  AKAConstantBindingExpression.m
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABeaconErrors.h"
#import "AKAConstantBindingExpression.h"
#import "AKABindingExpression_Internal.h"


#pragma mark - AKAConstantBindingExpression
#pragma mark -

@implementation AKAConstantBindingExpression

#pragma mark - Initialization

- (instancetype)initWithConstant:(id)constant
                      attributes:(NSDictionary<NSString*, AKABindingExpression*>* __nullable)attributes
                   specification:(opt_AKABindingSpecification)specification
{
    if (self = [super initWithAttributes:attributes
                           specification:specification])
    {
        _constant = constant;
    }

    return self;
}

- (instancetype _Nullable)initWithPrimaryExpression:(opt_id)primaryExpression
                                         attributes:(opt_AKABindingExpressionAttributes)attributes
                                      specification:(opt_AKABindingSpecification)specification
{
    return [self initWithConstant:primaryExpression
                       attributes:attributes
                    specification:specification];
}

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeAbstract;
}

// Private: allow enumerations and options to lazily update constant after enumeration/constantType
// is set:
- (void)setConstant:(id _Nullable)constant
{
    _constant = constant;
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

- (NSString *)textForPrimaryExpressionWithNestingLevel:(NSUInteger __unused)level
                                                indent:(NSString *__unused)indent
{
    return self.textForConstant ? (req_NSString)self.textForConstant : @"";
}

@end


