//
//  NSObject+AKAAssociatedValues.h
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (AKAAssociatedStorage)

@property (nonatomic, readonly) BOOL aka_hasAssociatesValues;

- (void)aka_setAssociatedValues:(NSDictionary*)values;

- (id)aka_associatedValueForKey:(id)key;

- (void)aka_setAssociatedValue:(id)value forKey:(NSString*)key;

- (void)aka_removeValueAssociatedWithKey:(NSString*)key;

- (void)aka_removeAllAssociatedValues;

- (void)aka_savePropertyValues:(NSArray*)propertyNames;

- (void)aka_restoreSavedPropertyValues:(NSArray*)propertyNames;

@end

