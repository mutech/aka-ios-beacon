//
//  ImageViewDemoViewController.m
//  AKABeaconDemo
//
//  Created by Michael Utech on 06.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "ImageViewDemoViewController.h"
@import AKABeacon;

@implementation ImageViewDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [AKABindingBehavior addToViewController:self];

    self.images = @[ @"AKALogo", @"Photo" ];
}

- (void)setSelectedImageIndex:( NSUInteger)selectedImageIndex
{
    _selectedImageIndex = selectedImageIndex % self.images.count;
    self.selectedImageOrImageName = _selectedImageIndex < self.images.count ? self.images[_selectedImageIndex] : nil;
}

- (void)setImages:(NSArray *)images
{
    _images = images;
    self.selectedImageIndex = self.selectedImageIndex; // update selectedImageOrImageName view index in new array
}

@end
