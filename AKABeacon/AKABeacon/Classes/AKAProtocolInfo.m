//
//  AKAProtocolInfo.m
//  AKABeacon
//
//  Created by Michael Utech on 11.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAProtocolInfo.h"

@implementation AKAProtocolInfo

- (instancetype)initWithProtocol:(Protocol*)protocol
{
    if (self = [super init])
    {
        _protocol = protocol;
    }
    return self;
}

#pragma mark - Enumerating Protocol Message Descriptions

- (void)                       enumerateMethodDescriptionsWithBlock:(void (^)(SEL selector, char* types))block
                                                           required:(BOOL)required
                                                           instance:(BOOL)instance
{
    unsigned int count = 0;
    struct objc_method_description* methodDescriptions =
    protocol_copyMethodDescriptionList(self.protocol, required, instance, &count);

    for (int i=0; i < count; ++i)
    {
        struct objc_method_description methodDescription = methodDescriptions[i];
        block(methodDescription.name, methodDescription.types);
    }

    free(methodDescriptions);
}

- (void)            enumerateMethodDescriptionsRecursivelyWithBlock:(void (^)(Protocol* protocol, SEL selector, char* types))block
                                                           required:(BOOL)required
                                                           instance:(BOOL)instance
{
    [self enumerateMethodDescriptionsWithBlock:^(SEL selector, char *types) { block(self.protocol, selector, types); }
                                      required:required
                                      instance:instance];
    [self enumerateProtocolInfosRecursivelyWithBlock:^(AKAProtocolInfo *protocolInfo) {
        [protocolInfo enumerateMethodDescriptionsWithBlock:
         ^(SEL selector, char *types)
        {
            block(protocolInfo.protocol, selector, types);
        }
                                                  required:required
                                                  instance:instance];
    }];
}

- (void)                       enumerateMethodDescriptionsWithBlock:(void(^)(SEL selector, char* types, BOOL isRequired, BOOL isInstanceMethod))block
{
    [self enumerateMethodDescriptionsWithBlock:^(SEL selector, char* types) { block(selector, types, YES, YES); }
                                      required:YES
                                      instance:YES];
    [self enumerateMethodDescriptionsWithBlock:^(SEL selector, char* types) { block(selector, types, NO, YES); }
                                      required:NO
                                      instance:YES];
    [self enumerateMethodDescriptionsWithBlock:^(SEL selector, char* types) { block(selector, types, YES, NO); }
                                      required:YES
                                      instance:NO];
    [self enumerateMethodDescriptionsWithBlock:^(SEL selector, char* types) { block(selector, types, NO, NO); }
                                      required:NO
                                      instance:NO];
}

- (void)            enumerateMethodDescriptionsRecursivelyWithBlock:(void(^)(Protocol* protocol, SEL selector, char* types, BOOL isRequired, BOOL isInstanceMethod))block
{
    [self enumerateMethodDescriptionsWithBlock:^(SEL selector, char *types, BOOL isRequired, BOOL isInstanceMethod) {
        block(self.protocol, selector, types, isRequired, isInstanceMethod);
    }];
    [self enumerateProtocolInfosRecursivelyWithBlock:^(AKAProtocolInfo *protocolInfo) {
        [protocolInfo enumerateMethodDescriptionsWithBlock:^(SEL selector, char *types, BOOL isRequired, BOOL isInstanceMethod) {
            block(protocolInfo.protocol, selector, types, isRequired, isInstanceMethod);
        }];
    }];
}

- (void)               enumerateInstanceMethodDescriptionsWithBlock:(void(^)(SEL selector, char* types, BOOL isRequired))block
{
    [self enumerateMethodDescriptionsWithBlock:^(SEL selector, char* types) { block(selector, types, YES); }
                                      required:YES
                                      instance:YES];
    [self enumerateMethodDescriptionsWithBlock:^(SEL selector, char* types) { block(selector, types, NO); }
                                      required:NO
                                      instance:YES];
}

- (void)    enumerateInstanceMethodDescriptionsRecursivelyWithBlock:(void(^)(Protocol* protocol, SEL selector, char* types, BOOL isRequired))block
{
    [self enumerateInstanceMethodDescriptionsWithBlock:^(SEL selector, char *types, BOOL isRequired) {
        block(self.protocol, selector, types, isRequired);
    }];
    [self enumerateProtocolInfosRecursivelyWithBlock:^(AKAProtocolInfo* protocolInfo) {
        [protocolInfo enumerateInstanceMethodDescriptionsWithBlock:^(SEL selector, char *types, BOOL isRequired) {
            block(protocolInfo.protocol, selector, types, isRequired);
        }];
    }];
}

- (void)                 enumerateStaticMethodDescriptionsWithBlock:(void(^)(SEL selector, char* types, BOOL isRequired))block
{
    [self enumerateMethodDescriptionsWithBlock:^(SEL selector, char* types) { block(selector, types, YES); }
                                      required:YES
                                      instance:NO];
    [self enumerateMethodDescriptionsWithBlock:^(SEL selector, char* types) { block(selector, types, NO); }
                                      required:NO
                                      instance:NO];
}

- (void)     enumerateStaticMethodDescriptionsRecursivelyWithBlock:(void(^)(Protocol* protocol, SEL selector, char* types, BOOL isRequired))block
{
    [self enumerateStaticMethodDescriptionsWithBlock:^(SEL selector, char *types, BOOL isRequired) {
        block(self.protocol, selector, types, isRequired);
    }];
    [self enumerateProtocolInfosRecursivelyWithBlock:^(AKAProtocolInfo *protocolInfo) {
        [protocolInfo enumerateStaticMethodDescriptionsWithBlock:^(SEL selector, char *types, BOOL isRequired) {
            block(protocolInfo.protocol, selector, types, isRequired);
        }];
    }];
}

- (void)              enumerateOptionalMethodDescriptionsWithBlock:(void(^)(SEL selector, char* types, BOOL isInstanceMethod))block
{
    [self enumerateMethodDescriptionsWithBlock:^(SEL selector, char* types) { block(selector, types, YES); }
                                      required:NO
                                      instance:YES];
    [self enumerateMethodDescriptionsWithBlock:^(SEL selector, char* types) { block(selector, types, NO); }
                                      required:NO
                                      instance:NO];
}

- (void)   enumerateOptionalMethodDescriptionsRecursivelyWithBlock:(void(^)(Protocol* protocol, SEL selector, char* types, BOOL isInstanceMethod))block
{
    [self enumerateOptionalMethodDescriptionsWithBlock:^(SEL selector, char *types, BOOL isInstanceMethod) {
        block(self.protocol, selector, types, isInstanceMethod);
    }];
    [self enumerateProtocolInfosRecursivelyWithBlock:^(AKAProtocolInfo *protocolInfo) {
        [protocolInfo enumerateOptionalMethodDescriptionsWithBlock:^(SEL selector, char *types, BOOL isInstanceMethod) {
            block(protocolInfo.protocol, selector, types, isInstanceMethod);
        }];
    }];
}

- (void)              enumerateRequiredMethodDescriptionsWithBlock:(void(^)(SEL selector, char* types, BOOL isInstanceMethod))block
{
    [self enumerateMethodDescriptionsWithBlock:^(SEL selector, char* types) { block(selector, types, YES); }
                                      required:YES
                                      instance:YES];
    [self enumerateMethodDescriptionsWithBlock:^(SEL selector, char* types) { block(selector, types, NO); }
                                      required:YES
                                      instance:NO];
}

- (void)   enumerateRequiredMethodDescriptionsRecursivelyWithBlock:(void(^)(Protocol* protocol, SEL selector, char* types, BOOL isInstanceMethod))block
{
    [self enumerateRequiredMethodDescriptionsWithBlock:^(SEL selector, char *types, BOOL isInstanceMethod) {
        block(self.protocol, selector, types, isInstanceMethod);
    }];
    [self enumerateProtocolInfosRecursivelyWithBlock:^(AKAProtocolInfo *protocolInfo) {
        [protocolInfo enumerateRequiredMethodDescriptionsWithBlock:^(SEL selector, char *types, BOOL isInstanceMethod) {
            block(protocolInfo.protocol, selector, types, isInstanceMethod);
        }];
    }];
}

#pragma mark - Enumerating Incorporated Protocols

- (void)                         enumerateProtocolsWithBlock:(void (^)(Protocol *))block
{
    unsigned int count = 0;
    __unsafe_unretained Protocol** protocols = protocol_copyProtocolList(self.protocol, &count);

    for (unsigned int i=0; i < count; ++i)
    {
        block(protocols[i]);
    }
    free(protocols);
}

- (void)             enumerateSelfAndProtocolInfosRecursivelyWithBlock:(void(^)(AKAProtocolInfo* protocol))block
{
    [self enumerateProtocolInfosRecursivelyWithBlock:block exclude:nil];
}

- (void)             enumerateSelfAndProtocolInfosRecursivelyWithBlock:(void(^)(AKAProtocolInfo* protocol))block
                                                           exclude:(NSSet<Protocol*>*)excludedProtocols
{
    NSMutableSet* enumerated = (excludedProtocols.count > 0
                                ? [NSMutableSet setWithSet:excludedProtocols]
                                : [NSMutableSet new]);
    if (![excludedProtocols containsObject:self.protocol])
    {
        block(self);
        [enumerated addObject:self.protocol];
        [self enumerateProtocolInfosRecursivelyWithBlock:block
                                 enumeratedProtocols:enumerated];
    }
}

- (void)              enumerateProtocolInfosRecursivelyWithBlock:(void (^)(AKAProtocolInfo *))block
{
    [self enumerateProtocolInfosRecursivelyWithBlock:block exclude:nil];
}

- (void)              enumerateProtocolInfosRecursivelyWithBlock:(void (^)(AKAProtocolInfo *))block
                                                     exclude:(NSSet<Protocol*>*)excludedProtocols
{
    NSMutableSet* enumerated = (excludedProtocols.count > 0
                                ? [NSMutableSet setWithSet:excludedProtocols]
                                : [NSMutableSet new]);
    [self enumerateProtocolInfosRecursivelyWithBlock:block
                             enumeratedProtocols:enumerated];
}

- (void)              enumerateProtocolInfosRecursivelyWithBlock:(void (^)(AKAProtocolInfo *))block
                                         enumeratedProtocols:(NSMutableSet*)enumeratedProtocols
{
    unsigned int count = 0;
    __unsafe_unretained Protocol** protocols = protocol_copyProtocolList(self.protocol, &count);

    for (unsigned int i=0; i < count; ++i)
    {
        Protocol* protocol = protocols[i];
        if (![enumeratedProtocols containsObject:protocol])
        {
            AKAProtocolInfo* protocolInfo = [[AKAProtocolInfo alloc] initWithProtocol:protocol];
            block(protocolInfo);
            [enumeratedProtocols addObject:protocol];

            [protocolInfo enumerateProtocolInfosRecursivelyWithBlock:block
                                                 enumeratedProtocols:enumeratedProtocols];
        }

    }
    free(protocols);
}

@end

