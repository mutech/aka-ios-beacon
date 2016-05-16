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

+ (instancetype)          bindingContextWithParent:(id<AKABindingContextProtocol>)bindingContext
                               dataContextProperty:(req_AKAProperty)dataContextProperty;

+ (instancetype)           bindingContextWithParent:(id<AKABindingContextProtocol>)bindingContext
                                        dataContext:(id)dataContext;

+ (instancetype)          bindingContextWithParent:(id<AKABindingContextProtocol>)bindingContext
                                           keyPath:(NSString*)keyPath;

#pragma mark - Properties

@property(nonatomic, weak, readonly) id                             dataContext;
@property(nonatomic, weak, readonly) id<AKABindingContextProtocol>  parent;

@end
