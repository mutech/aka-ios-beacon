//
//  AKATableViewSectionDataSourceInfoPropertyBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 21.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKATableViewSectionDataSourceInfoPropertyBinding.h"
#import "AKATableViewCellFactoryArrayPropertyBinding.h"
#import "AKABindingErrors.h"
#import "AKABinding_Protected.h"
#import "AKABinding+SubclassInitialization.h"
#import "AKATableViewCellFactoryPropertyBinding.h"
#import "AKABindingExpressionEvaluator.h"

@interface AKATableViewSectionDataSourceInfoPropertyBinding()

@property(nonatomic) AKATableViewSectionDataSourceInfo* sectionDataSourceInfo;
@property(nonatomic) AKABindingExpressionEvaluator* cellMapping;

@end


#pragma mark - AKATableViewSectionDataSourceInfoPropertyBinding Implementation
#pragma mark -

@implementation AKATableViewSectionDataSourceInfoPropertyBinding

+ (AKABindingSpecification*)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":          [AKATableViewSectionDataSourceInfoPropertyBinding class],
           @"expressionType":       @(AKABindingExpressionTypeForwardToPrimaryAttribute), //AKABindingExpressionTypeAnyKeyPath),
           @"attributes":           @{
                   @"rows":                 @{
                       @"primary":              @YES,
                       @"bindingType":          [AKAArrayPropertyBinding class],
                       @"use":                  @(AKABindingAttributeUseBindToTargetProperty),
                       },
                   @"headerTitle":          @{
                       @"use":                  @(AKABindingAttributeUseBindToTargetProperty),
                       @"expressionType":       @(AKABindingExpressionTypeString)
                       },
                   @"footerTitle":          @{
                       @"use":                  @(AKABindingAttributeUseBindToTargetProperty),
                       @"expressionType":       @(AKABindingExpressionTypeString)
                       },
                   @"cellMapping":          @{
                       @"bindingType":          [AKATableViewCellFactoryPropertyBinding class],
                       @"use":                  @(AKABindingAttributeUseAssignEvaluatorToBindingProperty)
                       }
                   }
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

- (AKAProperty *)defaultBindingSourceForExpression:(req_AKABindingExpression __unused)bindingExpression
                                           context:(req_AKABindingContext __unused)bindingContext
                                    changeObserver:(AKAPropertyChangeObserver __unused)changeObserver
                                             error:(out_NSError __unused)error
{
    return [AKAProperty constantNilProperty];
}

- (BOOL)convertSourceValue:(id)sourceValue
             toTargetValue:(id _Nullable __autoreleasing*)targetValueStore
                     error:(NSError* __autoreleasing _Nullable*)error
{
    BOOL result = (sourceValue == nil
                   || [sourceValue isKindOfClass:[NSArray class]]);

    if (result)
    {
        if (self.sectionDataSourceInfo == nil)
        {
            self.sectionDataSourceInfo = [AKATableViewSectionDataSourceInfo new];
        }
        if (self.sectionDataSourceInfo.rows != sourceValue)
        {
            self.sectionDataSourceInfo.rows = sourceValue;
        }
        *targetValueStore = self.sectionDataSourceInfo;
    }
    else
    {
        if (error)
        {
            *error = [AKABindingErrors bindingErrorConversionOfBinding:self
                                                           sourceValue:sourceValue
                                    failedWithInvalidTypeExpectedTypes:@[ [NSArray class],
                                                                          [NSFetchedResultsController class] ]];
        }
    }

    return result;
}


- (AKATableViewSectionDataSourceInfo *)sectionDataSourceInfo
{
    NSAssert(self.syntheticTargetValue == nil ||
             [self.syntheticTargetValue isKindOfClass:[AKATableViewSectionDataSourceInfo class]],
             @"Unexpected type of syntethic target value %@, expected %@",
             self.syntheticTargetValue, NSStringFromClass((req_Class)[self.syntheticTargetValue class]));

    if (self.syntheticTargetValue == nil)
    {
        id targetValue = self.targetValueProperty.value;
        if (targetValue != nil && targetValue != [NSNull null])
        {
            self.sectionDataSourceInfo = targetValue;
        }
    }
    return self.syntheticTargetValue;
}

- (void)setSectionDataSourceInfo:(AKATableViewSectionDataSourceInfo *)sectionDataSourceInfo
{
    self.syntheticTargetValue = sectionDataSourceInfo;

    // Forward cellMapping to section info
    sectionDataSourceInfo.cellMapping = self.cellMapping;
}

+ (NSSet *)keyPathsForValuesAffectingSectionDataSourceInfo
{
    static NSSet* result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [NSSet setWithObject:@"syntheticTargetValue"];
    });
    return result;
}

- (void)setCellMapping:(AKABindingExpressionEvaluator *)cellMapping
{
    _cellMapping = cellMapping;

    // Forward cellMapping to section info
    if (self.syntheticTargetValue) // @see sectionDataSourceInfo
    {
        self.sectionDataSourceInfo.cellMapping = cellMapping;
    }
}

#pragma mark - Binding Delegate

@end


