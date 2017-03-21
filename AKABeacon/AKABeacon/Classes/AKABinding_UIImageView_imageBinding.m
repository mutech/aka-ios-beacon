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

@property(nonatomic) NSString* adjustAspectRatioConstraint;
@property(nonatomic) NSLayoutConstraint* aspectRatioConstraint;
@property(nonatomic) NSLayoutConstraint* originalAspectRatioConstraint;

@property(nonatomic) NSNumber* maxWidth;
@property(nonatomic) NSNumber* maxHeight;

@end


@implementation AKABinding_UIImageView_imageBinding

#pragma mark - Specification

+ (AKABindingSpecification*)              specification
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
                                       @"adjustAspectRatioConstraint": @{
                                               @"bindingType":     [AKAPropertyBinding class],
                                               @"expressionType":  @(AKABindingExpressionTypeString),
                                               @"use":             @(AKABindingAttributeUseBindToBindingProperty)
                                               },
                                       @"maxHeight": @{
                                               @"bindingType":     [AKAPropertyBinding class],
                                               @"expressionType": @(AKABindingExpressionTypeAnyNumberConstant),
                                               @"use": @(AKABindingAttributeUseAssignValueToBindingProperty)
                                               },
                                       @"maxWidth": @{
                                               @"bindingType":     [AKAPropertyBinding class],
                                               @"expressionType": @(AKABindingExpressionTypeAnyNumberConstant),
                                               @"use": @(AKABindingAttributeUseAssignValueToBindingProperty)
                                               }
                                       }
                               };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    
    return result;
}

#pragma mark - Initialization

- (UIImage*)                             imageWithWidth:(CGFloat)width
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

+ (UIImage *)resizeImage:(UIImage*)image scale:(CGFloat)scale
{
    return [self resizeImage:image
                     newSize:CGSizeMake(image.size.width * scale,
                                        image.size.height * scale)];
}

+ (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);

    // Draw the scaled image in the current context
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];

    // Create a new image from current context
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();

    // Pop the current context from the stack
    UIGraphicsEndImageContext();

    // Return our new scaled image
    return scaledImage;
}

- (req_AKAProperty  )createTargetValuePropertyForTarget:(req_id)view
                                                  error:(out_NSError __unused)error
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
                    if (binding.maxWidth || binding.maxHeight)
                    {
                        CGFloat vscale = 1.0;
                        CGFloat hscale = 1.0;
                        if (binding.maxHeight && binding.maxHeight.floatValue < image.size.height)
                        {
                            vscale = binding.maxHeight.floatValue / image.size.height;
                        }
                        if (binding.maxWidth && binding.maxWidth.floatValue < image.size.width)
                        {
                            hscale = binding.maxWidth.floatValue / image.size.width;
                        }
                        CGFloat scale = MIN(vscale, hscale);
                        if (scale < 1.0)
                        {
                            image = [binding.class resizeImage:image scale:scale];
                        }
                    }
                }
                else if (value == nil || value == [NSNull null])
                {
                    image = [binding imageWithWidth:0 height:0 color:[UIColor clearColor]];
                }

                [binding transitionAnimation:^{
                    [binding adjustAspectRatioForImage:image];
                    binding.imageView.image = image;
                    [binding.imageView layoutIfNeeded];
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

- (void)adjustAspectRatioForImage:(UIImage*)image
{
    if (self.adjustAspectRatioConstraint.length > 0)
    {
        CGFloat ratio = 0.0;
        if (image.size.height != 0)
        {
            ratio = image.size.width / image.size.height;
        }

        if (self.aspectRatioConstraint == nil)
        {
            NSMutableArray* potentialConflicts = nil;
            for (NSLayoutConstraint* constraint in self.imageView.constraints)
            {
                if (constraint.identifier && [self.adjustAspectRatioConstraint isEqualToString:constraint.identifier])
                {
                    self.originalAspectRatioConstraint = constraint;
                    self.aspectRatioConstraint = constraint;
                }
                else if (constraint.firstItem == constraint.secondItem &&
                         constraint.firstAttribute != constraint.secondAttribute &&
                         (constraint.firstAttribute == NSLayoutAttributeWidth ||
                          constraint.firstAttribute == NSLayoutAttributeHeight) &&
                         (constraint.secondAttribute == NSLayoutAttributeWidth ||
                          constraint.secondAttribute == NSLayoutAttributeHeight))
                {
                    if (potentialConflicts == nil)
                    {
                        potentialConflicts = [NSMutableArray new];
                    }
                    [potentialConflicts addObject:constraint];
                }
            }
        }

        if (self.aspectRatioConstraint != nil)
        {
            self.aspectRatioConstraint.active = NO;
        }
        CGFloat constant = self.aspectRatioConstraint.constant;
        self.aspectRatioConstraint = [NSLayoutConstraint constraintWithItem:self.imageView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.imageView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:ratio
                                                                   constant:constant];
        CGRect bounds;
        bounds.origin = CGPointZero;
        bounds.size = image.size;
        self.imageView.bounds = bounds;
        [self.imageView addConstraint:self.aspectRatioConstraint];
        [self.imageView setNeedsLayout];
    }
}

- (void)                            transitionAnimation:(void (^)())animations
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

- (UIImageView *)                             imageView
{
    id result = self.target;

    NSAssert(result == nil || [result isKindOfClass:[UIImageView class]],
             @"View for %@ is required to be an instance of UIImageView", self.class);

    return result;
}

#pragma mark - Conversion

- (BOOL)                             convertSourceValue:(opt_id)sourceValue
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
