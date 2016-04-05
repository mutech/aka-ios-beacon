//
//  AKABindingExpression+Accessors.m
//  AKABeacon
//
//  Created by Michael Utech on 22.03.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import <objc/runtime.h>

#import "AKABindingExpression+Accessors.h"

@implementation AKABindingExpression(Accessors)

+ (opt_AKABindingExpression)bindingExpressionForTarget:(id<NSObject>_Nonnull)target
                                              property:(req_SEL)selector
{

    NSString* key = NSStringFromSelector(selector);
    return [self bindingExpressionsBySelectorNameForTarget:target
                                           createIfMissing:NO][key];
}

+ (void)                          setBindingExpression:(opt_AKABindingExpression)bindingExpression
                                             forTarget:(id<NSObject>_Nonnull)target
                                              property:(req_SEL)selector
{
    NSString* key = NSStringFromSelector(selector);
    if (bindingExpression == nil || bindingExpression == (id)[NSNull null])
    {
        [[self bindingExpressionsBySelectorNameForTarget:target
                                         createIfMissing:NO]removeObjectForKey:key];
    }
    else
    {
        [self bindingExpressionsBySelectorNameForTarget:target
                                        createIfMissing:YES][key] = bindingExpression;
    }

}

+ (void)          enumerateBindingExpressionsForTarget:(id<NSObject>_Nonnull)target
                                             withBlock:(void (^_Nonnull)(SEL _Nonnull property,
                                                                         req_AKABindingExpression ex,
                                                                         outreq_BOOL stop))block
{
    [[self bindingExpressionsBySelectorNameForTarget:target
                                     createIfMissing:NO] enumerateKeysAndObjectsUsingBlock:
     ^(req_NSString             propertyName,
       req_AKABindingExpression bindingExpression,
       BOOL * _Nonnull          stop)
     {
         SEL property = NSSelectorFromString(propertyName);
         block(property, bindingExpression, stop);
     }];
}

#pragma mark - Implementation

+ (NSMutableDictionary<NSString*, AKABindingExpression*>*)
  bindingExpressionsBySelectorNameForTarget:(id<NSObject>)target
                            createIfMissing:(BOOL)createMissing
{
    SEL key = @selector(bindingExpressionsBySelectorNameForTarget:createIfMissing:);
    NSAssert([NSThread isMainThread], @"Invalid attempt to access associated value bindingExpressionsBySelectorNameForTarget:createIfMissing: outside of main thread");

    NSMutableDictionary* result = nil;
    id raw = objc_getAssociatedObject(target, key);

    if ([raw isKindOfClass:[NSMutableDictionary class]])
    {
        result = raw;
    }
    else if (raw == nil)
    {
        if (createMissing)
        {
            result = [NSMutableDictionary new];
            objc_setAssociatedObject(target,
                                     key,
                                     result,
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    else
    {
        NSString* message = [NSString stringWithFormat:@"Invalid type %@ for value %@ associated with %@", [result class], result, NSStringFromSelector(key)];
        @throw [NSException exceptionWithName:@"InvalidOperation"
                                       reason:message
                                     userInfo:nil];
    }

    return result;
}

@end

