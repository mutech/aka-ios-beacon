//
//  AKATableViewCell.m
//  AKABeacon
//
//  Created by Michael Utech on 25.04.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKATableViewCell.h"
#import "AKATableViewCellCompositeControl.h"
#import "AKAControlConfiguration.h"

@interface AKATableViewCell()

@property(nonatomic, readonly) AKAMutableControlConfiguration* controlConfiguration;

@end

@implementation AKATableViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        _controlConfiguration = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(aka_controlConfiguration))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    id controlConfiguration = self.controlConfiguration;
    if (controlConfiguration)
    {
        //[aCoder encodeObject:self.controlConfiguration forKey:NSStringFromSelector(@selector(aka_controlConfiguration))];
    }
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Binding Configuration

- (NSString *)controlName
{
    return self.aka_controlConfiguration[kAKAControlNameKey];
}
- (void)setControlName:(NSString *)controlName
{
    [self aka_setControlConfigurationValue:controlName forKey:kAKAControlNameKey];
}

- (NSString *)controlRole
{
    return self.aka_controlConfiguration[kAKAControlRoleKey];
}
- (void)setControlRole:(NSString *)controlRole
{
    [self aka_setControlConfigurationValue:controlRole forKey:kAKAControlRoleKey];
}

- (NSString *)controlTags
{
    return self.aka_controlConfiguration[kAKAControlTagsKey];
}
- (void)setControlTags:(NSString *)controlTags
{
    [self aka_setControlConfigurationValue:controlTags forKey:kAKAControlTagsKey];
}

@synthesize controlConfiguration = _controlConfiguration;

- (AKAMutableControlConfiguration *)controlConfiguration
{
    if (_controlConfiguration == nil)
    {
        _controlConfiguration = [AKAMutableControlConfiguration new];
        _controlConfiguration[kAKAControlTypeKey] = [AKATableViewCellCompositeControl class];
    }
    return _controlConfiguration;
}

- (AKAControlConfiguration *)aka_controlConfiguration
{
    return self.controlConfiguration;
}

- (void)aka_setControlConfigurationValue:(id)value forKey:(NSString *)key
{
    if (value == nil)
    {
        [self.controlConfiguration removeObjectForKey:key];
    }
    else
    {
        self.controlConfiguration[key] = value;
    }
}

@end
