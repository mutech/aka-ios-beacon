//
//  FontBindingDemoViewController.h
//  AKABeaconDemo
//
//  Created by Michael Utech on 18.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FontBindingDemoViewController : UIViewController

@property(nonatomic) UIFontDescriptorSymbolicTraits symbolicTraits;

@property(nonatomic) CGFloat pointSize;
@property(nonatomic) BOOL bold;
@property(nonatomic) BOOL italic;

@end
