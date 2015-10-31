//
//  AKABindingErrors.m
//  AKAControls
//
//  Created by Michael Utech on 31.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABindingErrors_Internal.h"
#import "AKAControlsErrors_Internal.h"

@implementation AKABindingErrors

+ (NSError*)bindingErrorUndefinedBindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                                    context:(req_AKABindingContext)bindingContext
{
    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorUndefinedBindingSource
                                      userInfo:nil];
    return result;
}

@end
