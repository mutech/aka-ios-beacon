//
//  AKAFormViewController.h
//  AKABeacon
//
//  Created by Michael Utech on 12.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKABindingController.h"

/**
 Deprecated, use AKABindingBehavior (see AKABeaconDemo project for examples)
 */
@interface AKAFormViewController: UIViewController<AKABindingControllerDelegate>

#pragma mark - Outlets

@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;

@end

