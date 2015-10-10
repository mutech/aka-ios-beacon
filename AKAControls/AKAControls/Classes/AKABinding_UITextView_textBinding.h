//
//  AKABinding_UITextView_textBinding.h
//  AKAControls
//
//  Created by Michael Utech on 09.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABinding.h"

#import "AKAKeyboardActivationSequenceItemProtocol.h"


@interface AKABinding_UITextView_textBinding : AKABinding<AKAKeyboardActivationSequenceItemProtocol>

@property(nonatomic, readonly) BOOL                       liveModelUpdates;
@property(nonatomic, readonly) BOOL                       autoActivate;
@property(nonatomic, readonly) BOOL                       KBActivationSequence;

@end
