//
//  SliderViewController.m
//  AKABeaconDemo
//
//  Created by Michael Utech on 30.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKABeacon;

#import "SliderViewController.h"

@interface SliderViewController()

// Used to animate label text changes, see setNumberValue:
@property(nonatomic) AKATransitionAnimationParameters* numberValueLabelTransitionAnimation;

@end


@implementation SliderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [AKABindingBehavior addToViewController:self];

    self.minimumValue = 0;
    self.maximumValue = 1.0;
    self.stepValue = .01;
    self.autorepeat = YES;
    self.continuous = YES;
    self.wraps = YES;
    self.adaptiveAnimation = YES;

    self.numberValueLabelTransitionAnimation = [AKATransitionAnimationParameters new];
    self.numberValueLabelTransitionAnimation.duration = .25;
}

#pragma mark - View Model

- (void)setNumberValue:(double)numberValue
{
    if (self.adaptiveAnimation)
    {
        // Adapt animation to how the number was changed (increase or decreased):
        UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut;
        double oldValue = self.numberValue;
        if (numberValue < oldValue)
        {
            self.numberValueLabelTransitionAnimation.options =
            (options | UIViewAnimationOptionTransitionFlipFromTop);
        }
        else
        {
            self.numberValueLabelTransitionAnimation.options =
            (options | UIViewAnimationOptionTransitionFlipFromBottom);
        }
    }
    else
    {
        self.numberValueLabelTransitionAnimation.options = UIViewAnimationCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve;
    }

    _numberValue = numberValue;
}

- (BOOL)validateValue:(inout id  _Nullable __autoreleasing *)ioValue
               forKey:(NSString *)inKey
                error:(out NSError * _Nullable __autoreleasing *)outError
{
    BOOL result = YES;
    if ([@[@"stepValue", @"minimumValue", @"maximumValue"] containsObject:inKey])
    {
        // Make sure that stepper/slider configuration values are valid positive numbers, revert value if not
        id value = *ioValue;
        if (![value isKindOfClass:[NSNumber class]] ||
            [value doubleValue] <= 0)
        {
            // revert to current value
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
