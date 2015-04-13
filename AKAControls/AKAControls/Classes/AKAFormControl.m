//
//  AKAFormControl.m
//  AKAControls
//
//  Created by Michael Utech on 10.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAFormControl.h"
#import "AKAKeyboardActivationSequence.h"
#import <AKACommons/AKALog.h>

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
    }
    return result;
}

- (void)enumerateItemsInKeyboardActivationSequenceUsingBlock:(void (^)(id, NSUInteger, BOOL *))block
{
    __block int count = 0;
    [self enumerateLeafControlsUsingBlock:^(AKAControl *control,
                                            AKACompositeControl *owner,
                                            NSUInteger index,
                                            BOOL *stop)
     {
         if ([control participatesInKeyboardActivationSequence])
         {
             // Cannot use index, since not all controls neccessarily participate in keyboard
             // sequence.
             block(control, count++, stop);
         }
     }
                               startIndex:0
                          continueInOwner:NO];
}

- (UIResponder *)responderForKeyboardActivationSequence:(AKAKeyboardActivationSequence*)keyboardActivationSequence
                                                   item:(id)item
{
    UIResponder* result = nil;
    if (item != nil)
    {
        if ([item isKindOfClass:[AKAControl class]])
        {
            AKAControl* control = item;
            result = control.view;
        }
        else if ([item isKindOfClass:[UIResponder class]])
        {
            AKALogWarn(@"%@: Invalid request to resolve responder for keyboard activation sequence %@ item %@ which is not an instance of AKAControl. The specified item is a responder, recovering by returning the item", self, keyboardActivationSequence, item);
            result = item;
        }
    }
    return result;
}

- (BOOL)        activateResponder:(UIResponder*)responder
                          forItem:(id)item
                          atIndex:(NSUInteger)index
     inKeyboardActivationSequence:(AKAKeyboardActivationSequence*)keyboardActivationSequence
{
    BOOL result = NO;
    if ([item isKindOfClass:[AKAControl class]])
    {
        // TODO: maybe test for shouldActivate:
        result = [((AKAControl*)item) activate];
    }
    else
    {
        AKALogError(@"Invalid request to activate keyboard activation sequence %@ item %@ which is not an instance of AKAControl", keyboardActivationSequence, item);
    }
    return result;
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
        if ([control participatesInKeyboardActivationSequence])
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
