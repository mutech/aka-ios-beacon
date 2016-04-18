//
//  FontBindingDemoViewController.m
//  AKABeaconDemo
//
//  Created by Michael Utech on 18.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKABeacon;

#import "FontBindingDemoViewController.h"

@interface FontBindingDemoViewController ()

@end

@implementation FontBindingDemoViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [AKABindingBehavior addToViewController:self];
}

#pragma mark - View Model

- (void)setPointSize:(CGFloat)pointSize
{
    _pointSize = pointSize; //roundf(pointSize);
}

- (BOOL)bold
{
    return self.symbolicTraits & UIFontDescriptorTraitBold;
}

- (void)setBold:(BOOL)bold
{
    if (bold)
    {
        self.symbolicTraits = self.symbolicTraits | UIFontDescriptorTraitBold;
    }
    else
    {
        self.symbolicTraits = self.symbolicTraits & (~ UIFontDescriptorTraitBold);
    }
}

- (BOOL)italic
{
    return self.symbolicTraits & UIFontDescriptorTraitItalic;
}

- (void)setItalic:(BOOL)italic
{
    if (italic)
    {
        self.symbolicTraits = self.symbolicTraits | UIFontDescriptorTraitItalic;
    }
    else
    {
        self.symbolicTraits = self.symbolicTraits & (~ UIFontDescriptorTraitItalic);
    }
}

@end
