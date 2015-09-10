//
//  AKABooleanLabelBinding.m
//  AKAControls
//
//  Created by Michael Utech on 09.09.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKABooleanLabelBinding.h"
#import "AKABooleanLabel.h"
#import "AKABooleanTextConverter.h"
#import "AKAProperty.h"

@implementation AKABooleanLabelBinding

- (AKABooleanLabelBindingConfiguration *)configuration
{
    return (AKABooleanLabelBindingConfiguration*)super.configuration;
}

- (id<AKAControlConverterProtocol>)defaultConverter
{
    return [[AKABooleanTextConverter alloc] initWithTextForYes:self.configuration.textForYes
                                                     textForNo:self.configuration.textForNo
                                              textForUndefined:self.configuration.textForUndefined];
}

- (AKAProperty *)createConverterPropertyWithDataContextProperty:(AKAProperty*)dataContextProperty
{
    AKAProperty* result = [super createConverterPropertyWithDataContextProperty:dataContextProperty];
    if (result != nil)
    {
        __weak AKABooleanLabelBinding* weakSelf = self;
        result = [result propertyComputedBy:^id(id value) {
            return [[AKABooleanTextConverter alloc] initWithBaseConverter:value
                                                               textForYes:weakSelf.configuration.textForYes
                                                                textForNo:weakSelf.configuration.textForNo
                                                         textForUndefined:weakSelf.configuration.textForUndefined];
        }];
    }
    return result;
}

@end

@implementation AKABooleanLabelBindingConfiguration

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.textForYes = [aDecoder decodeObjectForKey:@"textForYes"];
        self.textForNo = [aDecoder decodeObjectForKey:@"textForNo"];
        self.textForUndefined = [aDecoder decodeObjectForKey:@"textForUndefined"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.textForYes forKey:@"textForYes"];
    [aCoder encodeObject:self.textForNo forKey:@"textForNo"];
    [aCoder encodeObject:self.textForUndefined forKey:@"textForUndefined"];
}

- (Class)preferredViewType
{
    return [AKABooleanLabel class];
}

- (Class)preferredBindingType
{
    return [AKABooleanLabelBinding class];
}

@end