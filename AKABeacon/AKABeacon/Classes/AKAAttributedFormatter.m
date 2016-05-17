//
//  AKAAttributedFormatter.m
//  AKABeacon
//
//  Created by Michael Utech on 18.12.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKANullability.h"

#import "AKAAttributedFormatter.h"

@implementation AKAAttributedFormatter

- (instancetype)init
{
    if (self = [super init])
    {
        self.attributes = [NSMutableDictionary new];
        self.defaultAttributes = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    (void)zone;
    AKAAttributedFormatter* result = [AKAAttributedFormatter new];
    result.pattern = self.pattern;
    result.patternOptions = self.patternOptions;
    result.defaultAttributes = self.defaultAttributes;
    result.attributes = [NSMutableDictionary dictionaryWithDictionary:self.attributes];
    return result;
}

- (NSString *)stringForObjectValue:(id)obj
{
    NSString* result;

    if ([obj isKindOfClass:[NSString class]])
    {
        result = obj;
    }
    else
    {
        result = [NSString stringWithFormat:@"%@", obj];
    }
    return result;
}

- (NSAttributedString *)attributedStringForObjectValue:(id)obj
                                 withDefaultAttributes:(NSDictionary<NSString *,id> *)defaultAttributes
{
    NSString* text = [self stringForObjectValue:obj];
    NSMutableAttributedString* result = [[NSMutableAttributedString alloc] initWithString:text
                                                                               attributes:defaultAttributes];
    if (self.pattern.length > 0)
    {
        [self enumateRangesForMatchesOfPattern:self.pattern
                                      inString:text
                                         block:
         ^(NSRange range, BOOL * _Nonnull stop) {
             (void)stop;
             [result addAttributes:self.attributes range:range];
         }];
    }

    return result;
}

- (NSUInteger)enumateRangesForMatchesOfPattern:(NSString*)pattern
                                      inString:(NSString*)text
                                         block:(void(^)(NSRange range, outreq_BOOL stop))block
{
    NSUInteger result = 0;

    if (text.length > 0)
    {
        NSRange scope = NSMakeRange(0, text.length);
        __block BOOL stop = scope.length <= 0;
        while (!stop)
        {
            NSRange range = [text rangeOfString:pattern options:self.patternOptions range:scope];
            stop = range.location == NSNotFound || range.length <= 0;
            if (!stop)
            {
                scope = NSMakeRange(scope.location + range.length, scope.length - range.length);
                ++result;
                block(range, &stop);
            }
        }
    }

    return result;
}

@end
