//
// Created by Michael Utech on 17.10.15.
// Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKAKeyboardControlViewBinding.h"
#import "AKACustomKeyboardResponderView.h"


@interface AKAKeyboardBinding_AKACustomKeyboardResponderView : AKAKeyboardControlViewBinding<
    AKACustomKeyboardResponderDelegate
>

@property(nonatomic, readonly) AKACustomKeyboardResponderView*  triggerView;

@property(nonatomic, weak)     UIView*                          inputAccessoryView;

- (void)                    attachToCustomKeyboardResponderView;

- (void)                  detachFromCustomKeyboardResponderView;

@end