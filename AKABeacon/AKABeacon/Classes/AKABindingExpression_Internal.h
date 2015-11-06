//
//  AKABindingExpression_Internal.h
//  AKABeacon
//
//  Created by Michael Utech on 19.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABindingExpression.h"
#import "AKABindingProvider.h"

@import AKACommons.AKANullability;

@interface AKABindingExpression(Internal)

#pragma mark - Initialization

- (instancetype _Nullable)initWithPrimaryExpression:(opt_id)primaryExpression
                                         attributes:(opt_AKABindingExpressionAttributes)attributes
                                           provider:(opt_AKABindingProvider)provider;

@end

// Internal Cluster Classes

@interface AKABindingExpression ()

#pragma mark - Initialization

- (instancetype _Nonnull)initWithAttributes:(opt_AKABindingExpressionAttributes)attributes
                                   provider:(opt_AKABindingProvider)provider;

#pragma mark - Properties

@property(nonatomic, readonly, nullable)NSString* textForPrimaryExpression;

@end


@interface AKAArrayBindingExpression: AKABindingExpression

- (instancetype _Nonnull)initWithArray:(NSArray<AKABindingExpression*>*_Nullable)array
                            attributes:(opt_AKABindingExpressionAttributes)attributes
                              provider:(opt_AKABindingProvider)provider;

@property(nonatomic, readonly, nullable) NSArray<AKABindingExpression*>* array;

@end


@interface AKAConstantBindingExpression: AKABindingExpression

- (instancetype _Nonnull)initWithConstant:(opt_id)constant
                               attributes:(opt_AKABindingExpressionAttributes)attributes
                                 provider:(opt_AKABindingProvider)provider;

@property(nonatomic, readonly, nullable) id constant;

@property(nonatomic, readonly, nullable) NSString* textForConstant;

@end

@interface AKAClassConstantBindingExpression: AKAConstantBindingExpression

- (instancetype _Nonnull)initWithConstant:(opt_Class)constant
                               attributes:(opt_AKABindingExpressionAttributes)attributes
                                 provider:(opt_AKABindingProvider)provider;

@property(nonatomic, readonly, nullable) Class constant;

@end

@interface AKAStringConstantBindingExpression: AKAConstantBindingExpression

- (instancetype _Nonnull)initWithConstant:(opt_NSString)constant
                               attributes:(opt_AKABindingExpressionAttributes)attributes
                                 provider:(opt_AKABindingProvider)provider;

@property(nonatomic, readonly, nullable) NSString* constant;

@end

@interface AKANumberConstantBindingExpression: AKAConstantBindingExpression

- (instancetype _Nonnull)  initWithNumber:(opt_NSNumber)constant
                               attributes:(opt_AKABindingExpressionAttributes)attributes
                                 provider:(opt_AKABindingProvider)provider;

@property(nonatomic, readonly, nullable) NSNumber* constant;

@end

@interface AKABooleanConstantBindingExpression: AKANumberConstantBindingExpression

+ (AKABooleanConstantBindingExpression*_Nonnull)constantTrue;
+ (AKABooleanConstantBindingExpression*_Nonnull)constantFalse;

@end

@interface AKAIntegerConstantBindingExpression: AKANumberConstantBindingExpression
@end

@interface AKADoubleConstantBindingExpression: AKANumberConstantBindingExpression
@end

@interface AKAEnumConstantBindingExpression: AKAConstantBindingExpression

@property(nonatomic, nullable) NSString* enumerationType;
@property(nonatomic, nullable) NSString* symbolicValue;

+ (BOOL)registerEnumerationType:(req_NSString)enumerationType
               withValuesByName:(NSDictionary<NSString*, id>* _Nonnull)valuesByName;
+ (opt_id)resolveEnumeratedValue:(opt_NSString)symbolicValue
                         forType:(opt_NSString)enumerationType
                           error:(out_NSError)error;
@end

@interface AKAOptionsConstantBindingExpression: AKAIntegerConstantBindingExpression

@property(nonatomic, nullable) NSString* optionsType;

+ (BOOL)registerOptionsType:(req_NSString)enumerationType
           withValuesByName:(NSDictionary<NSString*, NSNumber*>* _Nonnull)valuesByName;

@end

@interface AKAColorConstantBindingExpression: AKAConstantBindingExpression
@end

@interface AKAUIColorConstantBindingExpression: AKAColorConstantBindingExpression
@end

@interface AKACGColorConstantBindingExpression: AKAColorConstantBindingExpression
@end

@interface AKAUIFontConstantBindingExpression: AKAConstantBindingExpression
@end

@interface AKACGPointConstantBindingExpression: AKAConstantBindingExpression
@end

@interface AKACGSizeConstantBindingExpression: AKAConstantBindingExpression
@end

@interface AKACGRectConstantBindingExpression: AKAConstantBindingExpression
@end


@interface AKAKeyPathBindingExpression: AKABindingExpression

- (instancetype _Nonnull)initWithKeyPath:(opt_NSString)keyPath
                               attributes:(opt_AKABindingExpressionAttributes)attributes
                                 provider:(opt_AKABindingProvider)provider;

/**
 * The key path referencing the bindings source value relative to the defined scope.
 * If the key path is undefined, the scope (or constant) itself is used.
 */
@property(nonatomic, readonly, nullable) NSString* keyPath;

@end

@interface AKADataContextKeyPathBindingExpression: AKAKeyPathBindingExpression
@end

@interface AKARootDataContextKeyPathBindingExpression: AKAKeyPathBindingExpression
@end

@interface AKAControlKeyPathBindingExpression: AKAKeyPathBindingExpression
@end