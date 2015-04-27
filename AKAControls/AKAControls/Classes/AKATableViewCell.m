//
//  AKATableViewCell.m
//  AKAControls
//
//  Created by Michael Utech on 25.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATableViewCell.h"
#import "AKATableViewCellCompositeControl.h"

@implementation AKATableViewCell

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

@synthesize bindingConfiguration = _bindingConfiguration;

- (AKAViewBindingConfiguration*)bindingConfiguration
{
    if (_bindingConfiguration == nil)
    {
        _bindingConfiguration = AKATableViewCellBindingConfiguration.new;
    }
    return _bindingConfiguration;
}

#pragma mark - Interface Builder Properties
/// @name Interface Builder Properties

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
-(void)setControlTags:(NSString *)controlTags
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

@end

@implementation AKATableViewCellBindingConfiguration

- (Class)preferredViewType
{
    return [AKATableViewCell class];
}

- (Class)preferredBindingType
{
    return [AKATableViewCellBinding class];
}

- (Class)preferredControlType
{
    return [AKATableViewCellCompositeControl class];
}

@end

@implementation AKATableViewCellBinding

@end