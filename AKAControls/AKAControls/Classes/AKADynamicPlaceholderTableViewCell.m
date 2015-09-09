//
//  AKADynamicPlaceholderTableViewCell.m
//  AKAControls
//
//  Created by Michael Utech on 29.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKADynamicPlaceholderTableViewCell.h"
#import "AKADynamicPlaceholderTableViewCellCompositeControl.h"

@interface AKADynamicPlaceholderTableViewCell()

// Convenience property ensuring the right type of binding configuration
@property(nonatomic, readonly) AKADynamicPlaceholderTableViewCellBindingConfiguraton* bindingConfiguration;

@end

@implementation AKADynamicPlaceholderTableViewCell

#pragma mark - Binding Configuration

- (AKADynamicPlaceholderTableViewCellBindingConfiguraton *)bindingConfiguration
{
    id result = super.bindingConfiguration;
    NSAssert(result == nil || [result isKindOfClass:[AKADynamicPlaceholderTableViewCellBindingConfiguraton class]],
             @"Expected binding configuration of type AKADynamicPlaceholderTableViewCellBindingConfiguraton");
    return result;
}

- (AKATableViewCellBindingConfiguration *)newBindingConfiguration
{
    return [[AKADynamicPlaceholderTableViewCellBindingConfiguraton alloc] init];
}

#pragma mark - Interface Builder Properties

- (NSString *)dataSourceKeyPath { return self.bindingConfiguration.dataSourceKeyPath; }
- (void)setDataSourceKeyPath:(NSString *)dataSourceKeyPath { self.bindingConfiguration.dataSourceKeyPath = dataSourceKeyPath; }

- (NSString *)delegateKeyPath { return self.bindingConfiguration.delegateKeyPath; }
- (void)setDelegateKeyPath:(NSString *)delegateKeyPath { self.bindingConfiguration.delegateKeyPath = delegateKeyPath; }

- (NSUInteger)sectionIndex { return self.bindingConfiguration.sectionIndex; }
- (void)setSectionIndex:(NSUInteger)sectionIndex { self.bindingConfiguration.sectionIndex = sectionIndex; }

- (NSUInteger)rowIndex { return self.bindingConfiguration.rowIndex; }
- (void)setRowIndex:(NSUInteger)rowIndex { self.bindingConfiguration.rowIndex = rowIndex; }

- (NSUInteger)numberOfRows { return self.bindingConfiguration.numberOfRows; }
- (void)setNumberOfRows:(NSUInteger)numberOfRows { self.bindingConfiguration.numberOfRows = numberOfRows; }

#pragma mark - Content Rendering

- (void)renderItem:(id)item
{

}

@end

@implementation AKADynamicPlaceholderTableViewCellBinding
@end

@implementation AKADynamicPlaceholderTableViewCellBindingConfiguraton

- (Class)preferredViewType
{
    return [AKADynamicPlaceholderTableViewCell class];
}

- (Class)preferredBindingType
{
    return [AKADynamicPlaceholderTableViewCellBinding class];
}

- (Class)preferredControlType
{
    return [AKADynamicPlaceholderTableViewCellCompositeControl class];
}


- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder])
    {
        self.dataSourceKeyPath = [decoder decodeObjectForKey:@"dataSourceKeyPath"];
        self.delegateKeyPath = [decoder decodeObjectForKey:@"delegateKeyPath"];
        self.sectionIndex = ((NSNumber*)[decoder decodeObjectForKey:@"sectionIndex"]).unsignedIntegerValue;
        self.rowIndex = ((NSNumber*)[decoder decodeObjectForKey:@"rowIndex"]).unsignedIntegerValue;
        self.numberOfRows = ((NSNumber*)[decoder decodeObjectForKey:@"numberOfRows"]).unsignedIntegerValue;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.dataSourceKeyPath forKey:@"dataSourceKeyPath"];
    [coder encodeObject:self.delegateKeyPath forKey:@"delegateKeyPath"];
    [coder encodeObject:@(self.sectionIndex) forKey:@"sectionIndex"];
    [coder encodeObject:@(self.rowIndex) forKey:@"rowIndex"];
    [coder encodeObject:@(self.numberOfRows) forKey:@"numberOfRows"];
}

@end