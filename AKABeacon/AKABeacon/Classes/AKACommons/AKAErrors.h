//
//  AKAErrors.h
//  AKAControls
//
//  Created by Michael Utech on 18.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AKAErrorAbstractMethodImplementationMissing() \
    @throw [NSException exceptionWithName:NSInternalInconsistencyException \
                                   reason:[NSString stringWithFormat:@"Class %@ failed to implement abstract method %s", NSStringFromClass(self.class), __PRETTY_FUNCTION__] \
                                 userInfo:nil]

#define AKAErrorMethodNotImplemented() \
    @throw [NSException exceptionWithName:NSInternalInconsistencyException \
                                   reason:[NSString stringWithFormat:@"Method %s in class %@ is not (yet) implemented", __PRETTY_FUNCTION__, NSStringFromClass(self.class)] \
                                 userInfo:nil]

@interface AKAErrors : NSObject

@end
