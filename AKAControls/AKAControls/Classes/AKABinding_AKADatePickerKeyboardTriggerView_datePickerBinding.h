//
//  AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding.h
//  AKAControls
//
//  Created by Michael Utech on 08.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABinding.h"

#import "AKAKeyboardActivationSequenceItemProtocol.h"


@interface AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding: AKABinding<
    AKAKeyboardActivationSequenceItemProtocol
>

@property(nonatomic, readonly) BOOL autoActivate;
@property(nonatomic, readonly) BOOL KBActivationSequence;
@property(nonatomic, readonly) BOOL liveModelUpdates;

@end
