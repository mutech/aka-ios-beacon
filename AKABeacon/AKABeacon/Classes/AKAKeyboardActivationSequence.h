//
//  AKAKeyboardActivationSequence.h
//  AKABeacon
//
//  Created by Michael Utech on 10.04.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;
@import AKACommons.AKANullability;

#import "AKAKeyboardActivationSequenceItemProtocol.h"

@protocol AKAKeyboardActivationSequenceDelegate;
@class AKAKeyboardActivationSequence;
typedef AKAKeyboardActivationSequence* _Nonnull                     req_AKAKeyboardActivationSequence;
typedef AKAKeyboardActivationSequence* _Nullable                    opt_AKAKeyboardActivationSequence;


#pragma mark - AKAKeyboardActivationSequence
#pragma mark -

@interface AKAKeyboardActivationSequence : NSObject

#pragma mark - Initialization

- (instancetype _Nonnull)                                     init;

- (instancetype _Nonnull)                         initWithDelegate:(id<AKAKeyboardActivationSequenceDelegate>_Nullable)delegate;

#pragma mark - Configuration

@property(nonatomic, weak) id<AKAKeyboardActivationSequenceDelegate>
                                                          delegate;

#pragma mark - Items

@property(nonatomic, readonly) NSUInteger             countOfItems;

- (void)                                            setNeedsUpdate;
- (void)                                            updateIfNeeded;
- (void)                                                    update;

#pragma mark - Properties

@property(nonatomic, readonly) NSUInteger          activeItemIndex;

@property(nonatomic, readonly, nonnull) UIView* inputAccessoryView;

- (NSUInteger)                                         indexOfItem:(req_AKAKeyboardActivationSequenceItem)item;

- (opt_AKAKeyboardActivationSequenceItem)              itemAtIndex:(NSUInteger)index;

#pragma mark - Activation

- (BOOL)                                     prepareToActivateItem:(req_AKAKeyboardActivationSequenceItem)item;

- (BOOL)                                                deactivate;


@end


#pragma mark - AKAKeyboardActivationSequence(Convenience)
#pragma mark -

@interface AKAKeyboardActivationSequence(Convenience)

@property(nonatomic, readonly, weak) AKAKeyboardActivationSequenceItem  activeItem;
@property(nonatomic, readonly, weak) AKAKeyboardActivationSequenceItem  previousItem;
@property(nonatomic, readonly, weak) AKAKeyboardActivationSequenceItem  nextItem;

- (BOOL)                                     activateItemAtIndex:(NSUInteger)index;

- (BOOL)                                            activateItem:(req_AKAKeyboardActivationSequenceItem)item;

- (BOOL)                                        activatePrevious;

- (BOOL)                                            activateNext;

#pragma mark - Actions (For input accessory views)

- (IBAction)                                    activatePrevious:(req_AKAKeyboardActivationSequenceItem)sender;
- (IBAction)                                        activateNext:(req_AKAKeyboardActivationSequenceItem)sender;
- (IBAction)                                       closeKeyboard:(req_AKAKeyboardActivationSequenceItem)sender;

@end


#pragma mark - AKAKeyboardActivationSequenceDelegate
#pragma mark -

@protocol AKAKeyboardActivationSequenceDelegate <NSObject>

- (void)    enumerateItemsInKeyboardActivationSequenceUsingBlock:(void(^_Nonnull)(req_AKAKeyboardActivationSequenceItem object,
                                                                                  NSUInteger idx,
                                                                                  outreq_BOOL stop))block;

@optional
- (req_UIView)createInputAccessoryViewForKeyboardActivationSequence:(req_AKAKeyboardActivationSequence)keyboardActivationSequence
                                             activatePreviousAction:(opt_SEL)activatePrevious
                                                 activateNextAction:(opt_SEL)activateNext
                                                closeKeyboardAction:(opt_SEL)closeKeyboard;

@optional
- (void)                                 setupInputAccessoryView:(opt_UIView)inputAccessoryView
                                   forKeyboardActivationSequence:(req_AKAKeyboardActivationSequence)keyboardActivationSequence
                                                    previousItem:(opt_AKAKeyboardActivationSequenceItem)previousItem
                                                      activeItem:(req_AKAKeyboardActivationSequenceItem)activeItem
                                                        nextItem:(opt_AKAKeyboardActivationSequenceItem)nextItem;

@optional
- (req_UIView)                       customizeInputAccessoryView:(req_UIView)inputAccessoryView
                                   forKeyboardActivationSequence:(req_AKAKeyboardActivationSequence)keyboardActivationSequence;

@end
