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
           @"expressionType":       @(AKABindingExpressionTypeAnyKeyPath),
           @"attributes":           @{
                   @"headerTitle":          @{
                           @"use":                  @(AKABindingAttributeUseBindToTargetProperty),
                           @"expressionType":       @(AKABindingExpressionTypeStringConstant)
                           },
                   @"footerTitle":          @{
                           @"use":                  @(AKABindingAttributeUseBindToTargetProperty),
                           @"expressionType":       @(AKABindingExpressionTypeStringConstant)
                           },
                   @"cellMapping":          @{
                           @"use":                  @(AKABindingAttributeUseBindToTargetProperty),
                           @"bindingType":          [AKATableViewCellFactoryArrayPropertyBinding class]
                           }
                   }
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

- (BOOL)convertSourceValue:(id)sourceValue
             toTargetValue:(id _Nullable __autoreleasing*)targetValueStore
                     error:(NSError* __autoreleasing _Nullable*)error
{
    BOOL result = (sourceValue == nil
                   || [sourceValue isKindOfClass:[NSArray class]]
                   || [sourceValue isKindOfClass:[NSFetchedResultsController class]]);

    if (result)
    {
        if (!self.cachedTargetValue || self.cachedTargetValue.rowsSource != sourceValue)
        {
            self.cachedTargetValue = [AKATableViewSectionDataSourceInfo new];
            self.cachedTargetValue.rowsSource = sourceValue;
        }
        *targetValueStore = self.cachedTargetValue;
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

#pragma mark - Binding Delegate

@end


