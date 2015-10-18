//
//  ViewController.m
//  AKAControlsDemo
//
//  Created by Michael Utech on 19.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAControlsDemoBaseViewController.h"

#import <AKAControls/AKAControl.h>
#import <AKAControls/AKAFormControl.h>
#import <AKAControls/AKATheme.h>
#import <AKAControls/AKAEditorControlView.h>

@interface AKAControlsDemoBaseViewController () <AKAControlDelegate>

@property(nonatomic, readonly) NSMutableDictionary* model;

@property(nonatomic) NSArray* themeNames;
@property(nonatomic) NSUInteger currentThemeIndex;

@end

@implementation AKAControlsDemoBaseViewController

- (void)viewDidLoad
{
    self.themeNames = @[ @"default", @"tableview" ];
    self.currentThemeIndex = 0;

    [super viewDidLoad];

    [self.formControl setThemeName:@"default" forClass:[AKAEditorControlView class]];
}

#pragma mark - ViewModel

#pragma mark - Theme switcher

- (IBAction)switchTheme:(id)sender
{
    self.currentThemeIndex = (self.currentThemeIndex + 1) % self.themeNames.count;
    NSString* themeName = self.themeNames[self.currentThemeIndex];
    [self.view setNeedsLayout];
    [UIView animateWithDuration:.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionShowHideTransitionViews
                     animations:^
     {
         [self.formControl
          setThemeName:themeName
              forClass:[AKAEditorControlView class]];
         [self.view layoutIfNeeded];
     }
                     completion:nil];
}

@synthesize model = _model;
- (NSMutableDictionary*)model
{
    if (_model == nil)
    {
        _model = [NSMutableDictionary dictionaryWithDictionary:
                  @{ @"name": @"AKA Sarl",
                     @"phone": @"+1-234-5678",
                     @"email": @"info@demo.org",
                     @"number": @(123.45) }];
    }
    return _model;
}

@end