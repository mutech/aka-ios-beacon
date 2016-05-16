//
//  NSString+AKAKeyPathUtilities.h
//  AKACommons
//
//  Created by Michael Utech (AKA) on 10/01/14.
//  Copyright (c) 2014 Michael Utech & AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AKAKeyPathUtilities)

/**
 * Interprets this string as key path and returns the last key component of the path.
 *
 * If the key path consists of only one key, this key will be returned.
 */
@property(nonatomic, readonly) NSString* aka_lastKeyPathComponent;

/**
 * Interprets this string as key path and returns the key path resulting from removing
 * the last component (key).
 *
 * If the key path consists of only one key, the property returns nil.
 */
@property(nonatomic, readonly) NSString* aka_baseKeyPath;

/**
 * Interprets this string as key path and adds the specified component as key.
 *
 * If the key is nil or empty, the receiver is returned. If the receiver is an empty
 * string, key is returned.
 */
- (NSString*)aka_keyPathByAppendingKeyPath:(NSString*)key;

/**
 * Interprets this string as key (-path) and prepends the specified key path.
 *
 * If the key path is nil or empty, the receiver is returned. If the receiver is an empty
 * string, the specified key path is returned.
 */
- (NSString*)aka_keyPathByPrependingKeyPath:(NSString*)keyPath;

/**
 * Returns the remaining key path after removing the specified prefix (which
 * should *not* have a trailing dot).
 */
- (NSString*)aka_keyPathByRemovingLeadingPath:(NSString*)prefix;

/**
 * Interprets this string as key path, locates the last occurence of '.' and
 * stores the path left to the dot in the key path storage and the remainder to
 * the right of the dot in the key storage.
 *
 * If either or both of keyPath or key are nil, the respective values will not be
 * stored.
 *
 * @param keyPath the string pointer that will be set to the base key path.
 * @param key the string pointer that will be set to the key.
 *
 * @return TRUE, if this instance contains a dot and if the key path and key storage
 *      has been updated; FALSE if no dot was found.
 */
- (BOOL)aka_splitIntoBaseKeyPath:(NSString**)keyPath key:(NSString**)key;


@end
