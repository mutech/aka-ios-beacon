//
//  AKADelegateDispatcher.m
//  AKABeacon
//
//  Created by Michael Utech on 11.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.AKALog;
@import AKACommons.AKANullability;

#import "AKADelegateDispatcher.h"
#import "AKAProtocolInfo.h"

@interface AKADelegateDispatcher()


@property(nonatomic, readonly) NSArray<Protocol*>* protocols;

@property(nonatomic, readonly) NSMutableSet<Protocol*>* impersonatedProtocols;

@property(nonatomic, readonly) NSMapTable<NSString* , id>* targetsBySelectorName;

@end

@implementation AKADelegateDispatcher

- (instancetype)initWithProtocols:(NSArray<Protocol*>*)protocols
{
    if (self = [self init])
    {
        _protocols = protocols;
    }
    return self;
}

- (instancetype)initWithProtocols:(NSArray<Protocol*>*)protocols
                        delegates:(NSArray*)delegates
{
    if (self = [self initWithProtocols:protocols])
    {
        _targetsBySelectorName = [NSMapTable strongToWeakObjectsMapTable];
        [self addMappingsForDelegates:delegates];
    }
    return self;
}

- (instancetype)initWithProtocols:(NSArray<Protocol*>*)protocols
                  primaryDelegate:(id)delegate
                 fallbackDelegate:(id)fallbackDelegate
{
    return [self initWithProtocols:protocols
                         delegates:@[delegate, fallbackDelegate]];
}

- (void)addMappingFromSelector:(req_NSString)selectorName
                    toDelegate:(req_id)delegate
{
    [self->_targetsBySelectorName setObject:delegate forKey:selectorName];
}

- (void)addMappingsForDelegates:(NSArray*)delegates
{
    NSMutableSet<Protocol*>* processedProtocols = [NSMutableSet setWithArray:@[@protocol(NSObject),
                                                                               @protocol(NSCopying)]];

    for (Protocol* leafProtocol in self.protocols)
    {
        AKAProtocolInfo* leafProtocolInfo = [[AKAProtocolInfo alloc] initWithProtocol:leafProtocol];
        [leafProtocolInfo enumerateSelfAndProtocolInfosRecursivelyWithBlock:
         ^(AKAProtocolInfo *protocolInfo)
         {
             __block BOOL noConformingDelegate = YES;

             [protocolInfo enumerateInstanceMethodDescriptionsWithBlock:
              ^(SEL selector, char *types, BOOL isRequired)
              {
                  (void)types;
                  NSString* selectorName = NSStringFromSelector(selector);
                  if (![self->_targetsBySelectorName objectForKey:selectorName])
                  {
                      BOOL implementedByDelegates = NO;
                      for (id delegate in delegates)
                      {
                          if (noConformingDelegate)
                          {
                              noConformingDelegate = ![delegate conformsToProtocol:protocolInfo.protocol];
                          }
                          if ([delegate respondsToSelector:selector])
                          {
                              implementedByDelegates = YES;
                              [self addMappingFromSelector:selectorName
                                                toDelegate:delegate];
                              break;
                          }
                      }
                      if (isRequired && !implementedByDelegates)
                      {
                          AKALogError(@"None of the delegates {%@} respond to required selector %@ specified in protocol %@, this violates the protocol's contract.",
                                      [delegates componentsJoinedByString:@", "],
                                      NSStringFromSelector(selector),
                                      NSStringFromProtocol(protocolInfo.protocol));
                      }
                  }
              }];

             if (noConformingDelegate)
             {
                 AKALogWarn(@"None of the delegates {%@} conform to protocol %@, however the dispatcher %@ is configured to conform to it. This will probably mislead modules using the dispatcher as implementation for this protocol.", [delegates componentsJoinedByString:@", "], NSStringFromProtocol(protocolInfo.protocol), self);
             }
             [processedProtocols addObject:protocolInfo.protocol];
         }
                                                                    exclude:processedProtocols];
    }
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    BOOL result = [super conformsToProtocol:aProtocol];
    if (!result)
    {
        result = [self.protocols containsObject:aProtocol];
    }
    return result;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    NSString* selectorName = NSStringFromSelector(aSelector);
    id target = [self.targetsBySelectorName objectForKey:selectorName];

    BOOL result = target != nil;
    if (!result)
    {
        result = [super respondsToSelector:aSelector];
    }

    return result;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    NSString* selectorName = NSStringFromSelector(aSelector);
    id result = [self.targetsBySelectorName objectForKey:selectorName];
    if (result == nil)
    {
        result = [super forwardingTargetForSelector:aSelector];
    }
    return result;
}


@end
