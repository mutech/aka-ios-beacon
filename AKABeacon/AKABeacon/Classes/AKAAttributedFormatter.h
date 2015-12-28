//
//  AKAAttributedFormatter.h
//  AKABeacon
//
//  Created by Michael Utech on 18.12.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Formatter that applies text attributes to ranges of text matching a pattern.
 
 The attributed formatter is intended to be used independently of other formatters which
 (if used) create a non-attributed string that will then be turned into an attributed string.

 This is a quick shot to implement highlighting of search results. The interface and
 will most probably change (to support more flexible pattern matching, also the name
 should reflect the pattern matching functionality).
 */
@interface AKAAttributedFormatter : NSFormatter

@property(nonatomic) NSString* pattern;

@property(nonatomic) NSStringCompareOptions patternOptions;

@property(nonatomic) NSDictionary<NSString *,id>* defaultAttributes;

// TODO: make this immutable and support updating the dictionary instead of its contents in attributedFormatter binding:

@property(nonatomic) NSMutableDictionary<NSString *,id>* attributes;

@end
