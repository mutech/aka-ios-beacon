//
//  NSMutableString+AKATools.h
//  AKACommons
//
//  Created by Michael Utech on 20.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AKANullability.h"

@interface NSMutableString (AKATools)

- (void)aka_appendString:(req_NSString)string repeat:(NSUInteger)times;

@end
