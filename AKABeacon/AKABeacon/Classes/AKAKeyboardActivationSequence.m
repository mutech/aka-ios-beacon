//
//  AKAKeyboardActivationSequence.m
//  AKABeacon
//
//  Created by Michael Utech on 10.04.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;
@import AKACommons.AKALog;
@import AKACommons.AKAReference;

#import "AKAKeyboardActivationSequence.h"
#import "AKAKeyboardActivationSequenceAccessoryView.h"
#import "AKAKeyboardActivationSequenceItemProtocol_Internal.h"

#pragma mark - AKAKeyboardActivationSequence - Private Interface
#pragma mark -

@interface AKAKeyboardActivationSequence ()

@property(nonatomic, readonly)  NSMutableArray<AKAWeakReference<AKAKeyboardActivationSequenceItem>*>* items;
@property(nonatomic)            NSUInteger activeItemIndex;
@property(nonatomic, nullable)  UIResponder*  activeResponder;

@end


#pragma mark - AKAKeyboardActivationSequence - Implementation
#pragma mark -

@implementation AKAKeyboardActivationSequence

#pragma mark - Properties

@synthesize                                        items = _items;

@synthesize                           inputAccessoryView = _inputAccessoryView;

@synthesize                              activeItemIndex = _activeItemIndex;

@synthesize                              activeResponder = _activeResponder;

#pragma mark - Initialization

- (instancetype)                                    init
{
    if (self = [super init])
    {
        self.activeItemIndex = NSNotFound;
        self.activeResponder = nil;
    }

    return self;
}

- (instancetype)                        initWithDelegate:(id<AKAKeyboardActivationSequenceDelegate>)delegate
{
    if (self = [self init])
    {
        self.delegate = delegate;
    }

    return self;
}

#pragma mark - Items

- (NSMutableArray*)                               items
{
    if (_items == nil)
    {
        [self update];
    }

    return _items;
}

- (NSUInteger)                              countOfItems
{
    return self.items.count;
}

- (NSUInteger)                               indexOfItem:(req_AKAKeyboardActivationSequenceItem)item
{
    __block NSUInteger result = NSNotFound;

    if (item != nil)
    {
        [self.items
         enumerateObjectsUsingBlock:^(AKAWeakReference* _Nonnull obj, NSUInteger idx, BOOL* _Nonnull stop)
         {
             id rItem = obj.value;
             if (item == rItem || [item isEqual:rItem])
             {
                 result = idx;
                 *stop = YES;
             }
         }];
    }
    return result;
}

- (opt_AKAKeyboardActivationSequenceItem)    itemAtIndex:(NSUInteger)index
{
    AKAKeyboardActivationSequenceItem result = nil;

    if (index != NSNotFound)
    {
        AKAWeakReference* reference = self.items[index];
        result = reference.value;
    }

    return result;
}

#pragma mark Updating (adding and removing) items

- (void)                                  setNeedsUpdate
{
    [self removeAllItems];
    _items = nil;
}

- (void)                                  updateIfNeeded
{
    if (_items == nil)
    {
        [self update];
    }
}

- (void)addItem:(AKAKeyboardActivationSequenceItem)item
{
    [self registerItem:item];
    [_items addObject:[AKAWeakReference weakReferenceTo:item]];
}

- (void)removeAllItems
{
    [_items enumerateObjectsUsingBlock:^(AKAWeakReference<AKAKeyboardActivationSequenceItem>*_Nonnull reference,
                                         NSUInteger idx,
                                         BOOL * _Nonnull stop)
     {
         (void)idx;
         (void)stop;
         
         [self unregisterItem:reference.value];
     }];
    [_items removeAllObjects];

}

- (void)registerItem:(AKAKeyboardActivationSequenceItem)item
{
    if ([item conformsToProtocol:@protocol(AKAKeyboardActivationSequenceItemProtocol_Internal)])
    {
        id<AKAKeyboardActivationSequenceItemProtocol_Internal> itemInternal = (id)item;
        [itemInternal setKeyboardActivationSequence:self];
    }
}

- (void)unregisterItem:(AKAKeyboardActivationSequenceItem)item
{
    if ([item conformsToProtocol:@protocol(AKAKeyboardActivationSequenceItemProtocol_Internal)])
    {
        id<AKAKeyboardActivationSequenceItemProtocol_Internal> itemInternal = (id)item;
        [itemInternal setKeyboardActivationSequence:nil];
    }
}

- (void)                                          update
{
    if (_items == nil)
    {
        _items = [NSMutableArray new];
    }
    else
    {
        [self removeAllItems];
    }

    [self.delegate enumerateItemsInKeyboardActivationSequenceUsingBlock:
     ^(req_AKAKeyboardActivationSequenceItem    item,
       NSUInteger                               idx,
       outreq_BOOL                              stop)
     {
         (void)stop; // not needed
         UIResponder* responder = [item responderForKeyboardActivationSequence];

         if (responder != nil)
         {
             [self addItem:item];
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
                 [self registerActiveResponder:responder
                                       forItem:item
                                       atIndex:idx];
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

#pragma mark - Input Accessory View

- (UIView*)                           inputAccessoryView
{
    if (!_inputAccessoryView)
    {
        _inputAccessoryView = [self createInputAccessoryView];

        id<AKAKeyboardActivationSequenceDelegate> delegate = self.delegate;
        if (_inputAccessoryView != nil && [delegate respondsToSelector:@selector(customizeInputAccessoryView:forKeyboardActivationSequence:)])
        {
            [delegate customizeInputAccessoryView:_inputAccessoryView
                    forKeyboardActivationSequence:self];
        }
    }

    return _inputAccessoryView;
}

- (UIView*)                     createInputAccessoryView
{
    UIView* result = nil;

    id<AKAKeyboardActivationSequenceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(createInputAccessoryViewForKeyboardActivationSequence:activatePreviousAction:activateNextAction:closeKeyboardAction:)])
    {
        result =
            [delegate
             createInputAccessoryViewForKeyboardActivationSequence:self
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

- (BOOL)              setInputAccessoryViewForActiveItem
{
    AKAKeyboardActivationSequenceItem item = self.activeItem;

    BOOL result = item != nil;

    if (result)
    {
        result = [item installInputAccessoryView:self.inputAccessoryView];

        if (result)
        {
            [self updateInputAccessoryView];
        }
    }

    return result;
}

- (BOOL)          restoreInputAccessoryViewForActiveItem
{
    AKAKeyboardActivationSequenceItem item = self.activeItem;

    BOOL result = item != nil;

    if (result)
    {
        result = [item restoreInputAccessoryView];
    }

    return result;
}

- (void)                        updateInputAccessoryView
{
    if (self.activeResponder != nil)
    {
        if ([self.inputAccessoryView isKindOfClass:[AKAKeyboardActivationSequenceAccessoryView class]])
        {
            AKAKeyboardActivationSequenceAccessoryView* inputAccessoryView = (AKAKeyboardActivationSequenceAccessoryView*)self.inputAccessoryView;
            [inputAccessoryView updateBarItemStates];
        }
    }
}

#pragma mark - Activation

- (BOOL)                           prepareToActivateItem:(req_AKAKeyboardActivationSequenceItem)item
{
    // Typically called by items which know they will activate and need to ensure
    // that their responder's input accessory view is setup before becoming

    // first responder.
    return [self registerActiveResponder:[item responderForKeyboardActivationSequence]
                                 forItem:item
                                 atIndex:[self indexOfItem:item]];
}

- (BOOL)                                    activateItem:(req_AKAKeyboardActivationSequenceItem)item
                                                 atIndex:(NSUInteger)index
{
    NSParameterAssert(item != nil);
    NSParameterAssert(index != NSNotFound);
    NSParameterAssert([self itemAtIndex:index] == item);

    BOOL result = index < self.items.count;

    if (result)
    {
        UIResponder* responder = item.responderForKeyboardActivationSequence;
        result = [self registerActiveResponder:responder
                                       forItem:item
                                       atIndex:index];

        if (result && !item.isResponderActive)
        {

            result = [item activateResponder];
        }
    }

    return result;
}

- (BOOL)                                      deactivate
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

- (void)                       unregisterActiveResponder
{
    if (self.activeResponder != nil)
    {
        [self restoreInputAccessoryViewForActiveItem];
        self.activeResponder = nil;
    }
    self.activeItemIndex = NSNotFound;
}

- (BOOL)                         registerActiveResponder:(UIResponder*)responder
                                                 forItem:(id)item
                                                 atIndex:(NSUInteger)index
{
    (void)item;

    BOOL result = responder == self.activeResponder;

    if (result)
    {
        NSAssert(self.activeItem == item, @"Inconsistency: responder %@ is active responder, but owning item %@ is not active item in keyboard activation sequence", responder, item);
    }
    else
    {
        if ((self.activeItemIndex != index && self.activeItemIndex != NSNotFound) ||
            self.activeResponder != nil)
        {
            [self unregisterActiveResponder];
        }

        // We cannot test [responder canBecomeFirstResponder] because this method might
        // have been called in a shouldBegin... delegate method and calling canBecome..
        // here again would lead to an endless loop. Registering the active responder
        // might need to be called from a shouldBegin delegate method, because the inputAccessoryView
        // of the responder has to be set before the responder becomes first responder and
        // this might be the only opportunity of a view to detect that its about to
        // get a keyboard.

        result = YES;
        self.activeResponder = responder;
        self.activeItemIndex = index;
        [self setInputAccessoryViewForActiveItem];
    }

    return result;
}

@end


#pragma mark - AKAKeyboardActivationSequence - Convenience Implementation
#pragma mark

@implementation AKAKeyboardActivationSequence (Convenience)

#pragma mark - Activation

#pragma mark State

- (opt_AKAKeyboardActivationSequenceItem)     activeItem
{
    AKAKeyboardActivationSequenceItem result = [self itemAtIndex:self.activeItemIndex];

    return result;
}

- (NSUInteger)                             nextItemIndex
{
    NSUInteger result = NSNotFound;

    if (self.activeItemIndex != NSNotFound && self.activeItemIndex + 1 < self.countOfItems)
    {
        result = self.activeItemIndex + 1;
    }

    return result;
}

- (opt_AKAKeyboardActivationSequenceItem)       nextItem
{
    AKAKeyboardActivationSequenceItem result = [self itemAtIndex:[self nextItemIndex]];

    return result;
}

- (NSUInteger)                         previousItemIndex
{
    NSUInteger result = NSNotFound;

    if (self.activeItemIndex != NSNotFound && self.activeItemIndex >= 1)
    {
        result = self.activeItemIndex - 1;
    }

    return result;
}

- (opt_AKAKeyboardActivationSequenceItem)   previousItem
{
    AKAKeyboardActivationSequenceItem result = [self itemAtIndex:[self previousItemIndex]];

    return result;
}

#pragma mark Control

- (BOOL)                             activateItemAtIndex:(NSUInteger)index
{
    BOOL result = index != NSNotFound;

    if (result)
    {
        NSParameterAssert(index != NSNotFound);
        NSParameterAssert(index >= 0 && index < self.items.count);

        AKAKeyboardActivationSequenceItem item = [self itemAtIndex:index];
        result = [self activateItem:item atIndex:index];
    }

    return result;
}

- (BOOL)                                    activateItem:(req_AKAKeyboardActivationSequenceItem)item
{
    BOOL result = NO;
    NSUInteger index = [self indexOfItem:item];

    if (index != NSNotFound)
    {
        result = [self activateItem:item atIndex:index];
    }

    return result;
}

- (BOOL)                                    activateNext
{
    NSUInteger index = [self nextItemIndex];

    return [self activateItemAtIndex:index];
}

- (BOOL)                                activatePrevious
{
    NSUInteger index = [self previousItemIndex];

    return [self activateItemAtIndex:index];
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