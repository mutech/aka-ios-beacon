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
#import "AKAControlViewProtocol.h"

@implementation AKAControlViewBinding: NSObject

@synthesize view = _view;
@synthesize viewValueProperty = _viewValueProperty;
@synthesize control = _control;

#pragma mark - Initialization

+ (Class)resolveBindingType:(Class)preferredBindingType
{
    Class result = preferredBindingType;
    if (preferredBindingType == nil)
    {
        result = [AKAControlViewBinding class];
    }
    else if (![preferredBindingType isSubclassOfClass:[AKAControlViewBinding class]])
    {
        // TODO: error handling
    }
    return result;
}

+ (Class)resolveControlTypeForView:(id)view
{
    Class result = nil;
    if ([view isKindOfClass:[UIView class]])
    {
        UIView* uiView = view;
        if (uiView.subviews.count > 0)
        {
            result = [AKAControl class];
        }
    }
    return result;
}

+ (AKAControlViewBinding*)bindingOfType:(Class)preferredBindingType
                        withControlView:(UIView<AKAControlViewProtocol>*)view
                           controlOwner:(AKACompositeControl*)owner
{
    return [self bindingOfType:preferredBindingType
             withConfiguration:view
                          view:view
                  controlOwner:owner];
}

+ (AKAControlViewBinding*)bindingOfType:(Class)preferredBindingType
                      withConfiguration:(id<AKAControlViewBindingConfigurationProtocol>)configuration
                                   view:(UIView*)view
                           controlOwner:(AKACompositeControl*)owner
{
    AKAControlViewBinding* result = nil;

    Class bindingType = [self resolveBindingType:preferredBindingType];
    Class controlType = [bindingType resolveControlTypeForView:view];
    if (controlType)
    {
        AKAControl* control = [[controlType alloc] initWithOwner:owner
                                                         keyPath:configuration.valueKeyPath];
        if (control != nil)
        {
            result = [bindingType alloc];
            result = [result initWithControl:control
                                        view:view];
            [control setViewBinding:result];
        }
    }
    return result;
}

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

#pragma mark - Controlling the AKAControlView

#pragma mark Activation

- (BOOL)controlViewCanActivate
{
    return NO;
}

- (BOOL)shouldAutoActivate
{
    return self.controlViewCanActivate;
}

- (BOOL)participatesInKeyboardActivationSequence
{
    return NO;
}

- (void)setupKeyboardActivationSequenceWithPredecessor:(AKAControl*)previous
                                             successor:(AKAControl*)next
{
    // Default implementation does nothing
}

- (BOOL)activateControlView
{
    return NO;
}

- (BOOL)deactivateControlView
{
    return NO;
}

#pragma mark - AKAControlViewDelegate

#pragma mark View Value Changes

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

#pragma mark Activation

// TODO: controlView's are passed in order to support requests from multiple views. Check if this is needed

- (BOOL)controlViewShouldActivate:(UIView*)controlView
{
    (void)controlView; // not used
    return [self.control shouldActivate];
}

- (void)controlViewDidActivate:(UIView *)controlView
{
    (void)controlView; // not used
    [self.control didActivate];
}

- (BOOL)controlViewShouldDeactivate:(UIView*)controlView
{
    (void)controlView; // not used
    return [self.control shouldDeactivate];
}

- (void)controlViewDidDeactivate:(UIView *)controlView
{
    (void)controlView; // not used
    [self.control didDeactivate];
}

@end
