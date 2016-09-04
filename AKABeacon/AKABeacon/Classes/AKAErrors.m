//
//  AKAErrors.m
//  AKAControls
//
//  Created by Michael Utech on 18.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import CoreData.CoreDataErrors;

#import "AKAErrors.h"

@implementation AKAErrors

static NSString* const kUnderlyingErrorsKey = @"com.aka-labs.AKAErrors.underlyingErrors";

+ (NSString *)errorDomain
{
    static NSString* result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = @"com.aka-labs.AKAErrors";
    });
    return result;
}

+ (NSError *)errorForMultipleErrors:(NSArray<NSError *> *)errors
{
    return [self errorForMultipleErrors:errors
                               withCode:AKAErrorsMultipleErrors];
}

+ (NSError *)errorForMultipleErrors:(NSArray<NSError *> *)errors
                           withCode:(NSInteger)code
{
    return [self errorForMultipleErrors:errors
                               withCode:code
                      descriptionFormat:@"Multiple errors: \n\t -%@"
                   descriptionSeparator:@"\n\t- "];
}

+ (NSError *)errorForMultipleErrors:(NSArray<NSError *> *)errors
                           withCode:(NSInteger)code
                  descriptionFormat:(NSString*)descriptionFormat
               descriptionSeparator:(NSString*)descriptionSeparator
{
    NSError* result = nil;

    if (errors.count == 1)
    {
        result = errors.firstObject;
    }
    else if (errors.count > 1)
    {
        NSString* description = [NSString stringWithFormat:descriptionFormat, [errors componentsJoinedByString:descriptionSeparator]];
        result = [NSError errorWithDomain:[self errorDomain]
                                     code:code
                                 userInfo:@{ NSLocalizedDescriptionKey: description,
                                             NSDetailedErrorsKey: errors }];
    }
    return result;
}

@end

@implementation NSError(AKAErrors)

- (void)aka_enumerateUnderlyingErrorsUsingBlock:(void (^)(NSError * _Nonnull))block
{
    NSError* underlyingError = self.userInfo[NSUnderlyingErrorKey];
    if (underlyingError)
    {
        block(underlyingError);
    }

    if (self.code == AKAErrorsMultipleErrors)
    {
        NSArray<NSError*>* errors = self.userInfo[kUnderlyingErrorsKey];
        for (NSError* error in errors)
        {
            block(error);
        }
    }
}

@end