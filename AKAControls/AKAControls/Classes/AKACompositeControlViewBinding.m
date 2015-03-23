//
//  AKACompositeControlViewBinding.m
//  AKAControls
//
//  Created by Michael Utech on 20.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKACompositeControlViewBinding.h"
#import "AKAControlViewBinding_Protected.h"
#import "AKACompositeControl.h"

@implementation AKACompositeControlViewBinding

+ (Class)resolveBindingType:(Class)preferredBindingType
{
    NSParameterAssert(preferredBindingType == nil || [preferredBindingType isSubclassOfClass:[AKAControlViewBinding class]]);

    Class result = preferredBindingType;
    if (preferredBindingType == nil)
    {
        result = [AKAControlViewBinding class];
    }
    return result;
}

+ (Class)resolveControlTypeForView:(id)view
{
    return [AKACompositeControl class];
}

#pragma mark - View Value Property

- (AKAProperty *)createViewValueProperty
{
    // Composite controls do not have their own view value
    return nil;
}

#pragma mark - Control


@end
