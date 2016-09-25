//
//  NetworkActivityViewController.h
//  AKABeaconDemo
//
//  Created by Michael Utech on 24/09/2016.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;

@interface NetworkActivityViewController : UIViewController

@property(nonatomic) NSTimeInterval baseDuration;
@property(nonatomic) NSTimeInterval baseDelay;
@property(nonatomic) CGFloat randomFactor;
@property(nonatomic) NSUInteger operations;

@property(nonatomic, readonly) NSArray* items;

@end
