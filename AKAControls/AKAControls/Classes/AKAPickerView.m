//
//  AKAPickerView.m
//  AKAControls
//
//  Created by Michael Utech on 14.09.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAPickerView.h"

#import "AKAPickerViewBinding.h"

@interface AKAPickerView()

@property(nonatomic, strong) AKAPickerViewBindingConfiguration* bindingConfiguration;

@end

@implementation AKAPickerView

#pragma mark - Initialization

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
        self.bindingConfiguration = [aDecoder decodeObjectForKey:@"bindingConfiguration"];
        [self setupDefaultValues];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.bindingConfiguration forKey:@"bindingConfiguration"];
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
    if (_bindingConfiguration == nil)
    {
        _bindingConfiguration = [self createBindingConfiguration];

        self.controlName = nil;
        self.role = nil;
        self.valueKeyPath = nil;
    }
}

#pragma mark - Configuration

- (AKAPickerViewBindingConfiguration *)bindingConfiguration
{
    if (_bindingConfiguration == nil)
    {
        _bindingConfiguration = [self createBindingConfiguration];
    }
    return _bindingConfiguration;
}

- (AKAPickerViewBindingConfiguration*)createBindingConfiguration
{
    return [AKAPickerViewBindingConfiguration new];
}

#pragma mark - Interface Builder Properties
/// @name Interface Builder Properties

- (NSString *)controlName { return self.bindingConfiguration.controlName; }
- (void)setControlName:(NSString *)controlName { self.bindingConfiguration.controlName = controlName; }

- (NSString *)controlTags { return self.bindingConfiguration.controlTags; }
-(void)setControlTags:(NSString *)controlTags { self.bindingConfiguration.controlTags = controlTags; }

- (NSString *)role { return self.bindingConfiguration.role; }
- (void)setRole:(NSString *)role { self.bindingConfiguration.role = role; }

- (NSString *)valueKeyPath { return self.bindingConfiguration.valueKeyPath; }
- (void)setValueKeyPath:(NSString *)valueKeyPath { self.bindingConfiguration.valueKeyPath = valueKeyPath; }

- (NSString *)converterKeyPath { return self.bindingConfiguration.converterKeyPath; }
- (void)setConverterKeyPath:(NSString *)converterKeyPath { self.bindingConfiguration.converterKeyPath = converterKeyPath; }

- (NSString *)validatorKeyPath { return self.bindingConfiguration.validatorKeyPath; }
- (void)setValidatorKeyPath:(NSString *)validatorKeyPath { self.bindingConfiguration.validatorKeyPath = validatorKeyPath; }

- (BOOL)readOnly { return self.bindingConfiguration.readOnly; }
- (void)setReadOnly:(BOOL)readOnly
{
    self.bindingConfiguration.readOnly = readOnly;
    self.userInteractionEnabled = !readOnly;
}

- (NSString *)pickerValuesKeyPath { return self.bindingConfiguration.pickerValuesKeyPath; }
- (void)setPickerValuesKeyPath:(NSString *)pickerValuesKeyPath { self.bindingConfiguration.pickerValuesKeyPath = pickerValuesKeyPath; }

- (NSString *)titleKeyPath { return self.bindingConfiguration.titleKeyPath; }
- (void)setTitleKeyPath:(NSString *)titleKeyPath { self.bindingConfiguration.titleKeyPath = titleKeyPath; }

- (NSString *)titleConverterKeyPath { return self.bindingConfiguration.titleConverterKeyPath; }
- (void)setTitleConverterKeyPath:(NSString *)titleConverterKeyPath { self.bindingConfiguration.titleConverterKeyPath = titleConverterKeyPath; }

- (NSString *)otherValueTitle { return self.bindingConfiguration.otherValueTitle; }
- (void)setOtherValueTitle:(NSString *)otherValueTitle { self.bindingConfiguration.otherValueTitle = otherValueTitle; }

- (NSString *)undefinedValueTitle { return self.bindingConfiguration.undefinedValueTitle; }
- (void)setUndefinedValueTitle:(NSString *)undefinedValueTitle { self.bindingConfiguration.undefinedValueTitle = undefinedValueTitle; }

@end
