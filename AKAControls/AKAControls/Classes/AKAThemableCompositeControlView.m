//
// Created by Michael Utech on 08.09.15.
// Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKACompositeControl.h"
#import "AKAControl_Internal.h"

#import "AKAThemableCompositeControlView.h"
#import "AKAThemableContainerView_Protected.h"

@interface AKAThemableCompositeControlView()

@property(nonatomic) AKAProperty* themeNameProperty;
@property(nonatomic, readonly) AKAMutableControlConfiguration* controlConfiguration;

@end

@implementation AKAThemableCompositeControlView

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        _controlConfiguration = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(aka_controlConfiguration))];
        [self setupDefaultValues];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_controlConfiguration forKey:NSStringFromSelector(@selector(aka_controlConfiguration))];
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
    self.controlConfiguration[kAKAControlNameKey] = controlName;
}

- (NSString *)controlTags
{
    return self.controlConfiguration[kAKAControlTagsKey];
}
- (void)setControlTags:(NSString *)controlTags
{
    self.controlConfiguration[kAKAControlTagsKey] = controlTags;
}

- (NSString *)controlRole
{
    return self.controlConfiguration[kAKAControlRoleKey];
}
- (void)setControlRole:(NSString *)role
{
    self.controlConfiguration[kAKAControlRoleKey] = role;
}

/*
- (void)viewBindingChangedFrom:(AKAObsoleteViewBinding *)oldBinding
                            to:(AKAObsoleteViewBinding *)newBinding
{
    self.themeNameProperty = nil;
    __weak typeof(self) weakSelf = self;
    self.themeNameProperty = [newBinding.delegate themeNamePropertyForView:self
                                                            changeObserver:^(
                                                                             id oldValue,
                                                                             id newValue) {
                                                                [weakSelf setNeedsApplySelectedTheme];
                                                                [weakSelf setNeedsLayout];

                                                                [weakSelf updateConstraintsIfNeeded];
                                                                [weakSelf layoutIfNeeded];
                                                            }];
    [self.themeNameProperty startObservingChanges];
    if (super.themeName.length == 0)
    {
        [self setNeedsApplySelectedTheme];
        [self setNeedsUpdateConstraints];
        [self setNeedsLayout];
    }
}
*/

#pragma mark - Themes

- (NSString *)themeName
{
    NSString* result = super.themeName;
    if (result.length == 0)
    {
        result = self.themeNameProperty.value;
    }
    return result;
}

@end