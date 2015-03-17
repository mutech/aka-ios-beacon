//
//  AKAControl_Protected.h
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAControl.h"

@interface AKAControl (Protected)

@property(nonatomic, strong) AKAProperty* modelValueProperty;
@property(nonatomic, readonly) AKAProperty* viewValueProperty;

- (instancetype)initWithOwner:(AKACompositeControl*)owner keyPath:(NSString*)keyPath;
- (instancetype)initWithDataContext:(id)dataContext keyPath:(NSString*)keyPath;

@end
