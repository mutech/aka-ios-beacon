//
//  AKACustomKeyboardResponderView.m
//  AKAControls
//
//  Created by Michael Utech on 02.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKACustomKeyboardResponderView.h"

@implementation AKACustomKeyboardResponderView

#pragma mark - Actions

- (IBAction)becomeFirstResponderForSender:(id)sender
{
    if ([self shouldBecomeFirstResponder])
    {
        (void)[self becomeFirstResponder];
    }
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

- (UIView *)inputView
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

- (UIView *)inputAccessoryView
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

- (void)insertText:(NSString *)text
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

@end
