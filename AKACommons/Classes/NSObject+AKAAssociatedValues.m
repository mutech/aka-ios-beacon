//
//  NSObject+AKAAssociatedValues.m
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "NSObject+AKAAssociatedValues.h"
#import <objc/runtime.h>

@interface NSObject()

@property (atomic, readonly) NSMutableDictionary* associatedValues;

@end

@implementation NSObject (AKAAssociatedValues)

static char associationKey;

- (BOOL)hasAssociatesValues
{
    return self.associatedValues != nil;
}

- (NSMutableDictionary*)associatedValues
{
    return [self associatedValuesCreateIfMissing:NO];
}

- (NSMutableDictionary*)associatedValuesCreateIfMissing:(BOOL)createIfMissing
{
    id result = objc_getAssociatedObject(self, &associationKey);
    if (result == nil)
    {
        if (createIfMissing)
        {
            result = [[NSMutableDictionary alloc] init];
            objc_setAssociatedObject(self, &associationKey, result, OBJC_ASSOCIATION_RETAIN);
        }
    }
    return result;
}

- (void)setAssociatedValues:(NSDictionary*)values
{
    NSMutableDictionary* storage = [NSMutableDictionary dictionaryWithDictionary:values];
    objc_setAssociatedObject(self, &associationKey, storage, OBJC_ASSOCIATION_RETAIN);
}

- (id)associatedValueForKey:(id)key
{
    id result = nil;
    id associatedValues = [self associatedValues];
    if ([associatedValues isKindOfClass:[NSDictionary class]])
    {
        result = [((NSDictionary*)associatedValues) objectForKey:key];
    }
    return result;
}

- (void)setAssociatedValue:(id)value forKey:(NSString*)key
{
    id associatedValues = [self associatedValuesCreateIfMissing:YES];
    if ([associatedValues isKindOfClass:[NSMutableDictionary class]])
    {
        [((NSMutableDictionary*)associatedValues) setObject:value forKey:key];
    }
    return;
}

- (void)removeValueAssociatedWithKey:(NSString*)key
{
    id associatedValues = [self associatedValuesCreateIfMissing:YES];
    if ([associatedValues isKindOfClass:[NSMutableDictionary class]])
    {
        [((NSMutableDictionary*)associatedValues) removeObjectForKey:key];
    }
    return;
}

- (void)removeAllAssociatedValues
{
    [self setAssociatedValues:nil];
}

@end
