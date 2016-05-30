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

/**
 The bindings target view (redeclared with restricted type UIView).
 */
@property(nonatomic, readonly, weak, nullable) UIView*                    target;

/**
 The binding delegate (redeclared for refined delegate type AKAViewBindingDelegate).
 */
@property(nonatomic, readonly, weak, nullable) id<AKAViewBindingDelegate> delegate;

@end


