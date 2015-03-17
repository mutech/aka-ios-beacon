//
//  AKAControlViewBinding.m
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AKAControl_Internal.h"
#import "AKAControlViewBinding_Internal.h"

@implementation AKAControlViewBinding: NSObject

@synthesize view = _view;
@synthesize viewValueProperty = _viewValueProperty;
@synthesize control = _control;

#pragma mark - Initialization

- (instancetype)initWithControl:(AKAControl*)control
                           view:(UIView*)view
{
    self = [super init];
    if (self)
    {
        _control = control;
        _view = view;
    }
    return self;
}

#pragma mark - View Value Property

- (AKAProperty*)viewValueProperty
{
    if (_viewValueProperty == nil)
    {
        _viewValueProperty = [self createViewValueProperty];
    }
    return _viewValueProperty;
}

- (AKAProperty *)createViewValueProperty
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Class %@ failed to implement method %s", NSStringFromClass(self.class), __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

#pragma mark - Control

- (void)setControl:(AKAControl*)control
{
    AKAControl* currentControl = _control;
    if (currentControl != control)
    {
        if (currentControl != nil && control != nil)
        {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:[NSString stringWithFormat:@"%@'s control reference is already defined (%@).", self, self.control] userInfo:nil];
        }
        _control = control;
    }
}

#pragma mark - AKAControlViewDelegate

- (void)                controlView:(UIView*)controlView
          didChangeValueChangedFrom:(id)oldValue
                                 to:(id)newValue
{
    if (controlView == self.view)
    {
        AKAControl* control = self.control;
        [control viewValueDidChangeFrom:oldValue to:newValue];
    }
}

#pragma mark - Activation

- (BOOL)controlViewShouldActivate:(UIView*)controlView
{
    (void)controlView; // TODO: refactor this, controlView is useless.
    BOOL result = YES;
    return result;
}

- (void)controlViewDidActivate:(UIView *)controlView
{
    (void)controlView; // TODO: refactor this, controlView is useless.
}

- (BOOL)controlViewShouldDeactivate:(UIView*)controlView
{
    (void)controlView; // TODO: refactor this, controlView is useless.
    BOOL result = YES;
    return result;
}

- (void)controlViewDidDeactivate:(UIView *)controlView
{
    (void)controlView; // TODO: refactor this, controlView is useless.
}

- (BOOL)controlViewShouldActivateNextControl:(UIView*)controlView

{
    (void)controlView; // TODO: refactor this, controlView is useless.
    BOOL result = YES;
    return result;
}

- (void)controlViewRequestsActivateNextControl:(UIView*)controlView
{
    (void)controlView; // TODO: refactor this, controlView is useless.
}

@end
