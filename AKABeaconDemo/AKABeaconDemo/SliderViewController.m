//
//  SliderViewController.m
//  AKABeaconDemo
//
//  Created by Michael Utech on 30.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "SliderViewController.h"

@interface SliderViewController()
@end

@implementation SliderViewController

- (void)viewDidLoad
{
    self.minimumValue = 0;
    self.maximumValue = 1.0;
    self.stepValue = .01;
    self.autorepeat = YES;
    self.continuous = YES;
    self.wraps = YES;
    [super viewDidLoad];
}

#pragma mark - View Model

- (BOOL)validateValue:(inout id  _Nullable __autoreleasing *)ioValue
               forKey:(NSString *)inKey
                error:(out NSError * _Nullable __autoreleasing *)outError
{
    BOOL result = YES;
    if ([@[@"stepValue", @"minimumValue", @"maximumValue"] containsObject:inKey])
    {
        id value = *ioValue;
        if (![value isKindOfClass:[NSNumber class]] ||
            [value doubleValue] <= 0)
        {
            // Ignore change and use current value
            *ioValue = [self valueForKey:inKey];
        }
    }
    else
    {
        result = [super validateValue:ioValue forKey:inKey error:outError];
    }
    return result;
}

@end
