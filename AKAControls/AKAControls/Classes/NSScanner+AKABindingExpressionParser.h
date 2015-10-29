//
//  NSScanner+AKABindingExpressionParser.h
//  AKAControls
//
//  Created by Michael Utech on 19.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
@import AKACommons.AKANullability;

#import "AKABindingProvider.h"
#import "AKABindingExpression.h"

typedef enum AKABindingExpressionParseErrorCode
{
    // Scope identifier/constant errors
    AKAParseErrorInvalidConstantOrScopeName,

    // Key path parsing errors
    AKAParseErrorInvalidKeyPathComponent,
    AKAParseErrorInvalidKeyPathOperator,
    AKAParseErrorKeyPathOperatorRequiresSubsequentKey,
    AKAParseErrorKeyPathOperatorNameExpectedAfterAtSign,
    AKAParseErrorUnterminatedKeyPathAfterDot,
    AKAParseErrorKeyPathNotSupportedForExpressionType,
    
    AKAParseErrorInvalidPrimaryExpressionExpectedAttributesOrEnd,

    // Expression and attribute list errors
    AKAParseErrorUnterminatedBindingExpressionList,
    AKAParseErrorInvalidAttributeName,
    
    // String literal parsing errors
    AKAParseErrorInvalidStringDelimiter,
    AKAParseErrorUnterminatedStringConstant,
    AKAParseErrorUnsupportedCharacterEscapeSequence,
    AKAParseErrorInvalidCharacterEscapeSequence,

    // Number parsing errors
    AKAParseErrorInvalidNumberConstant,
    
    // Identifier errors
    AKAParseErrorInvalidIdentifierCharacter,

    AKAParseErrorUnterminatedParenthizedExpression,

    // Class errors
    AKAParseErrorUnknownClass,
    AKAParseErrorUnterminatedClassReference
    
} AKABindingExpressionParseErrorCode;

typedef NSScanner AKABindingExpressionParser;

@interface NSScanner(BindingExpressionParser)

+ (req_NSString) keywordTrue;
+ (req_NSString) keywordFalse;
+ (req_NSString) keywordData;
+ (req_NSString) keywordRoot;
+ (req_NSString) keywordControl;
+ (req_NSString) keywordColor;
+ (req_NSString) keywordUIColor;
+ (req_NSString) keywordCGColor;
+ (req_NSString) keywordFont;
+ (req_NSString) keywordUIFont;
+ (req_NSString) keywordPoint;
+ (req_NSString) keywordCGPoint;
+ (req_NSString) keywordSize;
+ (req_NSString) keywordCGSize;
+ (req_NSString) keywordRect;
+ (req_NSString) keywordCGRect;

#pragma mark - Binding Expression Parser

- (BOOL)    parseBindingExpression:(out_AKABindingExpression)store
                      withProvider:(opt_AKABindingProvider)provider
                             error:(out_NSError)error;

- (BOOL)      parseConstantOrScope:(out_id)constantStore
                      withProvider:(opt_AKABindingProvider)provider
                              type:(out_Class)bindingExpressionType
                             error:(out_NSError)error;

- (BOOL)              parseKeyPath:(out_NSString)store
                             error:(out_NSError)error;

- (BOOL)           parseIdentifier:(out_NSString)store
                             error:(out_NSError)error;

- (BOOL)       parseStringConstant:(out_NSString)stringStorage
                             error:(out_NSError)error;

- (BOOL)     parseEscapedCharacter:(unichar* __nullable)unicharStorage
                             error:(out_NSError)error;

- (BOOL)       parseNumberConstant:(out_id)constantStore
                              type:(out_Class)bindingExpressionType
                             error:(out_NSError)error;

#pragma mark - Scanner Tools (Convenience)

- (BOOL)    skipCurrentCharacter;

- (BOOL)    isAtCharacter:(unichar)character;

- (BOOL)    skipCharacter:(unichar)character;

- (BOOL)    isAtValidKeyPathComponentFirstCharacter;

- (BOOL)    isAtValidFirstIntegerCharacter;

- (BOOL)    isAtValidFirstIdentifierCharacter;

- (BOOL)    isAtValidIdentifierCharacter;

#pragma mark - Scanner Tools (Error Reporting)

- (BOOL)        registerParseError:(NSError* __autoreleasing __nonnull* __nullable)error
                          withCode:(AKABindingExpressionParseErrorCode)errorCode
                        atPosition:(NSUInteger)position
                            reason:(req_NSString)reason;

- (req_NSString)contextMessageWithMaxLeading:(NSUInteger)maxLeading
                                 maxTrailing:(NSUInteger)maxTrailing;


@end
