//
//  AKACompositeControlView.m
//  AKAControls
//
//  Created by Michael Utech on 09.09.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKACompositeControlView.h"

#import "AKAControlConfiguration.h"
#import "AKACompositeControl.h"

@interface AKACompositeControlView()

@property(nonatomic, readonly) AKAMutableControlConfiguration* controlConfiguration;

@end


@implementation AKACompositeControlView

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        //_controlConfiguration = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(aka_controlConfiguration))];
        [self setupDefaultValues];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    //[aCoder encodeObject:_controlConfiguration forKey:NSStringFromSelector(@selector(aka_controlConfiguration))];
}

- (void)setupDefaultValues
{
}

#pragma mark - Configuration

- (AKAControlConfiguration*)aka_controlConfiguration
{
    return self.controlConfiguration;
}

@synthesize controlConfiguration = _controlConfiguration;
- (AKAMutableControlConfiguration*)controlConfiguration
{
    if (_controlConfiguration == nil)
    {
        _controlConfiguration = [AKAMutableControlConfiguration new];
        _controlConfiguration[kAKAControlTypeKey] = [AKACompositeControl class];
    }
    return _controlConfiguration;
}

- (void)aka_setControlConfigurationValue:(id)value forKey:(NSString *)key
{
    AKAMutableControlConfiguration* mutableConfiguration = (AKAMutableControlConfiguration*)self.aka_controlConfiguration;
    if (value == nil)
    {
        [mutableConfiguration removeObjectForKey:key];
    }
    else
    {
        mutableConfiguration[key] = value;
    }
}

#pragma mark - Interface Builder Properties

- (NSString *)controlName
{
    return self.controlConfiguration[kAKAControlNameKey];
}
- (void)setControlName:(NSString *)controlName
{
    [self aka_setControlConfigurationValue:controlName forKey:kAKAControlNameKey];
}

- (NSString *)controlTags
{
    return self.controlConfiguration[kAKAControlTagsKey];
}
- (void)setControlTags:(NSString *)controlTags
{
    [self aka_setControlConfigurationValue:controlTags forKey:kAKAControlTagsKey];
}

- (NSString *)controlRole
{
    return self.controlConfiguration[kAKAControlRoleKey];
}
- (void)setControlRole:(NSString *)role
{
    [self aka_setControlConfigurationValue:role forKey:kAKAControlRoleKey];
}

@end
