//
//  AKATableViewCell.m
//  AKAControls
//
//  Created by Michael Utech on 25.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
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
    [aCoder encodeObject:self.controlConfiguration forKey:NSStringFromSelector(@selector(aka_controlConfiguration))];
}


- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Binding Configuration

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
