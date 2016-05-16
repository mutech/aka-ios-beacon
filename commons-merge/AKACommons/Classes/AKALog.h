//
//  AKALog.h
//  AKAControls
//
//  Created by Michael Utech on 18.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;
@import CocoaLumberjack;

#ifndef AKA_SUPPORT_DYNAMIC_LOG_LEVELS
#  define AKA_SUPPORT_DYNAMIC_LOG_LEVELS 1
#endif

#if AKA_SUPPORT_DYNAMIC_LOG_LEVELS
#  define AKA_LOG_LEVEL_DEF ([AKALog sharedInstance].logLevel)
#else
#  define AKA_LOG_LEVEL_DEF DDLogLevelWarning
#endif

#define AKALogError(format, ...)   LOG_MAYBE(NO,                AKA_LOG_LEVEL_DEF, DDLogFlagError,   0, nil, __PRETTY_FUNCTION__, format, ##__VA_ARGS__)
#define AKALogWarn(format, ...)    LOG_MAYBE(LOG_ASYNC_ENABLED, AKA_LOG_LEVEL_DEF, DDLogFlagWarning, 0, nil, __PRETTY_FUNCTION__, format, ##__VA_ARGS__)
#define AKALogInfo(format, ...)    LOG_MAYBE(LOG_ASYNC_ENABLED, AKA_LOG_LEVEL_DEF, DDLogFlagInfo,    0, nil, __PRETTY_FUNCTION__, format, ##__VA_ARGS__)
#define AKALogDebug(format, ...)   LOG_MAYBE(LOG_ASYNC_ENABLED, AKA_LOG_LEVEL_DEF, DDLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, format, ##__VA_ARGS__)
#define AKALogVerbose(format, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, AKA_LOG_LEVEL_DEF, DDLogFlagVerbose, 0, nil, __PRETTY_FUNCTION__, format, ##__VA_ARGS__)

@interface AKALog : NSObject

#if AKA_SUPPORT_DYNAMIC_LOG_LEVELS

+ (AKALog*)sharedInstance;

@property(nonatomic) DDLogLevel logLevel;

#endif

@end
