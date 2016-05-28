//
//  AKAFormViewController.m
//  AKABeacon
//
//  Created by Michael Utech on 12.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAFormViewController.h"
#import "AKABindingBehavior.h"

@implementation AKAFormViewController

// Please note that all functionality has been moved to AKABindingBehavior, this
// class will most likely be removed soon.

#pragma mark - View Life Cycle

- (void)                                       viewDidLoad
{
    [super viewDidLoad];

    [self setupScrollView];

    [AKABindingBehavior addToViewController:self];
}

// Experimental and not working well: Automatic injection of a top-level scroll view:
- (void) setupScrollView
{
#if 0
    if (self.scrollView == nil)
    {
        UIView* rootView = self.view;
        __block NSMutableArray* layoutSupportViews = [NSMutableArray new];
        __block NSMutableArray* subviews = [NSMutableArray new];
        [rootView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            (void)idx;
            (void)stop;
            if ([obj conformsToProtocol:@protocol(UILayoutSupport)])
            {
                [layoutSupportViews addObject:obj];
            }
            else
            {
                [subviews addObject:obj];
            }
        }];

        UIScrollView* scrollView = nil;
        if (subviews.count == 1)
        {
            if ([scrollView isKindOfClass:[UIScrollView class]])
            {
                scrollView = rootView.subviews.firstObject;
            }
            if (scrollView == nil)
            {
                scrollView = [[UIScrollView alloc] initWithFrame:rootView.bounds];
                scrollView.translatesAutoresizingMaskIntoConstraints = NO;
                scrollView.delaysContentTouches = YES;
                scrollView.canCancelContentTouches = YES;
                scrollView.userInteractionEnabled = YES;
                scrollView.multipleTouchEnabled = YES;
                scrollView.alwaysBounceHorizontal = NO;
                scrollView.alwaysBounceVertical = NO;

                UIView* contentView = subviews.firstObject;
                [contentView removeFromSuperview];
                [scrollView addSubview:contentView];
                [rootView addSubview:scrollView];


                NSArray* rootContraints =
                @[ [NSLayoutConstraint constraintWithItem:rootView
                                                attribute:NSLayoutAttributeTopMargin
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:scrollView
                                                attribute:NSLayoutAttributeTop
                                               multiplier:1
                                                 constant:0],
                   [NSLayoutConstraint constraintWithItem:scrollView
                                                attribute:NSLayoutAttributeBottom
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:rootView
                                                attribute:NSLayoutAttributeBottomMargin
                                               multiplier:1
                                                 constant:0],
                   [NSLayoutConstraint constraintWithItem:rootView
                                                attribute:NSLayoutAttributeLeading
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:scrollView
                                                attribute:NSLayoutAttributeLeading
                                               multiplier:1
                                                 constant:0],
                   [NSLayoutConstraint constraintWithItem:scrollView
                                                attribute:NSLayoutAttributeTrailing
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:rootView
                                                attribute:NSLayoutAttributeTrailing
                                               multiplier:1
                                                 constant:0],
                   [NSLayoutConstraint constraintWithItem:rootView
                                                attribute:NSLayoutAttributeWidth
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:contentView
                                                attribute:NSLayoutAttributeWidth
                                               multiplier:1.
                                                 constant:0.]];
                NSArray* scrollViewConstraints =
                @[ [NSLayoutConstraint constraintWithItem:scrollView
                                                attribute:NSLayoutAttributeTop
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:contentView
                                                attribute:NSLayoutAttributeTop
                                               multiplier:1
                                                 constant:0],
                   [NSLayoutConstraint constraintWithItem:contentView
                                                attribute:NSLayoutAttributeBottom
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:scrollView
                                                attribute:NSLayoutAttributeBottom
                                               multiplier:1
                                                 constant:0],
                   [NSLayoutConstraint constraintWithItem:scrollView
                                                attribute:NSLayoutAttributeLeading
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:contentView
                                                attribute:NSLayoutAttributeLeading
                                               multiplier:1
                                                 constant:0],
                   [NSLayoutConstraint constraintWithItem:contentView
                                                attribute:NSLayoutAttributeTrailing
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:scrollView
                                                attribute:NSLayoutAttributeTrailing
                                               multiplier:1
                                                 constant:0] ];
                [rootView addConstraints:rootContraints];
                [scrollView addConstraints:scrollViewConstraints];

                [rootView setNeedsLayout];
                [scrollView setNeedsLayout];
                [contentView setNeedsLayout];
                [rootView layoutIfNeeded];
            }
        }
        else if (subviews.count > 1)
        {
            NSLog(@"AKAFormViewController: will not automatically inject scroll view (more than one subview in view controllers top level content view). Scrolling in response to keyboard size changes will not be supported. If you need this feature, please add a scrollview and assign it to AKAFormViewController.scrollView outlet or wrap your views in a single UIView below the view controllers top level content view to enable auto injection of a scroll view");
        }

        self.scrollView = scrollView;
    }
#endif
}

@end