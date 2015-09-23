//
//  NSString+AKAKeyPathUtilities.m
//  AKACommons
//
//  Created by Michael Utech (AKA) on 10/01/14.
//  Copyright (c) 2014 Gripsware GmbH. All rights reserved.
//

#import "NSString+AKAKeyPathUtilities.h"

@implementation NSString (AKAKeyPathUtilities)

- (NSString*)aka_lastKeyPathComponent
{
    NSString* result;
    if (![self aka_splitIntoLeft:nil
                  right:&result
                atIndex:[self aka_indexOfLastOccurenceOfCharacter:'.']])
    {
        result = self;
    }
    return result;
}

- (NSString*)aka_baseKeyPath
{
    NSString* result;
    [self aka_splitIntoLeft:&result
                  right:nil
                atIndex:[self aka_indexOfLastOccurenceOfCharacter:'.']];
    return result;
}

- (NSString*)aka_keyPathByAppendingKeyPath:(NSString*)key
{
    return key.length ? [self stringByAppendingFormat:@".%@", key] : self;
}

- (NSString*)aka_keyPathByPrependingKeyPath:(NSString*)keyPath
{
    if (!keyPath.length)
    {
        return self;
    }
    else
    {
        return [keyPath aka_keyPathByAppendingKeyPath:self];
    }
}

- (NSString*)aka_keyPathByRemovingLeadingPath:(NSString *)prefix
{
    NSString* result = self;
    if (prefix.length && prefix.length <= self.length)
    {
        NSRange match = [self rangeOfString:prefix];
        if (match.location == 0 && match.length == prefix.length)
        {
            if (match.length == self.length)
            {
                // prefix matches complete key path, return empty string.
                result = @"";
            }
            else if ([prefix characterAtIndex:match.length - 1] == '.')
            {
                // prefix ended with '.'
                result = [self substringWithRange:NSMakeRange(match.length,
                                                              self.length - match.length)];
            }
            else if (self.length > match.length + 1 && [self characterAtIndex:match.length] == '.')
            {
                // prefix matched up to a dot result is everything following the dot.
                result = [self substringWithRange:NSMakeRange(match.length + 1,
                                                              self.length - match.length - 1)];
            }
            else
            {
                // All other cases mean no match
            }
        }
        else
        {
            // If no match found or the prefix didn't match completely,
            // that means no match.
        }
    }
    return result;
}

- (BOOL)aka_splitIntoBaseKeyPath:(NSString**)keyPath key:(NSString**)key
{
    BOOL result = NO;
    NSInteger index = [self aka_indexOfLastOccurenceOfCharacter:'.'];
    if (index == NSNotFound)
    {
        result = self.length > 0;
        if (result)
        {
            (*keyPath) = @"";
            (*key) = self;
        }
    }
    else
    {
        result = [self aka_splitIntoLeft:keyPath right:key atIndex:index];
    }
    return result;
}

- (NSInteger)aka_indexOfLastOccurenceOfCharacter:(unichar)character
{
    NSInteger result = NSNotFound;
    NSUInteger length = self.length;
    for (long i = (long)length - 1; i >=0; --i)
    {
        unichar c = [self characterAtIndex:i];
        if (c == '.')
        {
            result = i;
            break;
        }
    }
    return result;
}

- (BOOL)aka_splitIntoLeft:(NSString**)left
                right:(NSString**)right
              atIndex:(NSInteger)index
{
    BOOL result = index >= 0 && index < self.length;
    if (result)
    {
        if (left)
        {
            (*left) = [self substringToIndex:index];
        }
        if (right)
        {
            (*right) = [self substringFromIndex:index + 1];
        }
    }
    return result;
}

@end
