//
//  AppDelegate.m
//  AKABeaconDemo
//
//  Created by Michael Utech on 23.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AppDelegate.h"

@import AKACommons;
@import Aspects;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    AKA_LOG_LEVEL_DEF = DDLogLevelAll;
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:DDLogLevelWarning]; // TTY = Xcode console
    [DDLog addLogger:[DDASLLogger sharedInstance] withLevel:DDLogLevelWarning]; // ASL = Apple System Logs
    [DDLog setLevel:DDLogLevelAll forClass:[AKATVMultiplexedDataSource class]];

    Class header = NSClassFromString(@"_UITableViewHeaderFooterViewBackground");
    if (header)
    {
        NSError* error;
        id<AspectToken> token = [header aspect_hookSelector:@selector(setBackgroundColor:)
                                                withOptions:AspectPositionBefore
                                                 usingBlock:
                                 ^(id<AspectInfo> aspectInfo, UIColor* color) {
                                     NSLog(@"Header/Footer %@: setBackgroundColor:%@ called", aspectInfo.instance, color);
                                 }
                                                      error:&error];
        (void)token;
    }

    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
