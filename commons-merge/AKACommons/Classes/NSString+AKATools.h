//
//  NSString+AKATools.h
//  AKACommons
//
//  Created by Michael Utech on 27.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AKATools)

- (NSUInteger)aka_occurencesOfCharacters:(NSCharacterSet*)characters;

- (NSUInteger)aka_occurrencesOfCharactersInString:(NSString*)string;

- (NSString*)aka_stringWithFirstCharacterUppercase;

@end
