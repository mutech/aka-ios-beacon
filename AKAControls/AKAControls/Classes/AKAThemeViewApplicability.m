//
// Created by Michael Utech on 25.03.15.
// Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATheme.h"
#import "AKAThemeViewApplicability.h"

@implementation AKAThemeViewApplicability

- (instancetype)initRequirePresent
{
    self = [super init];
    if (self)
    {
        self.present = YES;
    }
    return self;
}

- (instancetype)initRequireAbsent
{
    self = [super init];
    if (self)
    {
        self.present = YES;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self)
    {
        __block BOOL failed = NO;
        self.present = YES;
        [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([@"type" isEqualToString:key])
            {
                if ([obj isKindOfClass:[NSArray class]])
                {
                    [self setRequiresViewsOfTypeIn:obj];
                }
                else
                {
                    [self setRequiresViewsOfTypeIn:@[obj]];
                }
            }
            else if ([@"notType" isEqualToString:key])
            {
                if ([obj isKindOfClass:[NSArray class]])
                {
                    [self setRequiresViewsOfTypeNotIn:obj];
                }
                else
                {
                    [self setRequiresViewsOfTypeNotIn:@[obj]];
                }
            }
            else
            {
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
    BOOL result = self.present == (view != nil);
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
    if (result && self.invalidTypes)
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

- (void)setRequiresViewsOfTypeIn:(NSArray *)validTypes
{
    self.validTypes = validTypes;
}

- (void)setRequiresViewsOfTypeNotIn:(NSArray *)invalidTypes
{
    self.invalidTypes = invalidTypes;
}

@end