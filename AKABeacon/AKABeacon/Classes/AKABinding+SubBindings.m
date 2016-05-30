//
//  AKABinding+SubBindings.m
//  AKABeacon
//
//  Created by Michael Utech on 28.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding+SubBindings.h"
#import "AKABinding_SubBindingsProperties.h"

@implementation AKABinding (SubBindings)

- (void)                                addArrayItemBinding:(AKABinding*)binding
{
    if (self.arrayItemBindings == nil)
    {
        self.arrayItemBindings = [NSMutableArray new];
    }
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
    [self.bindingPropertyBindings addObject:bpBinding];
}

- (void)                           addTargetPropertyBinding:(AKABinding*)bpBinding
{
    // TODO: check conflicting bindingProperty/attributeName declarations (only one attribute allowed for bindingProperty)
    if (self.targetPropertyBindings == nil)
    {
        self.targetPropertyBindings = [NSMutableArray new];
    }
    [self.targetPropertyBindings addObject:bpBinding];
}

@end
