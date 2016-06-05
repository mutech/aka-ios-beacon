//
//  AKAKeyboardControlViewBinding+DelegateSupport.h
//  AKABeacon
//
//  Created by Michael Utech on 05.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAKeyboardControlViewBinding.h"


@interface AKAKeyboardControlViewBinding (DelegateSupport)

- (BOOL)                              shouldResponderActivate:(req_UIResponder)responder;
- (void)                                responderWillActivate:(req_UIResponder)responder;
- (void)                                 responderDidActivate:(req_UIResponder)responder;
- (BOOL)                            shouldResponderDeactivate:(req_UIResponder)responder;
- (void)                              responderWillDeactivate:(req_UIResponder)responder;
- (void)                               responderDidDeactivate:(req_UIResponder)responder;

@end
