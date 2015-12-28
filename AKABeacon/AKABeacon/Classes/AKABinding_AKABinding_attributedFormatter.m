//
//  AKABinding_AKABinding_attributedFormatter.m
//  AKABeacon
//
//  Created by Michael Utech on 19.12.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding_AKABinding_attributedFormatter.h"
#import "AKANSEnumerations.h"
#import "AKAAttributedFormatter.h"

@implementation AKABinding_AKABinding_attributedFormatter

- (instancetype)initWithTarget:(id)target property:(SEL)property expression:(req_AKABindingExpression)bindingExpression context:(req_AKABindingContext)bindingContext delegate:(opt_AKABindingDelegate)delegate error:(NSError* __autoreleasing _Nullable*)error
{
    return self = [super initWithTarget:target property:property expression:bindingExpression context:bindingContext delegate:delegate error:error];
}

+ (AKABindingSpecification*)                 specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec = @{
            @"bindingType":         self,
            @"targetType":          [AKAProperty class],
            @"expressionType":      @(AKABindingExpressionTypeAnyKeyPath | AKABindingExpressionTypeNone),
            @"attributes": @{
                @"pattern": @{
                    @"required":        @YES,
                    @"use":             @(AKABindingAttributeUseBindToTargetProperty),
                    @"expressionType":  @(AKABindingExpressionTypeString)
                },

                @"patternOptions": @{
                    @"required":        @NO,
                    @"use":             @(AKABindingAttributeUseBindToTargetProperty),
                    @"expressionType":  @(AKABindingExpressionTypeOptionsConstant),
                    @"optionsType":     @"NSStringCompareOptions"
                },

                @"backgroundColor": @{
                    @"required":        @NO,
                    @"use": @(AKABindingAttributeUseBindToTargetProperty),
                    @"bindingProperty": [NSString stringWithFormat:@"attributes.%@", NSBackgroundColorAttributeName],
                    @"expressionType":  @(AKABindingExpressionTypeUIColor)
                },

                @"textColor": @{
                    @"required":        @NO,
                    @"use": @(AKABindingAttributeUseBindToTargetProperty),
                    @"bindingProperty": [NSString stringWithFormat:@"attributes.%@", NSForegroundColorAttributeName],
                    @"expressionType":  @(AKABindingExpressionTypeUIColor)
                },

                @"font": @{
                    @"required":        @NO,
                    @"use": @(AKABindingAttributeUseBindToTargetProperty),
                    @"bindingProperty": [NSString stringWithFormat:@"attributes.%@", NSFontAttributeName],
                    @"expressionType":  @(AKABindingExpressionTypeUIFontConstant)
                },
            },
            @"allowUnspecifiedAttributes":   @YES
        };

        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

+ (void)registerEnumerationAndOptionTypes
{
    [super registerEnumerationAndOptionTypes];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AKABindingExpressionSpecification registerOptionsType:@"NSStringCompareOptions"
                                              withValuesByName:[AKANSEnumerations stringCompareOptions]];
    });
}

- (BOOL)applyToTargetOnce:(out_NSError)error
{
    BOOL result = YES;

    [self updateTargetValue];
    for (AKABinding* attributeBinding in self.attributeBindings.allValues)
    {
        result = [attributeBinding applyToTargetOnce:error];

        if (!result)
        {
            break;
        }
    }

    return result;
}

- (BOOL)                              startObservingChanges
{
    __block BOOL result = YES;

    [self.attributeBindings enumerateKeysAndObjectsUsingBlock:
     ^(req_NSString propertyName,
       req_AKABinding propertyBinding,
       outreq_BOOL stop)
     {
         (void)propertyName;
         (void)stop;

         result = [propertyBinding startObservingChanges] && result;
     }];

    result = [self.bindingTarget startObservingChanges] && result;
    result = [self.bindingSource startObservingChanges] && result;

    [self updateTargetValue];
    
    return result;
}

- (NSFormatter*)defaultFormatter
{
    return [AKAAttributedFormatter new];
}

- (NSFormatter*)createMutableFormatter
{
    return [AKAAttributedFormatter new];
}

@end
