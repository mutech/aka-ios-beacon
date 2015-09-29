//
//  UIView+AKABindingSupport.m
//  AKAControls
//
//  Created by Michael Utech on 20.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import <objc/runtime.h>

@import AKACommons.AKANullability;

#import "UIView+AKABindingSupport.h"

@implementation UIView(AKABindingSupport)

- (NSArray<NSString *> *)            aka_definedBindingPropertyNames
{
    return [self aka_bindingExpressionsBySelectorName].allKeys;
}


- (opt_AKABindingExpression)   aka_bindingExpressionForPropertyNamed:(req_NSString)key
{
    return [self aka_bindingExpressionsBySelectorName][key];
}

- (opt_AKABindingExpression)        aka_bindingExpressionForProperty:(req_SEL)selector
{
    NSString* key = NSStringFromSelector(selector);
    return [self aka_bindingExpressionForPropertyNamed:key];
}

- (void)                                    aka_setBindingExpression:(opt_AKABindingExpression)bindingExpression
                                                         forProperty:(req_SEL)selector
{
    NSString* key = NSStringFromSelector(selector);
    [self aka_setBindingExpression:bindingExpression
                  forPropertyNamed:key];
}

- (void)                                    aka_setBindingExpression:(opt_AKABindingExpression)bindingExpression
                                                    forPropertyNamed:(req_NSString)key
{
    if (bindingExpression == nil || bindingExpression == (id)[NSNull null])
    {
        [[self aka_bindingExpressionsBySelectorName] removeObjectForKey:key];
    }
    else
    {
        [self aka_bindingExpressionsBySelectorNameCreateIfMissing:YES][key] = bindingExpression;
    }
}

#pragma mark - Implementation

- (opt_NSMutableDictionary)     aka_bindingExpressionsBySelectorName
{
    return [self aka_bindingExpressionsBySelectorNameCreateIfMissing:NO];
}

- (opt_NSMutableDictionary)
                 aka_bindingExpressionsBySelectorNameCreateIfMissing:(BOOL)createMissing
{
    NSAssert([NSThread isMainThread], @"Invalid attempt to access associated value aka_bindingExpressionsBySelectorName outside of main thread");

    NSMutableDictionary* result = nil;
    id raw = objc_getAssociatedObject(self, @selector(aka_bindingExpressionsBySelectorName));

    if ([raw isKindOfClass:[NSMutableDictionary class]])
    {
        result = raw;
    }
    else if (raw == nil)
    {
        result = [NSMutableDictionary new];
        objc_setAssociatedObject(self,
                                 @selector(aka_bindingExpressionsBySelectorName),
                                 result,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else
    {
        NSString* message = [NSString stringWithFormat:@"Invalid type %@ for value %@ associated with aka_bindingExpressionsBySelectorName", [result class], result];
        @throw [NSException exceptionWithName:@"Internal inconsistency" reason:message userInfo:nil];
    }

    return result;
}

@end
