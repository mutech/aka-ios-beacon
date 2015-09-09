//
//  AKAObservableCollection.m
//  AKACommons
//
//  Created by Michael Utech on 02.05.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAObservableCollection.h"

@interface AKAObservableCollection()

@property(nonatomic) NSMutableArray* itemsStorage;

@end

@implementation AKAObservableCollection

#pragma mark - Initialization

- (instancetype)init
{
    return [self initWithMutableArray:[NSMutableArray new]];
}

- (instancetype)initWithArray:(NSArray*)array
{
    NSMutableArray* mutableArray = [NSMutableArray arrayWithArray:array];
    return [self initWithMutableArray:mutableArray];
}

- (instancetype)initWithMutableArray:(NSMutableArray*)mutableArray
{
    if (self = [super init])
    {
        _itemsStorage = mutableArray;
    }
    return self;
}

#pragma mark - Indexed Item Property Implementation

- (void)insertObject:(id)object inItemsAtIndex:(NSUInteger)index
{
    [self.itemsStorage insertObject:object atIndex:index];
}

- (void)insertItems:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    [self.itemsStorage insertObjects:array atIndexes:indexes];
}

- (void)removeObjectFromItemsAtIndex:(NSUInteger)index
{
    [self.itemsStorage removeObjectAtIndex:index];
}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes
{
    [self.itemsStorage removeObjectsAtIndexes:indexes];
}

- (id)objectInItemsAtIndex:(NSUInteger)index
{
    return [self.itemsStorage objectAtIndex:index];
}

- (NSUInteger)countOfItems
{
    return self.itemsStorage.count;
}

#pragma mark - Convenience Methods for Indexed Item Property

- (void)removeAllItems
{
    [self.itemsStorage removeAllObjects];
}

#pragma mark - Mutable Array Proxy

- (NSMutableArray *)mutableArray
{
    return [self mutableArrayValueForKey:@"items"];
}

- (void)addItemsObserver:(NSObject *)observer
                 options:(NSKeyValueObservingOptions)options
                 context:(void *)context
{
    [self addObserver:observer forKeyPath:@"items" options:options context:context];
}

- (void)removeItemsObserver:(NSObject *)observer
{
    [self removeObserver:observer forKeyPath:@"items"];
}

- (void)removeItemsObserver:(NSObject *)observer
                    context:(void *)context
{
    [self removeObserver:observer forKeyPath:@"items" context:context];
}

@end
