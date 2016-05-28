//
//  AKAViewBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKABinding.h"
#import "AKAViewBindingDelegate.h"

/**
 * Abstract base class for bindings which target views.
 */
@interface AKAViewBinding: AKABinding

@property(nonatomic, readonly, weak, nullable) UIView*                    view;
@property(nonatomic, readonly, weak, nullable) id<AKAViewBindingDelegate> delegate;

@end


