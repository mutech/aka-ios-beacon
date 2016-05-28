//
//  AKABindingController+BindingContextProtocol.h
//  AKABeacon
//
//  Created by Michael Utech on 25.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingController.h"
#import "AKABindingContextProtocol.h"


#pragma mark - AKABindingController(BindingContextProtocol) - Interface
#pragma mark -

@interface AKABindingController(BindingContextProtocol) <AKABindingContextProtocol>

/**
 Property refering to dataContext used as dependency root for properties provided to bindings.
 */
@property(nonatomic, readonly) AKAProperty* dataContextProperty;

@end

