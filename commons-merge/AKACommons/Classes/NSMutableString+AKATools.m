//
//  NSMutableString+AKATools.m
//  AKACommons
//
//  Created by Michael Utech on 20.09.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "NSMutableString+AKATools.h"

@implementation NSMutableString (AKATools)

- (void)aka_appendString:(NSString*)string repeat:(NSUInteger)times
{
    if (string.length > 0)
    {
        for (NSUInteger i=0; i < times; ++i)
        {
            [self appendString:string];
        }
    }
}

@end
