//
//  AKAReference.m
//  AKACommons
//
//  Created by Michael Utech on 11.04.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAReference.h"
#import "AKAErrors.h"
#import "AKADeallocSentinel.h"

#include <objc/runtime.h>

@interface AKAStrongReference<__covariant ObjectType>() {
    __strong ObjectType _value;
}
- (instancetype)initWithValue:(id)value;
@end


@interface AKAWeakReference<__covariant ObjectType>() {
    __weak ObjectType _value;
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


@interface AKAWeakReferenceProxy<__covariant ObjectType>() {
    __weak ObjectType _aka_weakReference;
}

@end

@implementation AKAWeakReferenceProxy

+ (id)weakReferenceProxyFor:(id)value
{
    AKAWeakReferenceProxy* result = [AKAWeakReferenceProxy alloc];
    result->_aka_weakReference = value;
    return result;
}

+ (id)weakReferenceProxyFor:(id)value
                                    deallocation:(void(^)())deallocationBlock
{
    AKAWeakReferenceProxy* result = [AKAWeakReferenceProxy weakReferenceProxyFor:value];
    [AKADeallocSentinel observeObjectLifeCycle:value deallocation:deallocationBlock];
    return result;
}

- (Class)class
{
    return [_aka_weakReference class];
}

- (NSString *)description
{
    NSString* className = NSStringFromClass(object_getClass(self));
    NSString* objectDescription = _aka_weakReference;
    if ([objectDescription respondsToSelector:@selector(description)])
    {
        objectDescription = [objectDescription description];
    }
    return [NSString stringWithFormat:@"<%@: %@>", className, objectDescription];
}

- (NSString *)debugDescription
{
    NSString* className = NSStringFromClass(object_getClass(self));
    NSString* objectDescription = _aka_weakReference;
    if ([objectDescription respondsToSelector:@selector(debugDescription)])
    {
        objectDescription = [objectDescription description];
    }
    return [NSString stringWithFormat:@"<%@: %@>", className, objectDescription];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    (void)aSelector;
    return _aka_weakReference;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *methodSignature;

    id strongRef = _aka_weakReference;
    if (strongRef)
    {
        methodSignature = [strongRef methodSignatureForSelector:aSelector];
    }
    else
    {
        const char *types = [[NSString stringWithFormat:@"%s%s", @encode(id), @encode(SEL)] UTF8String];
        methodSignature = [NSMethodSignature signatureWithObjCTypes:types];
    }
    return methodSignature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    [anInvocation invokeWithTarget:_aka_weakReference];
}

@end