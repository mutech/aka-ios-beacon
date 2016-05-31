//
//  AKABinding+BindingOwner.m
//  AKABeacon
//
//  Created by Michael Utech on 28.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding+BindingOwner.h"
#import "AKABinding_BindingOwnerProperties.h"

@implementation AKABinding (BindingOwner)

- (void)                                addArrayItemBinding:(AKABinding*)binding
{
    if (self.arrayItemBindings == nil)
    {
        self.arrayItemBindings = [NSMutableArray new];
    }
    binding.owner = self;
    [self.arrayItemBindings addObject:binding];

    if (binding != (id)[NSNull null])
    {
        [self addTargetPropertyBinding:binding];
    }
}

- (void)                            removeArrayItemBindings
{
    for (AKABinding* binding in self.arrayItemBindings)
    {
        [binding stopObservingChanges];
        [self.targetPropertyBindings removeObject:binding];
        binding.owner = nil;
    }
    self.arrayItemBindings = nil;
}

- (void)                          addBindingPropertyBinding:(AKABinding*)bpBinding
{
    // TODO: check conflicting bindingProperty/attributeName declarations (only one attribute allowed for bindingProperty)
    if (self.bindingPropertyBindings == nil)
    {
        self.bindingPropertyBindings = [NSMutableArray new];
    }
    bpBinding.owner = self;
    [self.bindingPropertyBindings addObject:bpBinding];
}

- (void)                           addTargetPropertyBinding:(AKABinding*)tpBinding
{
    // TODO: check conflicting bindingProperty/attributeName declarations (only one attribute allowed for bindingProperty)
    if (self.targetPropertyBindings == nil)
    {
        self.targetPropertyBindings = [NSMutableArray new];
    }
    tpBinding.owner = self;
    [self.targetPropertyBindings addObject:tpBinding];
}

@end
