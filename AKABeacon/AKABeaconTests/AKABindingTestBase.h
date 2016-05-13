//
//  AKABindingTestBase.h
//  AKABeacon
//
//  Created by Michael Utech on 12.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AKABindingContextProtocol.h"

@interface AKABindingTestBase : XCTestCase <AKABindingContextProtocol>

@property(nonatomic, readonly, nonnull) NSMutableDictionary<NSString*, id>* dataContext;

- (nonnull id<AKABindingContextProtocol>)bindingContextForDataContextAtKeyPath:(req_NSString)keyPath;

- (nonnull id<AKABindingContextProtocol>)bindingContextForNewDataContext:(opt_id)dataContext
                                                               atKeyPath:(req_NSString)keyPath;

@end

