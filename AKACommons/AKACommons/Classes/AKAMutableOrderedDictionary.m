// Based on (with modifications):
// ------------------------------
//
//  OrderedDictionary.m
//  OrderedDictionary
//
//  Created by Matt Gallagher on 19/12/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//

#import "AKAMutableOrderedDictionary.h"

@interface AKAMutableOrderedDictionary<K, V>()

@property(nonatomic, readonly) NSMutableArray* sequence;
@property(nonatomic, readonly) NSMutableDictionary<K, V>* storage;

@end

@implementation AKAMutableOrderedDictionary

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _sequence = [NSMutableArray new];
        _storage = [NSMutableDictionary new];
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)capacity
{
	self = [super init];
	if (self != nil)
	{
        _sequence = [NSMutableArray new];
        _storage = [[NSMutableDictionary alloc] initWithCapacity:capacity];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        _storage = [[NSMutableDictionary alloc] initWithCoder:aDecoder];
        _sequence = [NSMutableArray new];
    }
    return self;
}

- (id)copy
{
	return [self mutableCopy];
}

- (void)setObject:(id)anObject forKey:(id)aKey
{
	if (![self.storage objectForKey:aKey])
	{
		[self.sequence addObject:aKey];
	}
	[self.storage setObject:anObject forKey:aKey];
}

- (void)removeObjectForKey:(id)aKey
{
	[self.storage removeObjectForKey:aKey];
	[self.sequence removeObject:aKey];
}

- (NSUInteger)count
{
	return [self.storage count];
}

- (id)objectForKey:(id)aKey
{
	return [self.storage objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator
{
	return [self.sequence objectEnumerator];
}

- (NSEnumerator *)reverseKeyEnumerator
{
	return [self.sequence reverseObjectEnumerator];
}

- (void)insertObject:(id)anObject forKey:(id)aKey atIndex:(NSUInteger)anIndex
{
	if ([self.storage objectForKey:aKey])
	{
		[self removeObjectForKey:aKey];
	}
	[self.sequence insertObject:aKey atIndex:anIndex];
	[self.storage setObject:anObject forKey:aKey];
}

- (id)keyAtIndex:(NSUInteger)anIndex
{
	return [self.sequence objectAtIndex:anIndex];
}

@end
