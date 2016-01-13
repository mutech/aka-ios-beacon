//
//  AKADelegateDispatcher.h
//  AKABeacon
//
//  Created by Michael Utech on 11.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Dispatches messages for one or more protocol to one or more delegates (objects implementing these protocols).
 
 For each configured protocol, the dispatcher analyses the delegates and maps each method (-selector) to the first delegate implementing it (in the order in which delegates are specified/added).
 
 The delegate uses this mapping to impersonate the specified protocol implementation and forwards message invokations to mapped targets (delegates).
 
 The dispatcher can be used to override protocol method implementations of a delegate (using a preceeding delegate providing these methods) or to augment a delegate by providing default implementations (using a subsequent delegate).
 
 @note Delegates are referenced weakly. If a delegate is deallocated, the dispatcher will no longer respond to any message formerly mapped to the deallocated delegate, even if the list of delegates used to initialize the dispatcher provided an alternative implementation. This may lead to crashes or otherwise inconsistent behaviour if calls to respondsToSelector: are cached by senders. Consequently, you have to ensure that the delegates used by the dispatcher are kept alive as long as the dispatcher requires their implementations.
 */
@interface AKADelegateDispatcher : NSObject

/**
 Initializes the dispatcher to impersonate the specified protocols using implementations found in the list of specified delegates. For each method specified by any of the protocols, the selector is mapped to the first delegate implementing it (in the order defined by the delegates parameter array).

 @param protocols the set of protocols this dispatcher is supposed to impersonate. The order of protocols is not relevant.
 @param delegates the list of delegates implementing the impersonated protocols. The order of delegates is relevant. For each message specified by a protocol, the first delegate is used as forwarding target.

 @return the initialized dispatcher.
 */
- (instancetype)initWithProtocols:(NSArray<Protocol*>*)protocols
                        delegates:(NSArray*)delegates;

@end
