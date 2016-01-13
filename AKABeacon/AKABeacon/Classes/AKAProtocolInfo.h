//
//  AKAProtocolInfo.h
//  AKABeacon
//
//  Created by Michael Utech on 11.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import <objc/runtime.h>
@import Foundation;

@interface AKAProtocolInfo: NSObject

@property(nonatomic, readonly) Protocol* protocol;

#pragma mark - Initialization

- (instancetype)initWithProtocol:(Protocol*)protocol;

#pragma mark - Enumerating Protocol Message Descriptions

#pragma mark Local methods

- (void)                      enumerateMethodDescriptionsWithBlock:(void(^)(SEL selector, char* types))block
                                                          required:(BOOL)required
                                                          instance:(BOOL)instance;

- (void)                      enumerateMethodDescriptionsWithBlock:(void(^)(SEL selector, char* types, BOOL isRequired, BOOL isInstanceMethod))block;
- (void)              enumerateInstanceMethodDescriptionsWithBlock:(void(^)(SEL selector, char* types, BOOL isRequired))block;
- (void)                enumerateStaticMethodDescriptionsWithBlock:(void(^)(SEL selector, char* types, BOOL isRequired))block;
- (void)              enumerateOptionalMethodDescriptionsWithBlock:(void(^)(SEL selector, char* types, BOOL isInstanceMethod))block;
- (void)              enumerateRequiredMethodDescriptionsWithBlock:(void(^)(SEL selector, char* types, BOOL isInstanceMethod))block;

#pragma mark Local and incorporated methods

- (void)           enumerateMethodDescriptionsRecursivelyWithBlock:(void(^)(Protocol* protocol, SEL selector, char* types))block
                                                          required:(BOOL)required
                                                          instance:(BOOL)instance;

- (void)           enumerateMethodDescriptionsRecursivelyWithBlock:(void(^)(Protocol* protocol, SEL selector, char* types, BOOL isRequired, BOOL isInstanceMethod))block;
- (void)    enumerateInstanceMethodDescriptionsRecursivelyWithBlock:(void(^)(Protocol* protocol, SEL selector, char* types, BOOL isRequired))block;
- (void)     enumerateStaticMethodDescriptionsRecursivelyWithBlock:(void(^)(Protocol* protocol, SEL selector, char* types, BOOL isRequired))block;
- (void)   enumerateRequiredMethodDescriptionsRecursivelyWithBlock:(void(^)(Protocol* protocol, SEL selector, char* types, BOOL isInstanceMethod))block;
- (void)   enumerateOptionalMethodDescriptionsRecursivelyWithBlock:(void(^)(Protocol* protocol, SEL selector, char* types, BOOL isInstanceMethod))block;

#pragma mark - Enumerating Incorporated Protocols

- (void)                               enumerateProtocolsWithBlock:(void(^)(Protocol* protocol))block;

- (void)                    enumerateProtocolInfosRecursivelyWithBlock:(void(^)(AKAProtocolInfo* protocol))block;
- (void)                    enumerateProtocolInfosRecursivelyWithBlock:(void(^)(AKAProtocolInfo* protocol))block
                                                           exclude:(NSSet<Protocol*>*)excludedProtocols;

- (void)             enumerateSelfAndProtocolInfosRecursivelyWithBlock:(void(^)(AKAProtocolInfo* protocol))block;
- (void)             enumerateSelfAndProtocolInfosRecursivelyWithBlock:(void(^)(AKAProtocolInfo* protocol))block
                                                           exclude:(NSSet<Protocol*>*)excludedProtocols;

@end

