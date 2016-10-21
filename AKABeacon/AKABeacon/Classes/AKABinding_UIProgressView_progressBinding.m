//
//  AKABinding_UIProgressView_progressBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 21/10/2016.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding_UIProgressView_progressBinding.h"


@interface AKABinding_UIProgressView_progressBinding()

@property(nonatomic, readonly) UIProgressView* progressView;

@end

@implementation AKABinding_UIProgressView_progressBinding

#pragma mark - Specification

+ (AKABindingSpecification *)                specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":              [AKABinding_UIProgressView_progressBinding class],
           @"targetType":               [UIProgressView class],
           @"expressionType":           @(AKABindingExpressionTypeNumber),
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    return result;
}

#pragma mark - Initialization - Target Value Property

- (req_AKAProperty)     createTargetValuePropertyForTarget:(req_id)view
                                                     error:(out_NSError __unused)error
{
    NSParameterAssert(view == nil || [view isKindOfClass:[UIProgressView class]]);

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                AKABinding_UIProgressView_progressBinding* binding = target;
                return @(binding.progressView.progress);
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_UIProgressView_progressBinding* binding = target;
                if ([value isKindOfClass:[NSNumber class]])
                {
                    binding.progressView.progress = ((NSNumber*)value).floatValue;
                }
            }
                          observationStarter:
            ^BOOL (id target)
            {
                return YES;
            }
                          observationStopper:
            ^BOOL (id target)
            {
                return YES;
            }];
}

#pragma mark - Properties

- (UIProgressView *)                          progressView
{
    UIView* result = self.target;
    NSParameterAssert(result == nil || [result isKindOfClass:[UIProgressView class]]);

    return (UIProgressView*)result;
}

@end
