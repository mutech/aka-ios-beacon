//
//  AKAReference.m
//  AKACommons
//
//  Created by Michael Utech on 11.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAReference.h"
#import "AKAErrors.h"

@interface AKAStrongReference() {
    __strong id _value;
}
- (instancetype)initWithValue:(id)value;
@end

@interface AKAWeakReference() {
    __weak id _value;
}
- (instancetype)initWithValue:(id)value;
@end

@implementation AKAReference

+ (AKAReference*)strongReferenceTo:(id)value
{
    AKAReference* result = [[AKAStrongReference alloc] initWithValue:value];
    return result;
}

+ (AKAReference*)weakReferenceTo:(id)value
{
    AKAReference* result = [[AKAWeakReference alloc] initWithValue:value];
    return result;
}

- (id)value
{
    AKAErrorAbstractMethodImplementationMissing();
}

- (BOOL)isEqual:(id)object
{
    BOOL result = [object isKindOfClass:[AKAWeakReference class]];
    if (result)
    {
        AKAWeakReference* other = object;
        id value = self.value;
        id otherValue = other.value;
        result = value == otherValue || [value isEqual:otherValue];
    }
    return result;
}

- (NSUInteger)hash
{
    id value = self.value;
    return [value hash];
}

@end

@implementation AKAStrongReference

- (instancetype)initWithValue:(id)value
{
    if (self = [self init])
    {
        _value = value;
    }
    return self;
}

- (id)value
{
    return _value;
}

@end

@implementation AKAWeakReference

- (instancetype)initWithValue:(id)value
{
    if (self = [self init])
    {
        _value = value;
    }
    return self;
}

- (id)value
{
    return _value;
}

@end