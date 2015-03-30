//
//  NSObject+AKASelectorTools.h
//  AKACommons
//
//  Created by Michael Utech on 27.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (AKASelectorTools)

- (BOOL)aka_savePerformSelector:(SEL)selector
                    storeResult:(out __autoreleasing id*)resultStorage;

- (BOOL)aka_savePerformSelectorFromString:(NSString*)selectorName;
- (BOOL)aka_savePerformSelectorFromString:(NSString*)selectorName
                              storeResult:(out __autoreleasing id*)resultStorage;

- (BOOL)aka_savePerformSelectorFromString:(NSString*)selectorName
                               withObject:(id)object1;
- (BOOL)aka_savePerformSelectorFromString:(NSString*)selectorName
                               withObject:(id)object1
                              storeResult:(out __autoreleasing id*)resultStorage;

- (BOOL)aka_savePerformSelectorFromString:(NSString*)selectorName
                               withObject:(id)object1
                               withObject:(id)object2;
- (BOOL)aka_savePerformSelectorFromString:(NSString*)selectorName
                               withObject:(id)object1
                               withObject:(id)object2
                              storeResult:(out __autoreleasing id*)resultStorage;

@end
