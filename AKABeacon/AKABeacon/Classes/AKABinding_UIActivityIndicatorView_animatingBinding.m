//
//  AKABinding_UIActivityIndicatorView_animatingBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 14/10/2016.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding_UIActivityIndicatorView_animatingBinding.h"
#import "AKABeaconNullability.h"
#import "AKATransitionAnimationParametersPropertyBinding.h"

#pragma mark - AKABinding_UIActivityIndicatorView_animatingBinding - Private Interface
#pragma mark -

@interface AKABinding_UIActivityIndicatorView_animatingBinding()

/**
 Convenience property accessing self.target as UIControl.
 */
@property(nonatomic, readonly) UIActivityIndicatorView* activityIndicatorView;

@property(nonatomic) AKATransitionAnimationParameters* transitionAnimation;
@property(nonatomic, readonly) BOOL isTransitionAnimationActive;

@end


#pragma mark - AKABinding_UIActivityIndicatorView_animatingBinding - Implementation
#pragma mark -

@implementation AKABinding_UIActivityIndicatorView_animatingBinding

+  (AKABindingSpecification *)             specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":              [AKABinding_UIActivityIndicatorView_animatingBinding class],
           @"targetType":               [UIActivityIndicatorView class],
           @"expressionType":           @(AKABindingExpressionTypeBoolean),
           @"attributes":
               @{ @"transitionAnimation": @{
                          @"bindingType":     [AKATransitionAnimationParametersPropertyBinding class],
                          @"use":             @(AKABindingAttributeUseBindToBindingProperty)
                          },
                  },
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
                AKABinding_UIActivityIndicatorView_animatingBinding* binding = target;
                return @(binding.activityIndicatorView.animating);
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_UIActivityIndicatorView_animatingBinding* binding = target;
                if ([value isKindOfClass:[NSNumber class]])
                {
                    [binding performAnimated:^{
                        BOOL boolValue = ((NSNumber*)value).boolValue;
                        if (boolValue)
                        {
                            [binding.activityIndicatorView startAnimating];
                        }
                        else
                        {
                            [binding.activityIndicatorView stopAnimating];
                        }
                    }];
                }
            }];
}

- (void)performAnimated:(void (^)())animations
{
    if (self.transitionAnimation.duration > 0.0)
    {
        [UIView transitionWithView:self.activityIndicatorView
                          duration:self.transitionAnimation.duration
                           options:self.transitionAnimation.options
                        animations:^{
                            self->_isTransitionAnimationActive = YES;

                            if (animations != NULL)
                            {
                                animations();
                            }
                        }
                        completion:^(BOOL finished) {
                            // We ignore finished, since we can't know when the animation
                            // is really finished if it is not yet when the handler is
                            // called. (What's this completion for if it's not for the
                            // completion of the animation??)
                            (void)finished;
                            self->_isTransitionAnimationActive = NO;
                        }];
    }
    else
    {
        if (animations != NULL)
        {
            animations();
        }
    }
}

#pragma mark - Properties

- (UIControl *)                    activityIndicatorView
{
    UIView* result = self.target;
    NSParameterAssert(result == nil || [result isKindOfClass:[UIActivityIndicatorView class]]);

    return (UIControl*)result;
}

@end
