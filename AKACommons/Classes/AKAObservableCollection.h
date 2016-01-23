//
//  AKAObservableCollection.h
//  AKACommons
//
//  Created by Michael Utech on 02.05.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKANullability.h"

@class AKAObservableCollection;

@protocol AKAObservableCollectionDelegate

@optional
- (void)collectionWillChangeContent:(AKAObservableCollection*_Nonnull)collection;

@optional
- (void)                 collection:(AKAObservableCollection*_Nonnull)collection
            didInsertItemsAtIndexes:(NSIndexSet*_Nonnull)indexes;

@optional
- (void)                 collection:(AKAObservableCollection*_Nonnull)collection
            didDeleteItemsAtIndexes:(NSIndexSet*_Nonnull)indexes;

@optional
- (void)                 collection:(AKAObservableCollection*_Nonnull)collection
                     didReplaceItem:(req_id)oldItem
                            atIndex:(NSUInteger)index
                           withItem:(req_id)newItem;

@optional
- (void)collectionDidChangeContent:(AKAObservableCollection*_Nonnull)collection;

@end


@interface AKAObservableCollection<__covariant ObjectType> : NSObject

#pragma mark - Initialization

/**
 * Initializes the instance as empty (mutable) collection.
 *
 * @return The new instance
 */
- (instancetype _Nonnull)                   init;

/**
 * Initializes the instance containing the elements of the specified
 * array. The specified array is not used internally (except for copying
 * its contents)
 *
 * @param array The array containing the initial content for the collection.
 *
 * @return The new instance
 */
- (instancetype _Nonnull)          initWithArray:(NSArray<ObjectType>* _Nonnull)array;

/**
 * Initializes the instance to use the specified mutable array as
 * storage for the collection. The contents of the array is preserved.
 * Changes applied to the collection will be forwarded to the mutable
 * array.
 *
 * @param mutableArray the mutable array to use as storage for collection elements.
 *
 * @return The new instance
 */
- (instancetype _Nonnull)   initWithMutableArray:(NSMutableArray<ObjectType>* _Nonnull)mutableArray;

#pragma mark - Properties

/**
 An array containing all items of the collection.
 
 @note that this is not necesserily the same instance as the array with which the collection might have been initialized.
 */
@property(nonatomic, readonly, nonnull) NSArray<ObjectType>* items;

/**
 A mutable array proxy. Changes made to the contents of this array will trigger collection KVO events.
 */
@property(nonatomic, readonly, nonnull) NSMutableArray<ObjectType>* mutableItems;

#pragma mark - Indexed Accessors

- (NSUInteger)                      countOfItems;

- (ObjectType _Nonnull)     objectInItemsAtIndex:(NSUInteger)index;

- (void)                                getItems:(__unsafe_unretained ObjectType _Nullable* _Nonnull)buffer
                                           range:(NSRange)inRange;


#pragma mark - Mutable Indexed Accessors

- (void)                            insertObject:(req_id)object
                                  inItemsAtIndex:(NSUInteger)index;

- (void)                             insertItems:(NSArray<ObjectType>* _Nonnull)array
                                       atIndexes:(NSIndexSet* _Nonnull)indexes;

- (void)            removeObjectFromItemsAtIndex:(NSUInteger)index;

- (void)                    removeItemsAtIndexes:(NSIndexSet* _Nonnull)indexes;

- (void)             replaceObjectInItemsAtIndex:(NSUInteger)index
                                      withObject:(ObjectType _Nonnull)object;

- (void)                   replaceItemsAtIndexes:(NSIndexSet* _Nonnull)indexes
                                       withItems:(NSArray<ObjectType>* _Nonnull)array;

@end


@interface AKAObservableCollection<__covariant ObjectType>(Convenience)

@end
