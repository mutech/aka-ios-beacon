//
// Created by Michael Utech on 25.03.15.
// Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKAThemeViewApplicability: NSObject

- (instancetype)initRequirePresent;
- (instancetype)initRequireAbsent;
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
- (instancetype)initWithSpecification:(id)specification;

@property(nonatomic) NSArray* validTypes;
@property(nonatomic) NSArray* invalidTypes;
@property(nonatomic) BOOL present;

- (BOOL)isApplicableToView:(id)view;
- (void)setRequiresViewsOfTypeIn:(NSArray*)validTypes;
- (void)setRequiresViewsOfTypeNotIn:(NSArray*)invalidTypes;

@end
