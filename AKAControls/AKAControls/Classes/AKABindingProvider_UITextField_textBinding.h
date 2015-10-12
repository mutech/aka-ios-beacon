//
//  AKABindingProvider_UITextField_textBinding.h
//  AKAControls
//
//  Created by Michael Utech on 28.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABindingProvider.h"
#import "AKAKeyboardActivationSequence.h"


@interface AKABindingProvider_UITextField_textBinding: AKABindingProvider

+ (instancetype)sharedInstance;

@end


@interface AKABinding_UITextField_textBinding: AKAKeyboardControlViewBinding

@end


