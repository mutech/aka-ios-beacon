//
//  AKALog.h
//  AKAControls
//
//  Created by Michael Utech on 18.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

// Implementation notes: do/while to make it a statement requiring a semicolon; ## to remove the
// preceeding comma if no variadic args are given.
#define AKALogLevel(level, format, ...)\
    do{ NSString* msg = [level stringByAppendingString:[NSString stringWithFormat:(format),##__VA_ARGS__]];\
        NSLog(@"%@",msg); } while(0)

#define AKALogDebug(format, ...)  AKALogLevel(@"DEBUG", (format),##__VA_ARGS__)
#define AKALogInfo(format, ...)   AKALogLevel(@"INFO",  (format),##__VA_ARGS__)
#define AKALogWarn(format, ...)   AKALogLevel(@"WARN",  (format), ##__VA_ARGS__)
#define AKALogError(format, ...)  AKALogLevel(@"ERROR", (format), ##__VA_ARGS__)

@interface AKALog : NSObject

@end
