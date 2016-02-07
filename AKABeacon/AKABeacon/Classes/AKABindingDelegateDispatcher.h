//
//  AKABindingDelegateDispatcher.h
//  AKABeacon
//
//  Created by Michael Utech on 06.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingDelegate.h"
#import "AKADelegateDispatcher.h"

#pragma mark - AKABindingDelegateDispatcher Interface
#pragma mark -

/**
 This delegate dispatcher is used by bindings to respond to binding delegate messages from sub bindings
 while at the same time forwarding these delegate messages to the bindings own delegate.
 
 Bindings who wish to do so and implement any binding delegate methods should call their own delegate's
 method (unless the correspondig event should intentionally be hidden from the binding's delegate).
 */
@interface AKABindingDelegateDispatcher : AKADelegateDispatcher<AKABindingDelegate>

- (instancetype)initWithDelegate:(id<AKABindingDelegate>)delegate
              delegateOverwrites:(id<AKABindingDelegate>)delegateOverwrites;

@property(nonatomic, readonly, weak) id<AKABindingDelegate> delegate;

@end


