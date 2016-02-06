//
//  AKATableViewCellFactoryPropertyBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 08.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKATableViewCellFactoryPropertyBinding.h"
#import "AKATableViewCellFactory.h"
#import "AKAPredicatePropertyBinding.h"

@interface AKATableViewCellFactoryPropertyBinding()

@property(nonatomic, readonly) AKATableViewCellFactory* targetFactory;

@end


@implementation AKATableViewCellFactoryPropertyBinding

+ (AKABindingSpecification*)                         specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    // Make sure that enumeration types are initialized before the specification is used the
    // first time:
    [self registerEnumerationAndOptionTypes];

    dispatch_once(&onceToken, ^{

        NSDictionary* spec =
        @{ @"bindingType":                  self,
           @"expressionType":               @(AKABindingExpressionTypeNone),
           @"attributes": @{
                   @"predicate": @{
                           @"bindingType": [AKAPredicatePropertyBinding class],
                           @"use": @(AKABindingAttributeUseBindToTargetProperty)
                           },
                   @"cellIdentifier": @{
                           @"expressionType": @(AKABindingExpressionTypeStringConstant),
                           @"use": @(AKABindingAttributeUseAssignValueToTargetProperty)
                           },
                   @"cellType": @{
                           @"expressionType": @(AKABindingExpressionTypeClassConstant),
                           @"use": @(AKABindingAttributeUseAssignValueToTargetProperty)
                           },
                   @"cellStyle": @{
                           @"expressionType": @(AKABindingExpressionTypeEnumConstant),
                           @"enumerationType": @"UITableViewCellStyle",
                           @"use": @(AKABindingAttributeUseAssignValueToTargetProperty)
                           }
                   }
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

+ (void)registerEnumerationAndOptionTypes
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* cellStylesByName =
        @{ @"Default": @(UITableViewCellStyleDefault),
           @"Value1": @(UITableViewCellStyleValue1),
           @"Value2": @(UITableViewCellStyleValue2),
           @"Subtitle": @(UITableViewCellStyleSubtitle),
           };
        [AKABindingExpressionSpecification registerEnumerationType:@"UITableViewCellStyle"
                                                  withValuesByName:cellStylesByName];
    });
}

- (instancetype)init
{
    if (self = [super init])
    {
        _targetFactory = [[AKATableViewCellFactory alloc] init];
    }
    return self;
}

- (BOOL)initializeTargetPropertyValueAssignmentAttribute:(req_NSString)bindingProperty
                                       withSpecification:(req_AKABindingAttributeSpecification)specification
                                     attributeExpression:(req_AKABindingExpression)attributeExpression
                                          bindingContext:(req_AKABindingContext)bindingContext
                                                   error:(out_NSError)error
{
    (void)specification;
    (void)error;

    BOOL result = YES;

    id value = [attributeExpression bindingSourceValueInContext:bindingContext];
    [self.targetFactory setValue:value forKey:bindingProperty];

    return result;
}

- (AKAProperty *)defaultBindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                           context:(req_AKABindingContext)bindingContext
                                    changeObserver:(AKAPropertyChangeObserver)changeObserver
                                             error:(out_NSError)error
{
    (void)bindingExpression;
    (void)bindingContext;
    (void)error;

    AKAProperty* result = [AKAProperty propertyOfWeakKeyValueTarget:self
                                                            keyPath:@"targetFactory"
                                                     changeObserver:changeObserver];
    return result;
}

@end

