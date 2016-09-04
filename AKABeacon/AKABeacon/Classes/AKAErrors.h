//
//  AKAErrors.h
//  AKAControls
//
//  Created by Michael Utech on 18.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;

/**
 Throws an exception indicating that an abstract method was not implemented.
 */
#define AKAErrorAbstractMethodImplementationMissing() \
    @throw [NSException exceptionWithName:NSInternalInconsistencyException \
                                   reason:[NSString stringWithFormat:@"Class %@ failed to implement abstract method %s", NSStringFromClass(self.class), __PRETTY_FUNCTION__] \
                                 userInfo:nil]

/**
 Throws an exception indicating that a method has not (yet) been implemented.
 */
#define AKAErrorMethodNotImplemented() \
    @throw [NSException exceptionWithName:NSInternalInconsistencyException \
                                   reason:[NSString stringWithFormat:@"Method %s in class %@ is not (yet) implemented", __PRETTY_FUNCTION__, NSStringFromClass(self.class)] \
                                 userInfo:nil]

/**
 Throws an exception indicating that an error has occurred but the caller did not provide an error
 store which means that it is not willing to handle the error and silently as well as invalidly assumes
 that no errors will occur.
 */
#define AKAUnhandledError(error) \
    @throw [NSException exceptionWithName:NSInternalInconsistencyException \
    reason:[NSString stringWithFormat:@"No defined error storage provided, unhandled error: %@", error.localizedDescription] \
userInfo:@{ @"error": error }]

/**
 Registers the specified error in the specified errorStore variable, if defined. If the specified error
 store is nil, AKAUnhandledError() will be called which in turn will throw an exception.
 */
#define AKARegisterErrorInErrorStore(error, errorStore) \
    if (errorStore) { *errorStore = error; } else { AKAUnhandledError(error); }


/**
 Error codes in [AKAErrors errorDomain].
 */
typedef NS_ENUM(NSUInteger, AKAErrorCodes) {
    /**
     An NSError encapsulating multiple errors.
     */
    AKAErrorsMultipleErrors = 1
};

@interface AKAErrors : NSObject

+ (nonnull NSString*)errorDomain;

/**
 Combines multiple errors into a single NSError.

 @param errors An array containing the errors to be combined.

 @return nil if errors is empty,  */
+ (nullable NSError*)errorForMultipleErrors:(nullable NSArray<NSError*>*)errors;

+ (nullable NSError*)errorForMultipleErrors:(nullable NSArray<NSError*>*)errors
                                   withCode:(NSInteger)code;


+ (nullable NSError*)errorForMultipleErrors:(nullable NSArray<NSError*>*)errors
                                   withCode:(NSInteger)code
                          descriptionFormat:(nonnull NSString*)descriptionFormat
                       descriptionSeparator:(nonnull NSString*)descriptionSeparator;

@end


@interface NSError(AKAErrors)

- (void)aka_enumerateUnderlyingErrorsUsingBlock:(void(^_Nonnull)(NSError*_Nonnull))block;

@end