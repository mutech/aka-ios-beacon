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

@interface AKATextField() {
    AKATextFieldControlViewBinding* _controlBinding;
    NSString* _valueKeyPath;
}
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
    self.valueKeyPath = nil;
    self.liveModelUpdates = YES;
    self.KBActivationSequence = YES;
    self.autoActivate = YES;
}

- (AKAControlViewBinding *)bindToControl:(AKAControl *)control
{
    AKATextFieldControlViewBinding* result;
    AKAControlViewBinding* controlViewBinding = self.controlBinding;

    if (controlViewBinding != nil)
    {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"Invalid attempt to bind %@ to %@: Already bound: %@", self, control, controlViewBinding]
                                     userInfo:nil];
    }
    _controlBinding = result =
        [[AKATextFieldControlViewBinding alloc] initWithControl:control
                                                           view:self];
    return result;
}

- (AKAControl*)createControlWithDataContext:(id)dataContext
{
    AKAControl* result = [AKAControl controlWithDataContext:dataContext keyPath:self.valueKeyPath];
    result.viewBinding = [self bindToControl:result];
    return result;
}

- (AKAControl*)createControlWithOwner:(AKACompositeControl *)owner
{
    AKAControl* result = [AKAControl controlWithOwner:owner keyPath:self.valueKeyPath];
    result.viewBinding = [self bindToControl:result];
    return result;
}

- (AKAControlViewBinding *)controlBinding
{
    return _controlBinding;
}

@end
