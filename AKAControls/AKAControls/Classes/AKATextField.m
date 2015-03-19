//
//  AKATextField.m
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATextField.h"
#import "AKATextFieldControlViewBinding.h"

#import "AKAControl.h"

@interface AKATextField()
@end

@implementation AKATextField

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
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setupDefaultValues];
    }
    return self;
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
    self.controlName = nil;
    self.role = nil;
    self.valueKeyPath = nil;

    self.liveModelUpdates = YES;
    self.KBActivationSequence = YES;
    self.autoActivate = YES;
}

#pragma mark - Control View Protocol

- (Class)preferredBindingType
{
    return [AKATextFieldControlViewBinding class];
}

@end
