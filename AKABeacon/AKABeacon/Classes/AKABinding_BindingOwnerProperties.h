//
//  AKABinding_SubBindingsProperties.h
//  AKABeacon
//
//  Created by Michael Utech on 29.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding.h"

@interface AKABinding ()

@property(nonatomic, weak, nullable) id<AKABindingOwnerProtocol>    owner;

@property(nonatomic, nullable) NSMutableArray<AKABinding*>*         arrayItemBindings;
@property(nonatomic, nullable) NSMutableArray<AKABinding*>*         targetPropertyBindings;
@property(nonatomic, nullable) NSMutableArray<AKABinding*>*         bindingPropertyBindings;

@end
