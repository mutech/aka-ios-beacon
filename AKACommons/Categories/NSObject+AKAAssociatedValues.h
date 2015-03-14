//
//  NSObject+AKAAssociatedValues.h
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (AKAAssociatedValues)

- (void)setAssociatedValue:(id)value forKey:(NSString*)key;
- (void)removeValueAssociatedWithKey:(NSString*)key;
- (void)removeAllAssociatedValues;

@end
