//
//  AKADynamicPlaceholderTableViewCell.m
//  AKAControls
//
//  Created by Michael Utech on 29.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKADynamicPlaceholderTableViewCell.h"
#import "AKADynamicPlaceholderTableViewCellCompositeControl.h"


@implementation AKADynamicPlaceholderTableViewCell

#pragma mark - Interface Builder Properties

#pragma mark - Content Rendering

- (void)renderItem:(id)item
{
}

@end

#import "AKABindingProvider.h"

@interface AKABindingProvider_AKADynamicPlaceholderTableViewCell_dataSourceBinding: AKABindingProvider


@end

@implementation AKABindingProvider_AKADynamicPlaceholderTableViewCell_dataSourceBinding

+ (instancetype)sharedInstance
{
    static AKABindingProvider_AKADynamicPlaceholderTableViewCell_dataSourceBinding* result = nil;
    static dispatch_once_t onceToken;

    // TODO: write specification
    dispatch_once(&onceToken, ^{
        result = [AKABindingProvider_AKADynamicPlaceholderTableViewCell_dataSourceBinding new];
    });

    return result;
}

- (AKABindingSpecification*)specification
{
    static AKABindingSpecification* result;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result = [[AKABindingSpecification alloc] initWithDictionary:
                  @{
                  }];
    });

    return result;
}

@end

@implementation AKABinding_AKADynamicPlaceholderTableViewCell_dataSourceBinding


@end
