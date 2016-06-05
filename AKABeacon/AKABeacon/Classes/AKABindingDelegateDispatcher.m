//
//  AKABindingDelegateDispatcher.m
//  AKABeacon
//
//  Created by Michael Utech on 06.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingDelegateDispatcher.h"
#import "AKAArrayPropertyBinding.h"

#pragma mark - AKABindingDelegateDispatcher Implementation
#pragma mark -

// Ignore warning about missing protocol implementations, these are provided dynamically
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"

@implementation AKABindingDelegateDispatcher

- (instancetype)initWithDelegate:(id<AKABindingDelegate>)delegate
              delegateOverwrites:(id<AKABindingDelegate>)delegateOverwrites
{
    static NSArray<Protocol*>* protocols;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        protocols = @[ @protocol(AKABindingDelegate), @protocol(AKAArrayPropertyBindingDelegate) ];
    });


    NSArray* delegates = nil;

    if (delegate && delegateOverwrites)
    {
        delegates = @[ delegateOverwrites, delegate ];
    }
    else if (delegate)
    {
        delegates = @[ delegate ];
    }
    else if (delegateOverwrites)
    {
        delegates = @[ delegateOverwrites ];
    }


    if (self = [super initWithProtocols:protocols
                              delegates:delegates])
    {
        _delegate = delegate;
    }

    return self;
}

@end

#pragma clang diagnostic pop

