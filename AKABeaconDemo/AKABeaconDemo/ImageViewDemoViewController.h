//
//  ImageViewDemoViewController.h
//  AKABeaconDemo
//
//  Created by Michael Utech on 06.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKABeacon;

@interface ImageViewDemoViewController : AKAFormViewController

@property(nonatomic) NSArray* images;
@property(nonatomic) id selectedImageOrImageName;
@property(nonatomic) NSUInteger selectedImageIndex;

@end
