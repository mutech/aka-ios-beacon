//
//  AKAKeyboardActivationSequence.h
//  AKAControls
//
//  Created by Michael Utech on 10.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AKAKeyboardActivationSequence;

@protocol AKAKeyboardActivationSequenceDelegate <NSObject>

- (void)enumerateItemsInKeyboardActivationSequenceUsingBlock:(void(^)(id object, NSUInteger idx, BOOL* stop))block;

- (UIResponder*)responderForKeyboardActivationSequence:(AKAKeyboardActivationSequence*)keyboardActivationSequence
                                                  item:(id)item;

@optional
- (UIView*)createInputAccessoryViewForKeyboardActivationSequence:(AKAKeyboardActivationSequence*)keyboardActivationSequence
                                          activatePreviousAction:(SEL) activatePrevious
                                              activateNextAction:(SEL)activateNext
                                             closeKeyboardAction:(SEL)closeKeyboard;

@optional
- (void)    setupInputAccessoryView:(UIView*)inputAccessoryView
      forKeyboardActivationSequence:(AKAKeyboardActivationSequence*)keyboardActivationSequence
                       previousItem:(id)previousItem
                         activeItem:(id)activeItem
                           nextItem:(id)nextItem;

@optional
- (UIView*)customizeInputAccessoryView:(UIView*)inputAccessoryView
         forKeyboardActivationSequence:(AKAKeyboardActivationSequence*)keyboardActivationSequence;

@optional
- (BOOL)        activateResponder:(UIResponder*)responder
                          forItem:(id)item
                          atIndex:(NSUInteger)index
     inKeyboardActivationSequence:(AKAKeyboardActivationSequence*)keyboardActivationSequence;

@end

@interface AKAKeyboardActivationSequence : NSObject

#pragma mark - Configuration

@property(nonatomic, weak) id<AKAKeyboardActivationSequenceDelegate> delegate;

#pragma mark - Access

@property(nonatomic, readonly) NSUInteger activeItemIndex;
@property(nonatomic, readonly, weak) id activeItem;
@property(nonatomic, readonly, weak) id previousItem;
@property(nonatomic, readonly, weak) id nextItem;

@property(nonatomic, readonly, weak) UIResponder* activeResponder;
@property(nonatomic, readonly) UIView* inputAccessoryView;

@property(nonatomic, readonly) NSUInteger count;
- (NSUInteger)indexOfItem:(id)item;
- (id)itemAtIndex:(NSUInteger)index;
- (UIResponder*)responderAtIndex:(NSUInteger)index;

#pragma mark - Updating the sequence

- (void)setNeedsUpdate;
- (void)update;

#pragma mark - Activation

- (BOOL)prepareToActivateItem:(id)item;

- (BOOL)activatePrevious;
- (BOOL)activateNext;
- (BOOL)activateItem:(id)item;
- (BOOL)activateItemAtIndex:(NSUInteger)index;

- (BOOL)deactivate;

- (IBAction)activatePrevious:(id)sender;
- (IBAction)activateNext:(id)sender;
- (IBAction)closeKeyboard:(id)sender;

@end
