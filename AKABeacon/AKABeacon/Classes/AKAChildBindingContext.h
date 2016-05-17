//
//  AKAChildBindingContext.h
//  AKABeacon
//
//  Created by Michael Utech on 11.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingContextProtocol.h"


@interface AKAChildBindingContext: NSObject<AKABindingContextProtocol>

#pragma mark - Initialization

+ (req_instancetype)          bindingContextWithParent:(nonnull id<AKABindingContextProtocol>)bindingContext
                               dataContextProperty:(req_AKAProperty)dataContextProperty;

+ (req_instancetype)           bindingContextWithParent:(nonnull id<AKABindingContextProtocol>)bindingContext
                                        dataContext:(opt_id)dataContext;

+ (req_instancetype)          bindingContextWithParent:(nonnull id<AKABindingContextProtocol>)bindingContext
                                           keyPath:(opt_NSString)keyPath;

#pragma mark - Properties

@property(nonatomic, weak, readonly, nullable) id                             dataContext;
@property(nonatomic, weak, readonly, nullable) id<AKABindingContextProtocol>  parent;

@end
