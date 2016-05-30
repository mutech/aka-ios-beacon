//
//  AKABinding_UIImageView_imageBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 06.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding_UIImageView_imageBinding.h"
#import "AKATransitionAnimationParametersPropertyBinding.h"
#import "AKABinding_Protected.h"
#import "AKABinding+SubclassInitialization.h"

@interface AKABinding_UIImageView_imageBinding()

@property(nonatomic) BOOL isObserving;
@property(nonatomic) AKATransitionAnimationParameters* transitionAnimation;
@property(nonatomic, readonly) BOOL isTransitionAnimationActive;

@end


@implementation AKABinding_UIImageView_imageBinding

+ (AKABindingSpecification*)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec = @{
                               @"bindingType":          [AKABinding_UIImageView_imageBinding class],
                               @"targetType":           [UIImageView class],
                               @"expressionType":       @((AKABindingExpressionTypeStringConstant|
                                                           AKABindingExpressionTypeAnyKeyPath)),
                               @"attributes": @{
                                       @"transitionAnimation": @{
                                               @"bindingType":     [AKATransitionAnimationParametersPropertyBinding class],
                                               @"use":             @(AKABindingAttributeUseBindToBindingProperty)
                                               },
                                       }
                               };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    
    return result;
}

#pragma mark - Initialization

- (void)validateTarget:(req_id)target
{
    NSParameterAssert([target isKindOfClass:[UIImageView class]]);
}

- (UIImage*)imageWithWidth:(CGFloat)width
                    height:(CGFloat)height
                     color:(UIColor*)color
{
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    [color setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (AKAProperty*)createBindingTargetPropertyForTarget:(req_id)view
{
    (void)view;

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                AKABinding_UIImageView_imageBinding* binding = target;

                return binding.imageView.image;
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_UIImageView_imageBinding* binding = target;
                UIImage* image;

                if ([value isKindOfClass:[UIImage class]])
                {
                    image = value;
                }
                else if (value == nil || value == [NSNull null])
                {
                    image = [binding imageWithWidth:0 height:0 color:[UIColor clearColor]];
                }

                [binding transitionAnimation:^{
                    binding.imageView.image = image;
                }];
            }
                          observationStarter:
            ^BOOL (id target)
            {
                AKABinding_UIImageView_imageBinding* binding = target;

                if (!binding.isObserving)
                {
                    binding.isObserving = YES;
                }

                return binding.isObserving;
            }
                          observationStopper:
            ^BOOL (id target)
            {
                AKABinding_UIImageView_imageBinding* binding = target;

                if (binding.isObserving)
                {
                    binding.isObserving = NO;
                }

                return !binding.isObserving;
            }];
}

- (void)transitionAnimation:(void (^)())animations
{
    if (self.transitionAnimation.duration > 0.0)
    {
        [UIView transitionWithView:self.imageView
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

- (UIImageView *)imageView
{
    UIView* result = self.view;

    NSAssert(result == nil || [result isKindOfClass:[UIImageView class]], @"View for %@ is required to be an instance of UIImageView", self.class);

    return (UIImageView*)result;
}

#pragma mark - Conversion

- (BOOL)convertSourceValue:(opt_id)sourceValue
             toTargetValue:(out_id)targetValueStore
                     error:(out_NSError)error
{
    BOOL result = NO;

    NSParameterAssert(targetValueStore != nil);

    if ([sourceValue isKindOfClass:[NSString class]])
    {
        UIImage* image = [UIImage imageNamed:(NSString*)sourceValue];
        self.syntheticTargetValue = image; // Keep a strong reference to the loaded image
        *targetValueStore = image;
        result = YES;
    }
    else
    {
        result = [super convertSourceValue:sourceValue toTargetValue:targetValueStore error:error];
    }

    return result;
}

@end
