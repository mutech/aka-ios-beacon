//
//  AKAKeyboardActivationSequence.h
//  AKAControls
//
//  Created by Michael Utech on 10.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import UIKit;
@import AKACommons.AKANullability;

@class AKAKeyboardActivationSequence;
typedef AKAKeyboardActivationSequence* _Nonnull                     req_AKAKeyboardActivationSequence;
typedef AKAKeyboardActivationSequence* _Nullable                    opt_AKAKeyboardActivationSequence;

@protocol AKAKeyboardActivationSequenceItemProtocol <NSObject>

@property(nonatomic, readonly, weak) opt_UIResponder responderForKeyboardActivationSequence;
@property(nonatomic, readonly)       BOOL            isActive;

- (BOOL)participatesInKeyboardActivationSequence;

- (BOOL)activate;
- (BOOL)deactivate;

- (BOOL)installInputAccessoryView:(req_UIView)inputAccessoryView;
- (BOOL)restoreInputAccessoryView;

@end

typedef id<AKAKeyboardActivationSequenceItemProtocol>               AKAKeyboardActivationSequenceItem;
typedef id<AKAKeyboardActivationSequenceItemProtocol> _Nullable     opt_AKAKeyboardActivationSequenceItem;
typedef id<AKAKeyboardActivationSequenceItemProtocol> _Nonnull      req_AKAKeyboardActivationSequenceItem;

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

@interface AKAKeyboardActivationSequence : NSObject

#pragma mark - Configuration

@property(nonatomic, weak) id<AKAKeyboardActivationSequenceDelegate> delegate;

#pragma mark - Access

@property(nonatomic, readonly) NSUInteger                               activeItemIndex;
@property(nonatomic, readonly, weak) AKAKeyboardActivationSequenceItem  activeItem;
@property(nonatomic, readonly, weak) AKAKeyboardActivationSequenceItem  previousItem;
@property(nonatomic, readonly, weak) AKAKeyboardActivationSequenceItem  nextItem;
@property(nonatomic, readonly, weak) UIResponder*                       activeResponder;
@property(nonatomic, readonly, nullable) UIView*                        inputAccessoryView;
@property(nonatomic, readonly) NSUInteger                               count;

- (NSUInteger)                                       indexOfItem:(req_AKAKeyboardActivationSequenceItem)item;
- (opt_AKAKeyboardActivationSequenceItem)            itemAtIndex:(NSUInteger)index;

#pragma mark - Updating the sequence

- (void)                                          setNeedsUpdate;
- (void)                                                  update;

#pragma mark - Activation

- (BOOL)                                   prepareToActivateItem:(req_AKAKeyboardActivationSequenceItem)item;

- (BOOL)                                        activatePrevious;
- (BOOL)                                            activateNext;
- (BOOL)                                            activateItem:(req_AKAKeyboardActivationSequenceItem)item
                                                         atIndex:(NSUInteger)index;

- (BOOL)                                              deactivate;


@end

@interface AKAKeyboardActivationSequence(Convenience)


- (opt_UIResponder)                             responderAtIndex:(NSUInteger)index;

- (BOOL)                                            activateItem:(req_AKAKeyboardActivationSequenceItem)item;

#pragma mark - Actions (For input accessory views)

- (IBAction)                                    activatePrevious:(req_AKAKeyboardActivationSequenceItem)sender;
- (IBAction)                                        activateNext:(req_AKAKeyboardActivationSequenceItem)sender;
- (IBAction)                                       closeKeyboard:(req_AKAKeyboardActivationSequenceItem)sender;

@end

