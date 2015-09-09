//
// Created by Michael Utech on 08.09.15.
// Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKACompositeControl.h"

#import "AKAThemableCompositeControlView.h"
#import "AKAThemableContainerView_Protected.h"

@interface AKAThemableCompositeControlView()

@property(nonatomic) AKAProperty* themeNameProperty;

@end

@implementation AKAThemableCompositeControlView

#pragma mark - Initialization
#pragma mark -

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        _bindingConfiguration = [aDecoder decodeObjectForKey:@"bindingConfiguration"];
        [self setupDefaultValues];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.bindingConfiguration forKey:@"bindingConfiguration"];
}

#pragma mark - Configuration
#pragma mark -

#pragma mark - Binding Configuration

@synthesize bindingConfiguration = _bindingConfiguration;
- (AKAViewBindingConfiguration *)bindingConfiguration
{
    if (_bindingConfiguration == nil)
    {
        _bindingConfiguration = [self createBindingConfiguration];
    }
    return _bindingConfiguration;
}

- (AKACompositeViewBindingConfiguration*)createBindingConfiguration
{
    return AKACompositeViewBindingConfiguration.new;
}

- (void)viewBindingChangedFrom:(AKAViewBinding *)oldBinding
                            to:(AKAViewBinding *)newBinding
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

#pragma mark - Interface Builder Properties
#pragma mark -

- (NSString *)controlName
{
    return self.bindingConfiguration.controlName;
}
- (void)setControlName:(NSString *)controlName
{
    self.bindingConfiguration.controlName = controlName;
}

- (NSString *)controlTags
{
    return self.bindingConfiguration.controlTags;
}
- (void)setControlTags:(NSString *)controlTags
{
    self.bindingConfiguration.controlTags = controlTags;
}

- (NSString *)role
{
    return self.bindingConfiguration.role;
}
- (void)setRole:(NSString *)role
{
    self.bindingConfiguration.role = role;
}

- (NSString *)valueKeyPath
{
    return self.bindingConfiguration.valueKeyPath;
}
- (void)setValueKeyPath:(NSString *)valueKeyPath
{
    self.bindingConfiguration.valueKeyPath = valueKeyPath;
}

- (NSString *)converterKeyPath
{
    return self.bindingConfiguration.converterKeyPath;
}
- (void)setConverterKeyPath:(NSString *)converterKeyPath
{
    self.bindingConfiguration.converterKeyPath = converterKeyPath;
}

- (NSString *)validatorKeyPath
{
    return self.bindingConfiguration.validatorKeyPath;
}
- (void)setValidatorKeyPath:(NSString *)validatorKeyPath
{
    self.bindingConfiguration.validatorKeyPath = validatorKeyPath;
}

- (BOOL)readOnly
{
    return self.bindingConfiguration.readOnly;
}
- (void)setReadOnly:(BOOL)readOnly
{
    self.bindingConfiguration.readOnly = readOnly;
}

@end