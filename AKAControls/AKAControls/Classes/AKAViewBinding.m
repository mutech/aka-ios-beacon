//
//  AKAControlViewAdapter.m
//  AKAControls
//
//  Created by Michael Utech on 06.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAViewBinding.h"
#import "AKAControlsErrors.h"
#import "UIView+AKABinding.h"

@implementation AKAViewBinding

@synthesize view = _view;
@synthesize configuration = _configuration;
@synthesize delegate = _delegate;
@synthesize viewValueProperty = _viewValueProperty;

- (instancetype)initWithView:(UIView *)view
               configuration:(AKAViewBindingConfiguration*)configuration
                    delegate:(id<AKAViewBindingDelegate>)delegate
{
    self = [self init];
    if (self)
    {
        _view = view;
        _configuration = configuration;
        _delegate = delegate;
        view.aka_binding = self;
    }
    return self;
}

#pragma mark - View Value

- (AKAProperty *)viewValueProperty
{
    if (_viewValueProperty == nil)
    {
        _viewValueProperty = [self createViewValueProperty];
    }
    return _viewValueProperty;
}

#pragma mark - Conversion

+ (id<AKAControlConverterProtocol>)defaultConverter
{
    return nil;
}

#pragma mark - Validation

- (void)    validationContext:(id)validationContext
                      forView:(UIView*)view
   changedValidationStateFrom:(NSError*)oldError
                           to:(NSError*)newError
{
    (void)oldError; // not needed
    if ([self managesValidationStateForContext:validationContext
                                          view:view])
    {
        [self setValidationState:newError
                         forView:view
               validationContext:validationContext];
        [self.view.superview layoutIfNeeded];
    }
}

- (BOOL)managesValidationStateForContext:(id)validationContext
                                    view:(UIView*)view
{
    return NO;
}

- (void)setValidationState:(NSError*)error
                   forView:(UIView*)view
         validationContext:(id)validationContext
{
}

#pragma mark - Activation

- (BOOL)supportsActivation
{
    return NO;
}

- (BOOL)activate
{
    return NO;
}

- (BOOL)deactivate
{
    return YES;
}

#pragma mark - Protected Interface - Abstract Methods

- (AKAProperty *)createViewValueProperty
{
    return nil;
    // TODO: no view value required for composite controls, other controls should probably have one:
    //AKAErrorAbstractMethodImplementationMissing();
}

#pragma mark - Protected Interface - Delegate Support Methods

- (void)viewValueDidChangeFrom:(id)oldValue to:(id)newValue
{
    if ([self.delegate respondsToSelector:@selector(viewBinding:view:valueDidChangeFrom:to:)])
    {
        [self.delegate viewBinding:self view:self.view valueDidChangeFrom:oldValue to:newValue];
    }
}

- (BOOL)shouldActivate
{
    BOOL result = YES;
    if ([self.delegate respondsToSelector:@selector(viewBindingShouldActivate:)])
    {
        result = [self.delegate viewBindingShouldActivate:self];
    }
    return result;
}

- (void)viewWillActivate
{
    if ([self.delegate respondsToSelector:@selector(viewBinding:viewWillActivate:)])
    {
        [self.delegate viewBinding:self viewWillActivate:self.view];
    }
}

- (void)viewDidActivate
{
    if ([self.delegate respondsToSelector:@selector(viewBinding:viewDidActivate:)])
    {
        [self.delegate viewBinding:self viewDidActivate:self.view];
    }
}

- (BOOL)shouldDeactivate
{
    BOOL result = YES;
    if ([self.delegate respondsToSelector:@selector(viewBindingShouldDeactivate:)])
    {
        result = [self.delegate viewBindingShouldDeactivate:self];
    }
    return result;
}

- (void)viewWillDeactivate
{
    if ([self.delegate respondsToSelector:@selector(viewBinding:viewWillDeactivate:)])
    {
        [self.delegate viewBinding:self viewWillDeactivate:self.view];
    }
}

- (void)viewDidDeactivate
{
    if ([self.delegate respondsToSelector:@selector(viewBinding:viewDidDeactivate:)])
    {
        [self.delegate viewBinding:self viewDidDeactivate:self.view];
    }
}

@end
