//
//  AKABinding_UIActivityIndicatorView_animatesBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 14/10/2016.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding_UIActivityIndicatorView_animatesBinding.h"
#import "AKABeaconNullability.h"

#pragma mark - AKABinding_UIActivityIndicatorView_animatesBinding - Private Interface
#pragma mark -

@interface AKABinding_UIActivityIndicatorView_animatesBinding()

/**
 Convenience property accessing self.target as UIControl.
 */
@property(nonatomic, readonly) UIActivityIndicatorView* activityIndicatorView;

@end


#pragma mark - AKABinding_UIActivityIndicatorView_animatesBinding - Implementation
#pragma mark -

@implementation AKABinding_UIActivityIndicatorView_animatesBinding

+  (AKABindingSpecification *)             specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":              [AKABinding_UIActivityIndicatorView_animatesBinding class],
           @"targetType":               [UIActivityIndicatorView class],
           @"expressionType":           @(AKABindingExpressionTypeBoolean),
           @"attributes":
               @{ },
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    return result;
}

#pragma mark - Initialization

#pragma mark - Initialization - Target Value Property

- (req_AKAProperty)   createTargetValuePropertyForTarget:(req_id)view
                                                   error:(out_NSError __unused)error
{
    NSParameterAssert(view == nil || [view isKindOfClass:[UIActivityIndicatorView class]]);

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                AKABinding_UIActivityIndicatorView_animatesBinding* binding = target;
                return @(binding.activityIndicatorView.animating);
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_UIActivityIndicatorView_animatesBinding* binding = target;
                if ([value isKindOfClass:[NSNumber class]])
                {
                    BOOL boolValue = ((NSNumber*)value).boolValue;
                    if (boolValue)
                    {
                        [binding.activityIndicatorView startAnimating];
                    }
                    else
                    {
                        [binding.activityIndicatorView stopAnimating];
                    }
                }
            }];
}

#pragma mark - Properties

- (UIControl *)                    activityIndicatorView
{
    UIView* result = self.target;
    NSParameterAssert(result == nil || [result isKindOfClass:[UIActivityIndicatorView class]]);

    return (UIControl*)result;
}

@end
