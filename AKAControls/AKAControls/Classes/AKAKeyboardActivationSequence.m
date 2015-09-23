//
//  AKAKeyboardActivationSequence.m
//  AKAControls
//
//  Created by Michael Utech on 10.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AKACommons/AKALog.h>
#import <AKACommons/AKAReference.h>
#import "AKAKeyboardActivationSequence.h"
#import "AKAKeyboardActivationSequenceAccessoryView.h"

@interface AKAKeyboardActivationSequence()

@property(nonatomic, readonly)NSMutableArray* items;
@property(nonatomic)NSUInteger activeItemIndex;
@property(nonatomic, weak)UIResponder* activeResponder;
// Using a strong reference, since we are replacing a probably strong reference:
@property(nonatomic)UIView* savedActiveResponderInputAccessoryView;

@end

@implementation AKAKeyboardActivationSequence

@synthesize items = _items;
@synthesize inputAccessoryView = _inputAccessoryView;

- (instancetype)init
{
    if (self = [super init])
    {
        self.activeItemIndex = NSNotFound;
        self.activeResponder = nil;
    }
    return self;
}

- (instancetype)initWithDelegate:(id<AKAKeyboardActivationSequenceDelegate>)delegate
{
    if (self = [self init])
    {
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - Updating

- (NSMutableArray *)items
{
    if (_items == nil)
    {
        [self update];
    }
    return _items;
}

- (void)setNeedsUpdate
{
    _items = nil;
}

- (void)update
{
    _items = [NSMutableArray new];

    [self.delegate enumerateItemsInKeyboardActivationSequenceUsingBlock:^(id object, NSUInteger idx, BOOL *stop)
     {
         (void)stop; // not needed
         UIResponder* responder = [self.delegate responderForKeyboardActivationSequence:self
                                                                                   item:object];
         if (responder != nil)
         {
             [self.items addObject:[AKAWeakReference weakReferenceTo:object]];
             UIResponder* activeResponder = self.activeResponder;
             if (activeResponder != nil || self.activeItemIndex != NSNotFound)
             {
                 if (responder == activeResponder)
                 {
                     // Update possibly changed index of active responder
                     self->_activeItemIndex = idx;
                 }
                 else if (self.activeItemIndex == idx)
                 {
                     // Reset the index of active responder, which is different after the update
                     self->_activeItemIndex = NSNotFound;
                 }
             }

             if (responder.isFirstResponder)
             {
                 // This will take care or unregistering a currently active item
                 [self registerActiveResponder:responder forItem:object atIndex:idx];
             }
         }
     }];

    UIResponder* activeResponder = self.activeResponder;
    if (activeResponder != nil)
    {
        if (self.activeItemIndex == NSNotFound || !activeResponder.isFirstResponder)
        {
            // Responder no longer part of the activation sequence or stealthily deactivated
            [self unregisterActiveResponder];
        }
        else
        {

        }
    }
    [self updateInputAccessoryView];
}

#pragma mark - Access

- (id)activeItem
{
    return self.activeItemIndex == NSNotFound ? nil : [self itemAtIndex:self.activeItemIndex];
}

- (NSUInteger)indexOfItem:(id)item
{
    AKAWeakReference* reference = [AKAWeakReference weakReferenceTo:item];
    return [self.items indexOfObject:reference];
}

- (id)itemAtIndex:(NSUInteger)index
{
    AKAWeakReference* reference = [self.items objectAtIndex:index];
    return reference.value;
}

- (UIResponder*)responderAtIndex:(NSUInteger)index
{
    UIResponder* result = nil;
    id item = [self itemAtIndex:index];
    id<AKAKeyboardActivationSequenceDelegate> delegate = self.delegate;
    if (item != nil && delegate != nil)
    {
        result = [delegate responderForKeyboardActivationSequence:self
                                                                  item:item];
    }
    return result;
}

- (NSUInteger)nextItemIndex
{
    NSUInteger result = NSNotFound;
    if (self.activeItemIndex != NSNotFound && self.activeItemIndex + 1 < self.items.count)
    {
        result = self.activeItemIndex + 1;
    }
    return result;
}

- (id)nextItem
{
    id result = nil;
    NSUInteger index = [self nextItemIndex];
    if (index != NSNotFound)
    {
        result = [self itemAtIndex:index];
    }
    return result;
}

- (UIResponder*)nextResponder
{
    UIResponder* result = nil;
    NSUInteger index = [self nextItemIndex];
    if (index != NSNotFound)
    {
        result = [self responderAtIndex:index];
    }
    return result;
}

- (NSUInteger)previousItemIndex
{
    NSUInteger result = NSNotFound;
    if (self.activeItemIndex != NSNotFound && self.activeItemIndex >= 1)
    {
        result = self.activeItemIndex - 1;
    }
    return result;
}

- (UIResponder*)previousItem
{
    UIResponder* result = nil;
    NSUInteger index = [self previousItemIndex];
    if (index != NSNotFound)
    {
        result = [self responderAtIndex:index];
    }
    return result;
}
- (UIResponder*)previousResponder
{
    UIResponder* result = nil;
    NSUInteger index = [self previousItemIndex];
    if (index != NSNotFound)
    {
        result = [self responderAtIndex:index];
    }
    return result;
}

#pragma mark - Activation

- (BOOL)prepareToActivateItemAtIndex:(NSUInteger)index
{
    BOOL result = index < self.items.count;
    if (result)
    {
        UIResponder* responder = [self responderAtIndex:index];
        result = responder != nil;
        if (result)
        {
            result = [self registerActiveResponder:responder
                                    forItemAtIndex:index];
        }
    }
    return result;
}

- (BOOL)activateItemAtIndex:(NSUInteger)index
{
    BOOL result = index < self.items.count;
    if (result)
    {
        UIResponder* responder = [self responderAtIndex:index];
        result = responder != nil;
        if (result)
        {
            result = [self registerActiveResponder:responder
                                    forItemAtIndex:index];
            if (result && !responder.isFirstResponder)
            {
                id<AKAKeyboardActivationSequenceDelegate> delegate = self.delegate;
                if ([delegate respondsToSelector:@selector(activateResponder:forItem:atIndex:inKeyboardActivationSequence:)])
                {
                    result = [delegate activateResponder:responder
                                                      forItem:[self itemAtIndex:index]
                                                      atIndex:index
                                 inKeyboardActivationSequence:self];
                }
                else
                {
                    result = [responder becomeFirstResponder];
                }
            }
        }
    }
    return result;
}

- (BOOL)prepareToActivateItem:(id)item
{
    BOOL result = NO;
    NSUInteger index = [self indexOfItem:item];
    if (index != NSNotFound)
    {
        result = [self prepareToActivateItemAtIndex:index];
    }
    return result;
}

- (BOOL)activateItem:(id)item
{
    BOOL result = NO;
    NSUInteger index = [self indexOfItem:item];
    if (index != NSNotFound)
    {
        result = [self activateItemAtIndex:index];
    }
    return result;
}

- (BOOL)activatePrevious
{
    NSUInteger index = [self previousItemIndex];
    return [self activateItemAtIndex:index];
}

- (BOOL)activateNext
{
    NSUInteger index = [self nextItemIndex];
    return [self activateItemAtIndex:index];
}

- (BOOL)deactivate
{
    BOOL result = YES;
    UIResponder* responder = self.activeResponder;
    if (responder.isFirstResponder && [responder canResignFirstResponder])
    {
        result = [responder resignFirstResponder];
    }
    if (result)
    {
        [self unregisterActiveResponder];
    }
    return result;
}

- (void)unregisterActiveResponder
{
    if (self.activeResponder != nil)
    {
        [self restoreInputAccessoryViewForActiveResponder];
        self.activeResponder = nil;
    }
    self.activeItemIndex = NSNotFound;
}

- (BOOL)registerActiveResponder:(UIResponder*)responder
                        forItem:(id)item
                        atIndex:(NSUInteger)index
{
    (void)item; // not used
    return [self registerActiveResponder:responder forItemAtIndex:index];
}

- (BOOL)registerActiveResponder:(UIResponder*)responder
                 forItemAtIndex:(NSUInteger)index
{
    BOOL result = NO;
    if ((self.activeItemIndex != index && self.activeItemIndex != NSNotFound) ||
        (self.activeResponder != nil && self.activeResponder != responder))
    {
        [self unregisterActiveResponder];
    }

    BOOL isFirstResponder = [responder isFirstResponder];
    if (isFirstResponder || [responder canBecomeFirstResponder])
    {
        result = YES;
        self.activeResponder = responder;
        self.activeItemIndex = index;
        [self setInputAccessoryViewForActiveResponder];
    }
    return result;
}

#pragma mark - Input Accessory View

- (UIView*)inputAccessoryView
{
    if (!_inputAccessoryView)
    {
        _inputAccessoryView = [self createInputAccessoryView];
        if (_inputAccessoryView != nil && [self.delegate respondsToSelector:@selector(customizeInputAccessoryView:forKeyboardActivationSequence:)])
        {
            [self.delegate customizeInputAccessoryView:_inputAccessoryView
                         forKeyboardActivationSequence:self];
        }
    }
    return _inputAccessoryView;
}

- (UIView*)createInputAccessoryView
{
    UIView* result = nil;
    if ([self.delegate respondsToSelector:@selector(createInputAccessoryViewForKeyboardActivationSequence:activatePreviousAction:activateNextAction:closeKeyboardAction:)])
    {
        result =
        [self.delegate createInputAccessoryViewForKeyboardActivationSequence:self
                                                      activatePreviousAction:@selector(activatePrevious:)
                                                          activateNextAction:@selector(activateNext:)
                                                         closeKeyboardAction:@selector(closeKeyboard:)];
    }
    else
    {
        AKAKeyboardActivationSequenceAccessoryView* inputAccessoryView =
            [[AKAKeyboardActivationSequenceAccessoryView alloc] initWithFrame:CGRectZero];
        inputAccessoryView.keyboardActivationSequence = self;
        result = inputAccessoryView;
    }
    return result;
}

- (BOOL)setInputAccessoryViewForActiveResponder
{
    UIView* oldView = nil;
    BOOL result = [self setInputAccessoryView:self.inputAccessoryView
                                 forResponder:self.activeResponder
                                      oldView:&oldView];
    if (oldView != self.inputAccessoryView)
    {
        self.savedActiveResponderInputAccessoryView = oldView;
    }
    else
    {
        self.savedActiveResponderInputAccessoryView = nil;
    }

    [self updateInputAccessoryView];
    return result;
}

- (void)updateInputAccessoryView
{
    if (self.activeResponder != nil)
    {
        if ([self.delegate respondsToSelector:@selector(setupInputAccessoryView:forKeyboardActivationSequence:previousItem:activeItem:nextItem:)])
        {
            [self.delegate setupInputAccessoryView:self.inputAccessoryView
                     forKeyboardActivationSequence:self
                                      previousItem:[self previousItem]
                                        activeItem:[self activeItem]
                                          nextItem:[self nextItem]];
        }
        else if ([self.inputAccessoryView isKindOfClass:[AKAKeyboardActivationSequenceAccessoryView class]])
        {
            AKAKeyboardActivationSequenceAccessoryView* inputAccessoryView = (AKAKeyboardActivationSequenceAccessoryView*)self.inputAccessoryView;
            [inputAccessoryView updateBarItemStates];
        }
    }
}

- (BOOL)setInputAccessoryView:(UIView*)inputAccessoryView
                 forResponder:(UIResponder*)responder
                      oldView:(out UIView*__autoreleasing*)oldView

{
    BOOL result = NO;
    if ([responder respondsToSelector:@selector(setInputAccessoryView:)])
    {
        if (oldView)
        {
            *oldView = responder.inputAccessoryView;
        }
        [responder performSelector:@selector(setInputAccessoryView:)
                        withObject:self.inputAccessoryView];
        result = YES;
    }
    else if ([responder isKindOfClass:[UITextField class]])
    {
        UITextField* textField = (UITextField*)responder;
        textField.inputAccessoryView = inputAccessoryView;
    }
    return result;
}

- (BOOL)restoreInputAccessoryViewForActiveResponder
{
    UIResponder* responder = self.activeResponder;
    BOOL result = NO;
    UIView* inputAccessoryView = self.inputAccessoryView;
    if (responder.inputAccessoryView == self.inputAccessoryView)
    {
        result = [self setInputAccessoryView:self.inputAccessoryView
                                forResponder:responder
                                     oldView:nil];
    }
    else
    {
        AKALogWarn(@"Input accessory view in responder %@ is not the expected view %@, found %@ instead. If the responders input accessory view was not changed after activation, this indicates an internal inconsistency of the activation sequence %@ or an unexpected behavior of the responder",
                   responder, inputAccessoryView, responder.inputAccessoryView, self);
    }

    if (!result && self.savedActiveResponderInputAccessoryView != nil && responder != nil)
    {
        AKALogError(@"Failed to restore input accessory view %@ for responder %@. This indicates an internal inconsistency in the keyboard activation sequence %@ or an unexpected behavior of the responder",
                    self.savedActiveResponderInputAccessoryView, responder, self);
    }

    // Release saved view in any case, because we keep a strong reference to it.
    self.savedActiveResponderInputAccessoryView = nil;

    return result;
}

#pragma mark - Exposed Actions

- (void)closeKeyboard:(id)sender
{
    (void)sender; // not needed
    [self deactivate];
}

- (void)activateNext:(id)sender
{
    (void)sender; // not needed
    (void)[self activateNext];
}

- (void)activatePrevious:(id)sender
{
    (void)sender; // not needed
    (void)[self activatePrevious];
}

@end
