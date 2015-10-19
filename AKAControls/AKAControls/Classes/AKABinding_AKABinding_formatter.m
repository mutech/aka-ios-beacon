//
//  AKABinding_AKABinding_formatter.m
//  AKAControls
//
//  Created by Michael Utech on 06.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKAErrors;

#import "AKABinding_AKABinding_formatter.h"

#pragma mark - Initialization

@implementation AKABinding_AKABinding_formatter

- (instancetype)                        initWithProperty:(req_AKAProperty)bindingTarget
                                              expression:(req_AKABindingExpression)bindingExpression
                                                 context:(req_AKABindingContext)bindingContext
                                                delegate:(opt_AKABindingDelegate)delegate
{
    self = [super initWithProperty:bindingTarget
                        expression:bindingExpression
                           context:bindingContext
                          delegate:delegate];

    if (self)
    {
        _formatter = self.bindingSource.value;

        if (_formatter != nil && bindingExpression.attributes.count > 0)
        {
            _formatter = [_formatter copy];
        }

        if (_formatter == nil && bindingExpression.attributes.count > 0)
        {
            _formatter = [self createMutableFormatter];
        }

        [bindingExpression.attributes
         enumerateKeysAndObjectsUsingBlock:
         ^(NSString* _Nonnull key, AKABindingExpression* _Nonnull obj, BOOL* _Nonnull stop)
         {
             (void)stop;

             // TODO: make this more robust and add error handling/reporting
             id value = [obj bindingSourceValueInContext:bindingContext];

             id (^converter)(id) = self.configurationValueConvertersByPropertyName[key];

             if (converter)
             {
                 value = converter(value);
             }
             [self->_formatter setValue:value
                               forKey:key];
         }];

        // This implementation initializes the formatter once and does not observe changes in
        // neither direction.
        self.bindingTarget.value = self.formatter;
    }
    
    return self;
}


#pragma mark - Change Propagation

- (BOOL)           shouldUpdateSourceValueForTargetValue:(opt_id)oldTargetValue
                                                changeTo:(opt_id)newTargetValue
                                             validatedTo:(opt_id)targetValue
{
    (void)oldTargetValue;
    (void)newTargetValue;
    (void)targetValue;

    // We never want to override a possibly shared number formatter with whatever we have
    return NO;
}

- (BOOL)           shouldUpdateTargetValueForSourceValue:(opt_id)oldSourceValue
                                                changeTo:(opt_id)newSourceValue
                                             validatedTo:(opt_id)sourceValue
{
    (void)oldSourceValue;
    (void)newSourceValue;
    (void)sourceValue;
    // TODO: allow updating the target number formatter, later though
    return NO;
}

#pragma mark - Abstract Methods

- (NSFormatter*)createMutableFormatter
{
    AKAErrorAbstractMethodImplementationMissing();
}

- (NSDictionary<NSString *,id (^)(id)> *)configurationValueConvertersByPropertyName
{
    AKAErrorAbstractMethodImplementationMissing();
}

@end
