//
//  AKAErrors.h
//  AKAControls
//
//  Created by Michael Utech on 18.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AKAErrorAbstractMethodImplementationMissing() \
    @throw [NSException exceptionWithName:NSInternalInconsistencyException \
                                   reason:[NSString stringWithFormat:@"Class %@ failed to implement abstract method %s", NSStringFromClass(self.class), __PRETTY_FUNCTION__] \
                                 userInfo:nil]

@interface AKAErrors : NSObject

@end
