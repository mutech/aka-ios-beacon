//
//  AKAArrayComparer.h
//  AKACommons
//
//  Created by Michael Utech on 25.07.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKAArrayComparer : NSObject

- initWithOldArray:(NSArray* __nonnull)oldArray
          newArray:(NSArray* __nonnull)newArray;

@property(nonatomic, nonnull, readonly) NSArray* oldArray;
@property(nonatomic, nonnull, readonly) NSArray* array;

@end
