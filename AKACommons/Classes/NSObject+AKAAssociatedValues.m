//
//  NSObject+AKAAssociatedValues.m
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "NSObject+AKAAssociatedValues.h"
#import <objc/runtime.h>

@interface NSObject()

@property (atomic, readonly) NSMutableDictionary* aka_associatedValues;

@end

@implementation NSObject (AKAAssociatedValues)

static char associationKey;

- (BOOL)aka_hasAssociatesValues
{
    return [self aka_associatedValues] != nil;
}

- (NSMutableDictionary*)aka_associatedValues
{
    return [self aka_associatedValuesCreateIfMissing:NO];
}

- (NSMutableDictionary*)aka_associatedValuesCreateIfMissing:(BOOL)createIfMissing
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

- (void)aka_setAssociatedValues:(NSDictionary*)values
{
    NSMutableDictionary* storage = [NSMutableDictionary dictionaryWithDictionary:values];
    objc_setAssociatedObject(self, &associationKey, storage, OBJC_ASSOCIATION_RETAIN);
}

- (id)aka_associatedValueForKey:(id)key
{
    id result = nil;
    id associatedValues = [self aka_associatedValues];
    if ([associatedValues isKindOfClass:[NSDictionary class]])
    {
        result = [((NSDictionary*)associatedValues) objectForKey:key];
    }
    return result;
}

- (void)aka_setAssociatedValue:(id)value forKey:(NSString*)key
{
    if (value == nil)
    {
        [self aka_removeValueAssociatedWithKey:key];
    }
    else
    {
        id associatedValues = [self aka_associatedValuesCreateIfMissing:YES];
        if ([associatedValues isKindOfClass:[NSMutableDictionary class]])
        {
            [((NSMutableDictionary*)associatedValues) setObject:value forKey:key];
        }
    }
}

- (void)aka_removeValueAssociatedWithKey:(NSString*)key
{
    id associatedValues = [self aka_associatedValuesCreateIfMissing:YES];
    if ([associatedValues isKindOfClass:[NSMutableDictionary class]])
    {
        [((NSMutableDictionary*)associatedValues) removeObjectForKey:key];
    }
    return;
}

- (void)aka_removeAllAssociatedValues
{
    [self aka_setAssociatedValues:nil];
}


- (void)aka_savePropertyValues:(NSArray*)propertyNames
{
    for (NSString* key in propertyNames)
    {
        if ([self aka_associatedValueForKey:key] == nil)
        {
            id value = [self valueForKey:key];
            if (value == nil)
            {
                value = [NSNull null];
            }
            [self aka_setAssociatedValue:value forKey:key];
        }
    }
}

- (void)aka_restoreSavedPropertyValues:(NSArray*)propertyNames
{
    for (NSString* key in propertyNames)
    {
        id value = [self aka_associatedValueForKey:key];
        if (value == [NSNull null])
        {
            [self setValue:nil forKey:key];
        }
        else if (value != nil)
        {
            [self setValue:value forKey:key];
        }
    }
}

- (void)aka_removeSavedPropertyValues:(NSArray*)propertyNames
{
    for (NSString* key in propertyNames)
    {
        [self aka_removeValueAssociatedWithKey:key];
    }
}

@end

