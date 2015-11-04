//
//  AKAFormViewController.h
//  AKABeacon
//
//  Created by Michael Utech on 12.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKAFormControl.h"

@interface AKAFormViewController: UIViewController<AKAControlDelegate>

#pragma mark - Configuration

@property(nonatomic, readonly) AKAFormControl* formControl;

#pragma mark - Outlets

@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;

@end

