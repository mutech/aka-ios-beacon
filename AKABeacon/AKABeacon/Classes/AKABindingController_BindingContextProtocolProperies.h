//
//  AKABindingController_BindingContextProtocolProperies.h
//  AKABeacon
//
//  Created by Michael Utech on 25.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import <AKABeacon/AKABeacon.h>

@interface AKABindingController ()

#pragma mark - Data Context

@property(nonatomic, nullable) id dataContext;
@property(nonatomic, nonnull) AKAProperty* dataContextProperty;

@end
