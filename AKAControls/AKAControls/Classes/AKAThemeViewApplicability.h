//
// Created by Michael Utech on 25.03.15.
// Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKAThemeViewApplicability: NSObject

- (instancetype)initRequireAbsent;
- (instancetype)initRequirePresent;
- (instancetype)initWithValidTypes:(NSArray*)validTypes
                      invalidTypes:(NSArray*)invalidTypes
                    requirePresent:(BOOL)required;
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
- (instancetype)initWithSpecification:(id)specification;

@property(nonatomic, readonly) NSArray* validTypes;
@property(nonatomic, readonly) NSArray* invalidTypes;
@property(nonatomic, readonly) BOOL requirePresent;
@property(nonatomic, readonly) BOOL requireAbsent;

- (BOOL)isApplicableToView:(id)view;

@end
