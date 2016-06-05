//
//  AKATableViewCellFactoryPropertyBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 08.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import <objc/runtime.h>
#import "AKATableViewCellFactoryPropertyBinding.h"
#import "AKATableViewCellFactory.h"
#import "AKAPredicatePropertyBinding.h"

#import "AKABinding_Protected.h"
#import "AKABinding+SubclassInitialization.h"
#import "AKABinding+SubclassObservationEvents.h"
#import "AKABinding_BindingOwnerProperties.h"

#import "AKABindingErrors.h"
#import "AKABinding_Protected.h"


@interface AKATableViewCellFactoryPropertyBinding()

@property(nonatomic, strong)   id                                 previousSourceValue;

@property(nonatomic, strong) AKATableViewCellFactory*             targetFactory;

@end


@implementation AKATableViewCellFactoryPropertyBinding

#pragma mark - Specification

+ (AKABindingSpecification*)                         specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    [self registerEnumerationAndOptionTypes];

    dispatch_once(&onceToken, ^{

        NSDictionary* spec =
        @{ @"bindingType":                  [AKATableViewCellFactoryPropertyBinding class],
           @"expressionType":               @((AKABindingExpressionTypeNone         |
                                               AKABindingExpressionTypeString       |
                                               AKABindingExpressionTypeClass        |
                                               AKABindingExpressionTypeEnumConstant )),
           @"enumerationType":              @"UITableViewCellStyle",
           @"attributes": @{
                   @"cellIdentifier": @{
                           @"expressionType": @(AKABindingExpressionTypeStringConstant),
                           @"use": @(AKABindingAttributeUseBindToTargetProperty)
                           },
                   @"cellType": @{
                           @"expressionType": @(AKABindingExpressionTypeClassConstant),
                           @"use": @(AKABindingAttributeUseBindToTargetProperty)
                           },
                   @"cellStyle": @{
                           @"expressionType": @(AKABindingExpressionTypeEnumConstant),
                           @"enumerationType": @"UITableViewCellStyle",
                           @"use": @(AKABindingAttributeUseBindToTargetProperty)
                           }
                   }
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

+ (void)                         registerEnumerationAndOptionTypes
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* cellStylesByName =
        @{ @"Default": @(UITableViewCellStyleDefault),
           @"Value1": @(UITableViewCellStyleValue1),
           @"Value2": @(UITableViewCellStyleValue2),
           @"Subtitle": @(UITableViewCellStyleSubtitle)
           };
        [AKABindingExpressionSpecification registerEnumerationType:@"UITableViewCellStyle"
                                                  withValuesByName:cellStylesByName];
    });
}

#pragma mark - Initialization

- (instancetype)                                              init
{
    if (self = [super init])
    {
        _targetFactory = [[AKATableViewCellFactory alloc] init];
    }
    return self;
}

- (AKAProperty *)                defaultBindingSourceForExpression:(req_AKABindingExpression __unused)bindingExpression
                                                           context:(req_AKABindingContext __unused)bindingContext
                                                    changeObserver:(AKAPropertyChangeObserver __unused)changeObserver
                                                             error:(out_NSError __unused)error
{
    return [AKAProperty constantNilProperty];
}

#pragma mark - Conversion

- (BOOL)                                        convertSourceValue:(opt_id)sourceValue
                                                     toTargetValue:(out_id)targetValueStore
                                                             error:(out_NSError)error
{
    BOOL result = YES;
    NSError* localError = nil;

    if (sourceValue == [NSNull null])
    {
        sourceValue = nil;
    }

    AKATableViewCellFactory* targetValue = nil;

    if (sourceValue != self.previousSourceValue || (sourceValue == nil && self.targetFactory == nil))
    {
        BOOL hasTargetPropertyBindings = self.targetPropertyBindings.count > 0;
        self.syntheticTargetValue = nil;
        self.targetFactory = nil;

        if (sourceValue != nil)
        {
            if ([sourceValue isKindOfClass:[AKATableViewCellFactory class]])
            {
                if (hasTargetPropertyBindings)
                {
                    // Do not modify the source object (here via target bindings), create a copy instead
                    self.syntheticTargetValue = [sourceValue copy];
                    targetValue = self.syntheticTargetValue;
                }
                else
                {
                    targetValue = sourceValue;
                }
            }
            else if ([sourceValue isKindOfClass:[NSString class]])
            {
                self.syntheticTargetValue = [AKATableViewCellFactory new];
                targetValue = self.syntheticTargetValue;

                targetValue.cellIdentifier = sourceValue;
            }
            else if ([sourceValue isKindOfClass:[NSNumber class]])
            {
                self.syntheticTargetValue = [AKATableViewCellFactory new];
                targetValue = self.syntheticTargetValue;

                targetValue.cellStyle = ((NSNumber*)sourceValue).integerValue;
            }
            else if (class_isMetaClass(object_getClass(sourceValue)))
            {
                Class type = sourceValue;
                if ([type isSubclassOfClass:[UITableViewCell class]])
                {
                    self.syntheticTargetValue = [AKATableViewCellFactory new];
                    targetValue = self.syntheticTargetValue;

                    targetValue.cellType = sourceValue;
                }
                else
                {
                    result = NO;
                    localError = [AKABindingErrors invalidBinding:self
                                                      sourceValue:sourceValue
                                               expectedSubclassOf:[UITableViewCell class]];
                }
            }
            else
            {
                result = NO;
                id tp = [AKATypePattern typePatternWithObject:@[ [NSString class],
                                                                 [NSNumber class],
                                                                 [[UITableViewCell class] class], // Meta class
                                                                 [AKATableViewCellFactory class] ]
                                                     required:YES];
                localError = [AKABindingErrors invalidBinding:self
                                                  sourceValue:sourceValue
                                       expectedInstanceOfType:tp];
            }
        }
        else
        {
            self.syntheticTargetValue = [AKATableViewCellFactory new];
            targetValue = self.syntheticTargetValue;
        }
    }
    else
    {
        targetValue = self.targetFactory;
    }

    if (result)
    {
        if (targetValueStore)
        {
            *targetValueStore = targetValue;
        }
        self.previousSourceValue = sourceValue;
    }
    else
    {
        AKARegisterErrorInErrorStore(localError, error);
    }

    return result;
}

#pragma mark - Change Tracking

- (void)                             didStopObservingBindingSource
{
    [super didStopObservingBindingSource];

    self.previousSourceValue = nil;
    self.targetFactory = nil;
    self.syntheticTargetValue = nil;
}

@end

