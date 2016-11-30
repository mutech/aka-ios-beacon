//
//  AKABinding_UIProgressView_progressBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 21/10/2016.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding_UIProgressView_progressBinding.h"
#import "AKAPropertyBinding.h"

@interface AKABinding_UIProgressView_progressBinding()

@property(nonatomic, readonly) UIProgressView* progressView;
@property(nonatomic) NSNumber* workload;

@property(nonatomic) NSLayoutConstraint* workloadChangeAnimationConstraint;

@property(nonatomic) BOOL animatingWorkloadChange;
@property(nonatomic) NSNumber* pendingWorkloadUpdate;
@property(nonatomic) NSNumber* pendingProgressUpdate;

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
           @"attributes": @{
                   @"workload": @{
                           @"bindingType":      [AKAPropertyBinding class],
                           @"use":              @(AKABindingAttributeUseBindToBindingProperty),
                           @"expressionType":   @(AKABindingExpressionTypeNumber)
                           },
                   },
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
                    if (!binding.animatingWorkloadChange)
                    {
                        binding.progressView.progress = ((NSNumber*)value).floatValue;
                    }
                    else
                    {
                        binding.pendingProgressUpdate = value;
                    }
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

- (NSLayoutConstraint*)layoutConstraintForWorkflowAnimation
{
    NSLayoutConstraint* result = nil;

    for (NSLayoutConstraint* constraint in self.progressView.superview.constraints)
    {
        if (constraint.relation == NSLayoutRelationEqual && constraint.constant == 0.0 && constraint.priority >= 999)
        {
            if (constraint.multiplier == 1.0)
            {
                if ((constraint.firstItem == self.progressView &&
                     constraint.firstAttribute == NSLayoutAttributeTrailing)
                    ||
                    (constraint.secondItem == self.progressView &&
                     constraint.secondAttribute == NSLayoutAttributeTrailing))
                {
                    result = constraint;
                    break;
                }
            }
        }
    }
    return result;
}

- (void)setWorkload:(NSNumber*)workload
{
    if (self.animatingWorkloadChange)
    {
        self.pendingWorkloadUpdate = workload;
    }
    else
    {
        CGFloat currentWorkload = self.workload.floatValue;
        if (currentWorkload > 0.0 && workload.floatValue > currentWorkload)
        {
            if (!self.workloadChangeAnimationConstraint)
            {
                self.workloadChangeAnimationConstraint = [self layoutConstraintForWorkflowAnimation];
            }

            if (self.workloadChangeAnimationConstraint)
            {
                self.animatingWorkloadChange = YES;

                CGFloat workloadChange = currentWorkload / workload.floatValue;
                [self animateWorkloadChange:workloadChange completion:^{
                    NSNumber* pendingWorkloadUpdate = self.pendingWorkloadUpdate;
                    NSNumber* pendingProgressUpdate = self.pendingProgressUpdate;
                    self.pendingWorkloadUpdate = nil;
                    self.pendingProgressUpdate = nil;

                    self.animatingWorkloadChange = NO;
                    if (pendingProgressUpdate)
                    {
                        self.targetValueProperty.value = pendingProgressUpdate;
                    }
                    if (pendingWorkloadUpdate)
                    {
                        self.workload = pendingWorkloadUpdate;
                    }
                }];
            }
        }
        _workload = workload;
    }
}

- (void)animateWorkloadChange:(CGFloat)workloadChange
                   completion:(void(^)())completionBlock
{
    CGFloat animatedWidth = self.progressView.frame.size.width * workloadChange;
    CGFloat constant = self.progressView.frame.size.width - animatedWidth;
    if (self.workloadChangeAnimationConstraint.firstItem == self.progressView)
    {
        constant = -constant;
    }

    UIProgressView* background = [[UIProgressView alloc] initWithFrame:self.progressView.frame];
    background.alpha = 0.7;
    background.progress = 0.0;
    background.backgroundColor = [UIColor yellowColor];
    [self.progressView.superview insertSubview:background belowSubview:self.progressView];

    [UIView animateWithDuration:0.1
                          delay:0
                        options:0
                     animations:
     ^ {
         background.alpha = 1.0;
         self.workloadChangeAnimationConstraint.constant = constant;
         [self.progressView setNeedsLayout];
         [self.progressView layoutIfNeeded];
         [self.progressView.superview setNeedsLayout];
         [self.progressView.superview layoutIfNeeded];
     }
                     completion:
     ^(BOOL finished) {
         [UIView animateWithDuration:1.25
                               delay:0
                             options:0
                          animations:
          ^{
              background.alpha = 0;
              self.workloadChangeAnimationConstraint.constant = 0;
              [self.progressView setNeedsLayout];
              [self.progressView layoutIfNeeded];
              [self.progressView.superview setNeedsLayout];
              [self.progressView.superview layoutIfNeeded];
          }
                          completion:^(BOOL finished) {
                              [background removeFromSuperview];
                              if (completionBlock != NULL)
                              {
                                  completionBlock();
                              }
                          }];
     }];
}

@end
