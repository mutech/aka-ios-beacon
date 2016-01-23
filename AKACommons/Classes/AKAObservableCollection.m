//
//  AKAObservableCollection.m
//  AKACommons
//
//  Created by Michael Utech on 02.05.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAObservableCollection.h"

@interface AKAObservableCollection<__covariant ObjectType>()

@property(nonatomic) NSMutableArray* itemsStorage;
@property(nonatomic) NSMutableArray* cachedMutableItems;

@end

@implementation AKAObservableCollection

#pragma mark - Initialization

- (instancetype)                   init
{
    return [self initWithMutableArray:[NSMutableArray new]];
}

- (instancetype)          initWithArray:(NSArray*)array
{
    NSMutableArray* mutableArray = [NSMutableArray arrayWithArray:array];
    return [self initWithMutableArray:mutableArray];
}

- (instancetype)   initWithMutableArray:(NSMutableArray*)mutableArray
{
    if (self = [super init])
    {
        _itemsStorage = mutableArray;
    }
    return self;
}

#pragma mark - Properties

- (NSArray *)items
{
    return [NSArray arrayWithArray:self.itemsStorage];
}

@synthesize mutableItems = _mutableItems;
- (NSMutableArray *)mutableItems
{
    if (!self.mutableItems)
    {
        _mutableItems = [self mutableArrayValueForKey:@"items"];
    }
    return self.mutableItems;
}

#pragma mark - Indexed Accessors

- (NSUInteger)             countOfItems
{
    return self.itemsStorage.count;
}

- (id)             objectInItemsAtIndex:(NSUInteger)index
{
    return self.itemsStorage[index];
}

- (void)                       getItems:(__unsafe_unretained id _Nonnull*)buffer
                                  range:(NSRange)inRange
{
    [self.itemsStorage getObjects:buffer range:inRange];
}

#pragma mark - Mutable Indexed Accessors

- (void)                   insertObject:(id)object
                         inItemsAtIndex:(NSUInteger)index
{
    [self.itemsStorage insertObject:object atIndex:index];
}

- (void)                    insertItems:(NSArray *)array
                              atIndexes:(NSIndexSet *)indexes
{
    [self.itemsStorage insertObjects:array atIndexes:indexes];
}

- (void)   removeObjectFromItemsAtIndex:(NSUInteger)index
{
    [self.itemsStorage removeObjectAtIndex:index];
}

- (void)           removeItemsAtIndexes:(NSIndexSet *)indexes
{
    [self.itemsStorage removeObjectsAtIndexes:indexes];
}

- (void)    replaceObjectInItemsAtIndex:(NSUInteger)index
                             withObject:(id)object
{
    [self.itemsStorage replaceObjectAtIndex:index withObject:object];
}

- (void)          replaceItemsAtIndexes:(NSIndexSet *)indexes
                              withItems:(NSArray *)array
{
    [self.itemsStorage replaceObjectsAtIndexes:indexes withObjects:array];
}

#pragma mark - Unordered Accessors

- (NSEnumerator *)    enumeratorOfItems
{
    return [self.itemsStorage objectEnumerator];
}

@end


@implementation AKAObservableCollection(Convenience)

#pragma mark - Mutable Array Proxy

- (NSMutableArray *)       mutableArray
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
