//
//  AKAFormControl.m
//  AKAControls
//
//  Created by Michael Utech on 10.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKALog;

#import "AKAFormControl.h"
#import "AKAControl_Internal.h"

#import "AKAKeyboardActivationSequence.h"
#import "AKABinding.h"
#import "AKAKeyboardControl.h"

@interface AKAFormControl() <AKAKeyboardActivationSequenceDelegate> {
    __strong AKAKeyboardActivationSequence* _keyboardActivationSequence;
}
@end

@implementation AKAFormControl

#pragma mark - Initialization

- (instancetype)initWithDataContext:(req_id)dataContext
                      configuration:(AKAControlConfiguration*)configuration
                           delegate:(opt_AKAControlDelegate)delegate
{
    if (self = [super initWithDataContext:dataContext
                            configuration:configuration])
    {
        _delegate = delegate;
    }
    return self;
}

- (instancetype)initWithDataContext:(req_id)dataContext
                           delegate:(opt_AKAControlDelegate)delegate
{
    if (self = [self initWithDataContext:dataContext
                           configuration:nil
                                delegate:delegate])
    {
    }
    return self;
}

#pragma mark - Keyboard Activation Sequence

- (AKAKeyboardActivationSequence *)keyboardActivationSequence
{
    AKAKeyboardActivationSequence* result = _keyboardActivationSequence;
    if (!result)
    {
        result = [super keyboardActivationSequence];
    }
    if (!result && !self.owner)
    {
        _keyboardActivationSequence = [AKAKeyboardActivationSequence new];
        _keyboardActivationSequence.delegate = self;
        [_keyboardActivationSequence update];
        result = _keyboardActivationSequence;
    }
    return result;
}

- (void)enumerateItemsInKeyboardActivationSequenceUsingBlock:(void (^)(req_AKAKeyboardActivationSequenceItem, NSUInteger, outreq_BOOL))block
{
    __block int count = 0;

    [self enumerateControlsRecursivelyUsingBlock:^(AKAControl *control,
                                                   AKACompositeControl *owner,
                                                   NSUInteger index,
                                                   BOOL *stop)
     {
         (void)owner; // not needed
         (void)index; // not needed
         if ([control isKindOfClass:[AKAKeyboardControl class]])
         {
             AKAKeyboardControl* keyboardControl = (id)control;
             if ([keyboardControl.controlViewBinding shouldParticipateInKeyboardActivationSequence])
             {
                 block(keyboardControl.controlViewBinding, count++, stop);
             }
         }
     }
                                      startIndex:0
                                 continueInOwner:NO];
}

@end


@interface AKAFormControl(DelegatePropagation)
@end

@implementation AKAFormControl(DelegatePropagation)


#pragma mark Delegat'ish Methods for Notifications and Customization

- (BOOL)  shouldControl:(AKACompositeControl *)compositeControl
             addControl:(AKAControl *)memberControl
                atIndex:(NSUInteger)index
{
    BOOL result = YES;

    if (result)
    {
        id<AKAControlMembershipDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(shouldControl:addControl:atIndex:)])
        {
            result = [delegate shouldControl:compositeControl addControl:memberControl atIndex:index];
        }
    }

    if (result)
    {
        result = [super shouldControl:compositeControl addControl:memberControl atIndex:index];
    }

    return result;
}

- (void)        control:(AKACompositeControl *)compositeControl
         willAddControl:(AKAControl *)memberControl
                atIndex:(NSUInteger)index
{
    id<AKAControlMembershipDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(control:willAddControl:atIndex:)])
    {
        [delegate control:self willAddControl:memberControl atIndex:index];
    }
    [super control:self willAddControl:memberControl atIndex:index];
}

- (void)        control:(AKACompositeControl *)compositeControl
          didAddControl:(AKAControl *)memberControl
                atIndex:(NSUInteger)index
{
    id<AKAControlMembershipDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(control:didAddControl:atIndex:)])
    {
        [delegate control:self didAddControl:memberControl atIndex:index];
    }
    [super control:self didAddControl:memberControl atIndex:index];

    if ([memberControl isKindOfClass:[AKAKeyboardControl class]])
    {
        [self.keyboardActivationSequence update];
    }
}

- (BOOL)  shouldControl:(AKACompositeControl *)compositeControl
          removeControl:(AKAControl *)memberControl
                atIndex:(NSUInteger)index
{
    BOOL result = YES;

    if (result)
    {
        id<AKAControlMembershipDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(shouldControl:removeControl:atIndex:)])
        {
            result = [delegate shouldControl:compositeControl removeControl:memberControl atIndex:index];
        }
    }

    if (result)
    {
        result = [super shouldControl:compositeControl removeControl:memberControl atIndex:index];
    }

    return result;
}

- (void)        control:(AKACompositeControl *)compositeControl
      willRemoveControl:(AKAControl *)memberControl
              fromIndex:(NSUInteger)index
{
    id<AKAControlMembershipDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(control:willRemoveControl:fromIndex:)])
    {
        [delegate control:self willRemoveControl:memberControl fromIndex:index];
    }
    [super control:self willRemoveControl:memberControl fromIndex:index];

    if ([memberControl isKindOfClass:[AKAKeyboardControl class]])
    {
        [self.keyboardActivationSequence update];
    }
}

- (void)        control:(AKACompositeControl *)compositeControl
       didRemoveControl:(AKAControl *)memberControl
              fromIndex:(NSUInteger)index
{
    id<AKAControlMembershipDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(control:didRemoveControl:fromIndex:)])
    {
        [delegate control:self didRemoveControl:memberControl fromIndex:index];
    }
    [super control:self didRemoveControl:memberControl fromIndex:index];
}

@end


