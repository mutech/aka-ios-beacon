//
//  AKACustomKeyboardResponderView.m
//  AKAControls
//
//  Created by Michael Utech on 02.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit;
@import AKACommons.AKAErrors;

#import "AKACustomKeyboardResponderView.h"
#import "AKAControlConfiguration.h"
#import "AKAKeyboardControl.h"

@interface AKACustomKeyboardResponderView ()

@property(nonatomic, strong) IBOutlet UITapGestureRecognizer* currentTapToOpenGestureRecognizer;
@property(nonatomic) BOOL highlight;
@property(nonatomic, readonly) AKAMutableControlConfiguration* controlConfiguration;

@end

@implementation AKACustomKeyboardResponderView

#pragma mark - Actions

- (IBAction)becomeFirstResponderForSender:(id)sender
{
    (void)sender;

    if ([self shouldBecomeFirstResponder])
    {
        (void)[self becomeFirstResponder];
    }
}

#pragma mark - Tap To Open

- (BOOL)tapToOpen
{
    return self.currentTapToOpenGestureRecognizer != nil;
}

- (void)setTapToOpen:(BOOL)tapToOpen
{
    if (tapToOpen != self.tapToOpen)
    {
        if (tapToOpen)
        {
            self.currentTapToOpenGestureRecognizer = self.tapToOpenGestureRecognizer;

            if (!self.currentTapToOpenGestureRecognizer)
            {
                self.currentTapToOpenGestureRecognizer = [UITapGestureRecognizer new];
                [self.currentTapToOpenGestureRecognizer
                 addTarget:self
                    action:@selector(becomeFirstResponderForSender:)];
            }

            if (![self.gestureRecognizers containsObject:self.currentTapToOpenGestureRecognizer])
            {
                [self addGestureRecognizer:self.currentTapToOpenGestureRecognizer];
            }
        }
        else
        {
            [self removeGestureRecognizer:self.currentTapToOpenGestureRecognizer];

            if (self.currentTapToOpenGestureRecognizer != self.tapToOpenGestureRecognizer)
            {
                [self.currentTapToOpenGestureRecognizer
                 removeTarget:self
                       action:@selector(becomeFirstResponderForSender:)];
            }
            self.currentTapToOpenGestureRecognizer = nil;
        }
    }
}

- (void)setTapToOpenGestureRecognizer:(UITapGestureRecognizer*)tapToOpenGestureRecognizer
{
    BOOL activate = NO;

    if (tapToOpenGestureRecognizer != self.currentTapToOpenGestureRecognizer && self.tapToOpen)
    {
        [self removeGestureRecognizer:self.currentTapToOpenGestureRecognizer];

        if (self.currentTapToOpenGestureRecognizer != self.tapToOpenGestureRecognizer)
        {
            [self.currentTapToOpenGestureRecognizer
             removeTarget:self
                   action:@selector(becomeFirstResponderForSender:)];
        }
        self.currentTapToOpenGestureRecognizer = nil;
        activate = YES;
    }

    _tapToOpenGestureRecognizer = tapToOpenGestureRecognizer;
    self.tapToOpen = activate;
}

#pragma mark - Control Binding Configuration

@synthesize controlConfiguration = _controlConfiguration;
- (AKAMutableControlConfiguration*)controlConfiguration
{
    if (_controlConfiguration == nil)
    {
        _controlConfiguration = [AKAMutableControlConfiguration new];
        _controlConfiguration[kAKAControlTypeKey] = [AKAKeyboardControl class];
        [self setupControlConfiguration:_controlConfiguration];
    }
    return _controlConfiguration;
}

- (void)setupControlConfiguration:(AKAMutableControlConfiguration *)controlConfiguration
{
    (void)controlConfiguration;

    AKAErrorAbstractMethodImplementationMissing();
}

- (AKAControlConfiguration *)aka_controlConfiguration
{
    return self.controlConfiguration;
}

- (void)aka_setControlConfigurationValue:(id)value forKey:(NSString *)key
{
    self.controlConfiguration[key] = value;
}

#pragma mark - UIResponder redefinitions

- (BOOL)becomeFirstResponder
{
    BOOL result = [self shouldBecomeFirstResponder];

    if (result)
    {
        [self willBecomeFirstResponder];
        result = [super becomeFirstResponder];

        if (result)
        {
            [self didBecomeFirstResponder];
        }
    }

    return result;
}

- (BOOL)resignFirstResponder
{
    BOOL result = [self shouldResignFirstResponder];

    if (result)
    {
        [self willResignFirstResponder];
        result = [super resignFirstResponder];

        if (result)
        {
            [self didResignFirstResponder];
        }
    }

    return result;
}

- (UIView*)inputView
{
    UIView* result;

    if ([self.delegate respondsToSelector:@selector(inputViewForCustomKeyboardResponderView:)])
    {
        result = [self.delegate inputViewForCustomKeyboardResponderView:self];
    }
    else
    {
        result = [super inputView];
    }

    return result;
}

- (UIView*)inputAccessoryView
{
    UIView* result;

    if ([self.delegate respondsToSelector:@selector(inputAccessoryViewForCustomKeyboardResponderView:)])
    {
        result = [self.delegate inputAccessoryViewForCustomKeyboardResponderView:self];
    }
    else
    {
        result = [super inputAccessoryView];
    }

    return result;
}

#pragma mark - Key Input Protocol Implementation

- (BOOL)hasText
{
    BOOL result = YES;

    if ([self.delegate respondsToSelector:@selector(customKeyboardResponderViewHasText:)])
    {
        result = [self.delegate customKeyboardResponderViewHasText:self];
    }

    return result;
}

- (void)insertText:(NSString*)text
{
    if ([self.delegate respondsToSelector:@selector(customKeyboardResponderView:insertText:)])
    {
        [self.delegate customKeyboardResponderView:self insertText:text];
    }
}

- (void)deleteBackward
{
    if ([self.delegate respondsToSelector:@selector(customKeyboardResponderViewDeleteBackward:)])
    {
        [self.delegate customKeyboardResponderViewDeleteBackward:self];
    }
}

#pragma mark - Delegate Support

- (BOOL)canBecomeFirstResponder
{
    BOOL result = NO;

    if ([self.delegate respondsToSelector:@selector(customKeyboardResponderViewCanBecomeFirstResponder:)])
    {
        result = [self.delegate customKeyboardResponderViewCanBecomeFirstResponder:self];
    }

    return result;
}

- (BOOL)shouldBecomeFirstResponder
{
    BOOL result = NO;

    if ([self.delegate respondsToSelector:@selector(customKeyboardResponderViewShouldBecomeFirstResponder:)])
    {
        result = [self.delegate customKeyboardResponderViewShouldBecomeFirstResponder:self];
    }
    else
    {
        result = [self canBecomeFirstResponder];
    }

    return result;
}

- (void)willBecomeFirstResponder
{
    self.highlight = YES;

    if ([self.delegate respondsToSelector:@selector(customKeyboardResponderViewWillBecomeFirstResponder:)])
    {
        [self.delegate customKeyboardResponderViewWillBecomeFirstResponder:self];
    }
}

- (void)didBecomeFirstResponder
{
    if ([self.delegate respondsToSelector:@selector(customKeyboardResponderViewDidBecomeFirstResponder:)])
    {
        [self.delegate customKeyboardResponderViewDidBecomeFirstResponder:self];
    }
}

- (BOOL)shouldResignFirstResponder
{
    BOOL result = YES;

    if ([self.delegate respondsToSelector:@selector(customKeyboardResponderViewShouldResignFirstResponder:)])
    {
        result = [self.delegate customKeyboardResponderViewShouldResignFirstResponder:self];
    }

    return result;
}

- (void)willResignFirstResponder
{
    self.highlight = NO;

    if ([self.delegate respondsToSelector:@selector(customKeyboardResponderViewWillResignFirstResponder:)])
    {
        [self.delegate customKeyboardResponderViewWillResignFirstResponder:self];
    }
}

- (void)didResignFirstResponder
{
    if ([self.delegate respondsToSelector:@selector(customKeyboardResponderViewDidResignFirstResponder:)])
    {
        [self.delegate customKeyboardResponderViewDidResignFirstResponder:self];
    }
}

#pragma mark -

- (void)setHighlight:(BOOL)highight
{
    _highlight = highight;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)applyHighlight
{
    if (self.highlight)
    {
        CALayer* layer = self.layer;
        [layer setMasksToBounds:YES];
        //[layer setCornerRadius:5.0];

        [UIView animateWithDuration:.075
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:
         ^{
             //[layer setBorderWidth:2.0];
             //[layer setBorderColor:[self.tintColor CGColor]];
             [layer setBackgroundColor:[[self.tintColor
                                         colorWithAlphaComponent:.25] CGColor]];
             //CGFloat vf = 1.0 + (6.0 / self.frame.size.height);
             //CGFloat hf = 1.0 + (6.0 / self.frame.size.width);
             //CGAffineTransform transform = CGAffineTransformMakeScale(1.0 / hf,
             //                                                         1.0 / vf);
             //for (UIView* view in self.subviews)
             //{
             //    view.transform = transform;
             //}
         }
                         completion:
         ^(BOOL finished)
         {
             (void)finished;
             [UIView animateWithDuration:.3
                                   delay:0
                                 options:UIViewAnimationOptionCurveEaseOut
                              animations:
              ^{
                  //[layer setBorderWidth:1.5];
                  [layer setBackgroundColor:[[self.tintColor
                                              colorWithAlphaComponent:.16f] CGColor]];              }
                              completion:
              ^(BOOL innerFinished) {
                  (void)innerFinished;
              }
              ];
         }
         ];
    }
    else
    {
        CALayer* layer = self.layer;
        [layer setMasksToBounds:YES];
        [UIView animateWithDuration:.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:
         ^{
             //[layer setCornerRadius:0.0];
             //[layer setBorderWidth:0.0];
             //[layer setBorderColor:[[UIColor clearColor] CGColor]];
             [layer setBackgroundColor:[[UIColor clearColor] CGColor]];

             //for (UIView* view in self.subviews)
             //{
             //    view.transform = CGAffineTransformIdentity;
             //}
         } completion:^(BOOL finished) { (void)finished; }];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self applyHighlight];
}

@end
