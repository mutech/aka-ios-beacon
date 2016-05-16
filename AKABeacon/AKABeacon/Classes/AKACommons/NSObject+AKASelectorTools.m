//
//  NSObject+AKASelectorTools.m
//  AKACommons
//
//  Created by Michael Utech on 27.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "NSObject+AKASelectorTools.h"
#import "NSString+AKATools.h"

@implementation NSObject (AKASelectorTools)

- (BOOL)aka_savePerformSelector:(SEL)selector
                    storeResult:(out __autoreleasing id*)resultStorage
{
    NSParameterAssert(selector != (SEL)0);
    NSAssert([self methodSignatureForSelector:selector].numberOfArguments == 2, @"Wrong number of arguments %lu (expected 2+0) in selector %s", (unsigned long)[self methodSignatureForSelector:selector].numberOfArguments, sel_getName(selector));

    BOOL result = NO;

    if ([self respondsToSelector:selector])
    {
        IMP imp = [self methodForSelector:selector];
        id (* function)(id, SEL) = (id (*)(id, SEL))imp;
        id value = function(self, selector);

        if (resultStorage)
        {
            *resultStorage = value;
        }
        result = YES;
    }

    return result;
}

- (BOOL)aka_savePerformSelectorFromString:(NSString*)selectorName
                              storeResult:(out __autoreleasing id*)resultStorage
{
    NSParameterAssert(selectorName.length > 0);
    SEL selector = NSSelectorFromString(selectorName);
    NSAssert(selector != (SEL)0, @"Invalid selector name %@", selectorName);
    NSAssert([self methodSignatureForSelector:selector].numberOfArguments == 2, @"Wrong number of arguments %lu (expected 2+0) in selector %@", (unsigned long)[self methodSignatureForSelector:selector].numberOfArguments, selectorName);

    BOOL result = NO;

    if ([self respondsToSelector:selector])
    {
        IMP imp = [self methodForSelector:selector];
        id (* function)(id, SEL) = (id (*)(id, SEL))imp;
        id value = function(self, selector);

        if (resultStorage)
        {
            *resultStorage = value;
        }
        result = YES;
    }

    return result;
}

- (BOOL)aka_savePerformSelectorFromString:(NSString*)selectorName
{
    NSParameterAssert(selectorName.length > 0);
    SEL selector = NSSelectorFromString(selectorName);
    NSAssert(selector != (SEL)0, @"Invalid selector name %@", selectorName);
    NSAssert([self methodSignatureForSelector:selector].numberOfArguments == 2, @"Wrong number of arguments %lu (expected 2+0) in selector %@", (unsigned long)[self methodSignatureForSelector:selector].numberOfArguments, selectorName);

    NSParameterAssert(![selectorName containsString:@":"]);

    BOOL result = NO;

    if ([self respondsToSelector:selector])
    {
        IMP imp = [self methodForSelector:selector];
        void (* function)(id, SEL) = (void (*)(id, SEL))imp;
        function(self, selector);
        result = YES;
    }

    return result;
}

- (BOOL)aka_savePerformSelectorFromString:(NSString*)selectorName
                               withObject:(id)object1
{
    NSParameterAssert(selectorName.length > 0);
    SEL selector = NSSelectorFromString(selectorName);
    NSAssert(selector != (SEL)0, @"Invalid selector name %@", selectorName);
    NSAssert([self methodSignatureForSelector:selector].numberOfArguments == 3, @"Wrong number of arguments %lu (expected 2+1) in selector %@", (unsigned long)[self methodSignatureForSelector:selector].numberOfArguments, selectorName);

    BOOL result = NO;

    if ([self respondsToSelector:selector])
    {
        IMP imp = [self methodForSelector:selector];
        void (* function)(id, SEL, id) = (void (*)(id, SEL, id))imp;
        function(self, selector, object1);
        result = YES;
    }

    return result;
}

- (BOOL)aka_savePerformSelectorFromString:(NSString*)selectorName
                               withObject:(id)object1
                              storeResult:(out __autoreleasing id*)resultStorage
{
    NSParameterAssert(selectorName.length > 0);
    SEL selector = NSSelectorFromString(selectorName);
    NSAssert(selector != (SEL)0, @"Invalid selector name %@", selectorName);
    NSAssert([self methodSignatureForSelector:selector].numberOfArguments == 3, @"Wrong number of arguments %lu (expected 2+1) in selector %@", (unsigned long)[self methodSignatureForSelector:selector].numberOfArguments, selectorName);

    BOOL result = NO;

    if ([self respondsToSelector:selector])
    {
        IMP imp = [self methodForSelector:selector];
        id (* function)(id, SEL, id) = (id (*)(id, SEL, id))imp;
        id value = function(self, selector, object1);

        if (resultStorage)
        {
            *resultStorage = value;
        }
        result = YES;
    }

    return result;
}

- (BOOL)aka_savePerformSelectorFromString:(NSString*)selectorName
                               withObject:(id)object1
                               withObject:(id)object2
{
    NSParameterAssert(selectorName.length > 0);
    SEL selector = NSSelectorFromString(selectorName);
    NSAssert(selector != (SEL)0, @"Invalid selector name %@", selectorName);
    NSAssert([self methodSignatureForSelector:selector].numberOfArguments == 4, @"Wrong number of arguments %lu (expected 2+2) in selector %@", (unsigned long)[self methodSignatureForSelector:selector].numberOfArguments, selectorName);

    BOOL result = NO;

    if ([self respondsToSelector:selector])
    {
        IMP imp = [self methodForSelector:selector];
        void (* function)(id, SEL, id, id) = (void (*)(id, SEL, id, id))imp;
        function(self, selector, object1, object2);
        result = YES;
    }

    return result;
}

- (BOOL)aka_savePerformSelectorFromString:(NSString*)selectorName
                               withObject:(id)object1
                               withObject:(id)object2
                              storeResult:(out __autoreleasing id*)resultStorage
{
    NSParameterAssert(selectorName.length > 0);
    SEL selector = NSSelectorFromString(selectorName);
    NSAssert(selector != (SEL)0, @"Invalid selector name %@", selectorName);
    NSAssert([self methodSignatureForSelector:selector].numberOfArguments == 4, @"Wrong number of arguments %lu (expected 2+2) in selector %@", (unsigned long)[self methodSignatureForSelector:selector].numberOfArguments, selectorName);

    BOOL result = NO;

    if ([self respondsToSelector:selector])
    {
        IMP imp = [self methodForSelector:selector];
        id (* function)(id, SEL, id, id) = (id (*)(id, SEL, id, id))imp;
        id value = function(self, selector, object1, object2);

        if (resultStorage)
        {
            *resultStorage = value;
        }
        result = YES;
    }

    return result;
}

@end
