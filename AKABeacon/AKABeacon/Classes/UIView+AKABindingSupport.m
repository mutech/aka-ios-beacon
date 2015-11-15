//
//  UIView+AKABindingSupport.m
//  AKABeacon
//
//  Created by Michael Utech on 20.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import <objc/runtime.h>

@import AKACommons.AKANullability;
@import AKACommons.NSObject_AKAConcurrencyTools;

#import "UIView+AKABindingSupport.h"

typedef NSMutableDictionary<NSString*, AKABindingExpression*>* Storage;


@implementation UIView(AKABindingSupport)

- (void)             aka_enumerateBindingExpressionsWithBlock:(void (^)(SEL _Nonnull,
                                                                        req_AKABindingExpression,
                                                                        outreq_BOOL))block
{
    [[self aka_bindingExpressionsBySelectorNameCreateIfMissing:NO] enumerateKeysAndObjectsUsingBlock:
     ^(req_NSString             propertyName,
       req_AKABindingExpression bindingExpression,
       BOOL * _Nonnull          stop)
     {
         SEL property = NSSelectorFromString(propertyName);
         block(property, bindingExpression, stop);
     }];
}

- (opt_AKABindingExpression) aka_bindingExpressionForProperty:(req_SEL)selector
{
    NSString* key = NSStringFromSelector(selector);
    return [self aka_bindingExpressionsBySelectorNameCreateIfMissing:NO][key];
}

- (void)                             aka_setBindingExpression:(opt_AKABindingExpression)bindingExpression
                                                  forProperty:(req_SEL)selector
{
    NSString* key = NSStringFromSelector(selector);
    if (bindingExpression == nil || bindingExpression == (id)[NSNull null])
    {
        [[self aka_bindingExpressionsBySelectorNameCreateIfMissing:NO] removeObjectForKey:key];
    }
    else
    {
        [self aka_bindingExpressionsBySelectorNameCreateIfMissing:YES][key] = bindingExpression;
    }
}

#pragma mark - Implementation

- (Storage)aka_bindingExpressionsBySelectorNameCreateIfMissing:(BOOL)createMissing
{
    NSAssert([NSThread isMainThread], @"Invalid attempt to access associated value aka_bindingExpressionsBySelectorName outside of main thread");

    NSMutableDictionary* result = nil;
    id raw = objc_getAssociatedObject(self, @selector(aka_bindingExpressionsBySelectorNameCreateIfMissing:));

    if ([raw isKindOfClass:[NSMutableDictionary class]])
    {
        result = raw;
    }
    else if (raw == nil)
    {
        if (createMissing)
        {
            result = [NSMutableDictionary new];
            objc_setAssociatedObject(self,
                                     @selector(aka_bindingExpressionsBySelectorNameCreateIfMissing:),
                                     result,
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    else
    {
        NSString* message = [NSString stringWithFormat:@"Invalid type %@ for value %@ associated with aka_bindingExpressionsBySelectorName", [result class], result];
        @throw [NSException exceptionWithName:@"Internal inconsistency" reason:message userInfo:nil];
    }

    return result;
}

@end
