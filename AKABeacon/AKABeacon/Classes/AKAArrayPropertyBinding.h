//
//  AKAArrayPropertyBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 06.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAPropertyBinding.h"

@class AKAArrayPropertyBinding;

@protocol AKAArrayPropertyBindingDelegate <AKABindingDelegate>

@optional
- (void)                                            binding:(AKAArrayPropertyBinding*_Nonnull)binding
                                     sourceArrayItemAtIndex:(NSUInteger)arrayItemIndex
                                                      value:(opt_id)oldValue
                                                didChangeTo:(opt_id)newValue;


@optional
- (void)                                            binding:(AKAArrayPropertyBinding*_Nonnull)binding
                      collectionControllerWillChangeContent:(opt_id)controller;

// TODO: rename
@optional
- (void)                                            binding:(AKAArrayPropertyBinding*_Nonnull)binding
                                       collectionController:(opt_id)controller
                                            didInsertObject:(req_id)object
                                                    atIndex:(NSUInteger)index;

@optional
- (void)                                            binding:(AKAArrayPropertyBinding*_Nonnull)binding
                                       collectionController:(opt_id)controller
                                            didUpdateObject:(req_id)object
                                                    atIndex:(NSUInteger)index;

@optional
- (void)                                            binding:(AKAArrayPropertyBinding*_Nonnull)binding
                                       collectionController:(opt_id)controller
                                            didDeleteObject:(req_id)object
                                                    atIndex:(NSUInteger)index;
@optional
- (void)                                            binding:(AKAArrayPropertyBinding*_Nonnull)binding
                                       collectionController:(opt_id)controller
                                              didMoveObject:(req_id)object
                                                  fromIndex:(NSUInteger)index
                                                    toIndex:(NSUInteger)index;

@optional
- (void)                                            binding:(AKAArrayPropertyBinding*_Nonnull)binding
                       collectionControllerDidChangeContent:(opt_id)controller;

@end


@interface AKAArrayPropertyBinding : AKAPropertyBinding

@property(nonatomic)           BOOL generateContentChangeEventsForSourceArrayChanges;

@end
