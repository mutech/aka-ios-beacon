//
// Created by Michael Utech on 25.03.15.
// Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATheme.h"
#import "AKAThemeViewApplicability.h"

#import <objc/runtime.h> // needed to check if id is Class

@implementation AKAThemeViewApplicability

- (instancetype)init
{
    {
        self = [super init];
        if (self)
        {
            _requirePresent = NO;
            _requireAbsent = NO;
        }
        return self;
    }
}

- (instancetype)initRequirePresent
{
    self = [self init];
    if (self)
    {
        _requirePresent = YES;
    }
    return self;
}

- (instancetype)initRequireAbsent
{
    self = [self init];
    if (self)
    {
        _requireAbsent = YES;
    }
    return self;
}

- (instancetype)initWithValidTypes:(NSArray *)validTypes invalidTypes:(NSArray *)invalidTypes requirePresent:(BOOL)required
{
    self = [self init];
    if (self)
    {
        _requirePresent = required;
        _validTypes = validTypes;
        _invalidTypes = invalidTypes;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self)
    {
        __block BOOL failed = NO;
        [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([@"type" isEqualToString:key])
            {
                if ([obj isKindOfClass:[NSArray class]])
                {
                    self->_validTypes = obj;
                }
                else if (class_isMetaClass(object_getClass(obj)))
                {
                    self->_validTypes = @[obj];
                }
            }
            else if ([@"notType" isEqualToString:key])
            {
                if ([obj isKindOfClass:[NSArray class]])
                {
                    self->_invalidTypes = obj;
                }
                else if (class_isMetaClass(object_getClass(obj)))
                {
                    self->_invalidTypes = @[obj];
                }
            }
            else if ([@"present" isEqualToString:key])
            {
                if ([obj isKindOfClass:[NSNumber class]])
                {
                    self->_requirePresent = ((NSNumber*)obj).boolValue;
                }
            }
            else if ([@"absent" isEqualToString:key])
            {
                if ([obj isKindOfClass:[NSNumber class]])
                {
                    self->_requireAbsent = ((NSNumber*)obj).boolValue;
                }
            }
            else
            {
                // TODO: error handling
                failed = YES;
                *stop = YES;
            }
        }];
        if (failed)
        {
            self = nil;
        }
    }
    return self;
}

- (instancetype)initWithSpecification:(id)specification
{
    if ([specification isKindOfClass:[NSNumber class]])
    {
        BOOL present = ((NSNumber*)specification).boolValue;
        if (present)
        {
            self = [self initRequirePresent];
        }
        else
        {
            self = [self initRequireAbsent];
        }
    }
    else if ([specification isKindOfClass:[NSDictionary class]])
    {
        self = [self initWithDictionary:(NSDictionary*)specification];
    }
    else
    {
        self = nil;
    }
    return self;
}

- (BOOL)isApplicableToView:(id)view
{
    BOOL result = YES;
    if (self.requirePresent && (view == nil))
    {
        result = NO;
    }
    if (self.requireAbsent && (view != nil))
    {
        result = NO;
    }
    if (result && self.validTypes.count > 0)
    {
        result = NO;
        for (Class type in self.validTypes)
        {
            if ([view isKindOfClass:type])
            {
                result = YES;
                break;
            }
        }
    }
    if (result && self.invalidTypes.count > 0)
    {
        for (Class type in self.invalidTypes)
        {
            if ([view isKindOfClass:type])
            {
                return NO;
            }
        }
    }
    return result;
}

@end