//
//  AKATextField.m
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATextField_Protected.h"
#import "AKATextFieldBinding.h"

#import "AKAControl.h"

@implementation AKATextField

@synthesize textFieldBindingConfiguration = _textFieldBindingConfiguration;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setupDefaultValues];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        _textFieldBindingConfiguration = [aDecoder decodeObjectForKey:@"bindingConfiguration"];
        [self setupDefaultValues];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.textFieldBindingConfiguration forKey:@"bindingConfiguration"];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupDefaultValues];
    }
    return self;
}

- (void)setupDefaultValues
{
    if (_textFieldBindingConfiguration == nil)
    {
        _textFieldBindingConfiguration = [self createTextFieldBindingConfiguration];

        self.controlName = nil;
        self.role = nil;
        self.valueKeyPath = nil;

        self.liveModelUpdates = YES;
        self.KBActivationSequence = YES;
        self.autoActivate = YES;
    }
}

#pragma mark - Control View Protocol

- (AKATextFieldBindingConfiguration*)createTextFieldBindingConfiguration
{
    return AKATextFieldBindingConfiguration.new;
}

- (AKAViewBindingConfiguration*)bindingConfiguration
{
    return self.textFieldBindingConfiguration;
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
    self.userInteractionEnabled = !readOnly;
}

- (BOOL)liveModelUpdates
{
    return self.textFieldBindingConfiguration.liveModelUpdates;
}
- (void)setLiveModelUpdates:(BOOL)liveModelUpdates
{
    self.textFieldBindingConfiguration.liveModelUpdates = liveModelUpdates;
}

- (BOOL)autoActivate
{
    return self.textFieldBindingConfiguration.autoActivate;
}
- (void)setAutoActivate:(BOOL)autoActivate
{
    self.textFieldBindingConfiguration.autoActivate = autoActivate;
}

- (BOOL)KBActivationSequence
{
    return self.textFieldBindingConfiguration.KBActivationSequence;
}
- (void)setKBActivationSequence:(BOOL)KBActivationSequence
{
    self.textFieldBindingConfiguration.KBActivationSequence = KBActivationSequence;
}

@end
