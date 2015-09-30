//
//  AKAFormControl.m
//  AKAControls
//
//  Created by Michael Utech on 10.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKALog;

#import "AKAFormControl.h"
#import "AKAKeyboardActivationSequence.h"
#import "AKABinding.h"

@interface AKAFormControl() <AKAKeyboardActivationSequenceDelegate> {
    __strong AKAKeyboardActivationSequence* _keyboardActivationSequence;
}
@end

@implementation AKAFormControl

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

    BOOL stop = NO;
    for (AKABinding* binding in self.bindings)
    {
        if ([binding conformsToProtocol:@protocol(AKAKeyboardActivationSequenceItemProtocol)])
        {
            AKAKeyboardActivationSequenceItem item = (AKAKeyboardActivationSequenceItem)binding;
            if ([item shouldParticipateInKeyboardActivationSequence])
            {
                block(item, count++, &stop);
            }
        }
        if (stop)
        {
            return;
        }
    }

    [self enumerateControlsRecursivelyUsingBlock:^(AKAControl *control,
                                                   AKACompositeControl *owner,
                                                   NSUInteger index,
                                                   BOOL *stop)
     {
         (void)owner; // not needed
         (void)index; // not needed
         if ([control participatesInKeyboardActivationSequence])
         {
             // Cannot use index, since not all controls neccessarily participate in keyboard
             // sequence.
             block(control, count++, stop);
         }
         for (AKABinding* binding in control.bindings)
         {
             if ([binding conformsToProtocol:@protocol(AKAKeyboardActivationSequenceItemProtocol)])
             {
                 AKAKeyboardActivationSequenceItem item = (AKAKeyboardActivationSequenceItem)binding;
                 if ([item shouldParticipateInKeyboardActivationSequence])
                 {
                     block(item, count++, stop);
                 }
             }
         }
     }
                                      startIndex:0
                                 continueInOwner:NO];
}

#pragma mark -

- (void)enumerateKeyboardActivationSequenceUsingBlock:(void(^)(AKAControl* control, AKACompositeControl* owner, NSUInteger index, BOOL* stop))block
{
    [self enumerateKeyboardActivationSequenceUsingBlock:block startIndex:0 continueInOwner:NO];
}

- (void)enumerateKeyboardActivationSequenceUsingBlock:(void(^)(AKAControl* control, AKACompositeControl* owner, NSUInteger index, BOOL* stop))block
                                           startIndex:(NSUInteger)startIndex
                                      continueInOwner:(BOOL)continueInOwner
{
    [self enumerateLeafControlsUsingBlock:^(AKAControl *control, AKACompositeControl *owner, NSUInteger index, BOOL *stop) {
        if ([control shouldParticipateInKeyboardActivationSequence])
        {
            block(control, owner, index, stop);
        }
    }
                               startIndex:startIndex
                          continueInOwner:continueInOwner];
}

#pragma mark - 

- (AKAControl*)nextControlInKeyboardActivationSequenceAfter:(AKAControl*)control
{
    __block AKAControl* result = nil;
    NSUInteger index = [self indexOfControl:control];
    [self enumerateKeyboardActivationSequenceUsingBlock:^(AKAControl *control, AKACompositeControl *owner, NSUInteger index, BOOL *stop)
     {
         result = control;
         *stop = YES;
     }
                                             startIndex:index+1
                                        continueInOwner:YES];
    return result;
}

@end
