//
//  AKAViewSizeTransitionListener.h
//  AKABeacon
//
//  Created by Michael Utech on 05.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;

@protocol AKAViewSizeTransitionListener <NSObject>

@required
- (void)                    viewController:(UIViewController*)viewController
                  viewWillTransitionToSize:(CGSize)size
                 withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;

@end
