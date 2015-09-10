//
//  AKATextLabel.m
//  AKACommons
//
//  Created by Michael Utech on 14.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATextLabel.h"
#import "AKATextLabelBinding.h"
#import "AKAControl.h"

@implementation AKATextLabel

#pragma mark - Initialization
#pragma mark -

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        _bindingConfiguration = [aDecoder decodeObjectForKey:@"bindingConfiguration"];
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

@synthesize bindingConfiguration = _bindingConfiguration;
- (AKATextLabelBindingConfiguration*)bindingConfiguration
{
    if (_bindingConfiguration == nil)
    {
        _bindingConfiguration = [self createBindingConfiguration];
    }
    return _bindingConfiguration;
}

- (AKATextLabelBindingConfiguration*)createBindingConfiguration
{
    return AKATextLabelBindingConfiguration.new;
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

- (BOOL)readOnly
{
    return self.bindingConfiguration.readOnly;
}
- (void)setReadOnly:(BOOL)readOnly
{
    self.bindingConfiguration.readOnly = readOnly;
}

@end
