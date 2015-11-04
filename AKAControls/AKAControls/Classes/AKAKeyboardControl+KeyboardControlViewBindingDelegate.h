//
//  AKAControl+KeyboardControlViewBindingDelegate.h
//  AKABeacon
//
//  Created by Michael Utech on 14.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAKeyboardControl.h"
#import "AKAScalarControl+ControlViewBindingDelegate.h"
#import "AKAKeyboardControlViewBindingDelegate.h"


@interface AKAKeyboardControl(KeyboardControlViewBindingDelegate) <AKAKeyboardControlViewBindingDelegate>

- (BOOL)                                shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                    responderActivate:(req_UIResponder)responder;

- (void)                                      binding:(req_AKAKeyboardControlViewBinding)binding
                                responderWillActivate:(req_UIResponder)responder;

- (void)                                      binding:(req_AKAKeyboardControlViewBinding)binding
                                 responderDidActivate:(req_UIResponder)responder;

- (BOOL)                                shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                  responderDeactivate:(req_UIResponder)responder;

- (void)                                      binding:(req_AKAKeyboardControlViewBinding)binding
                              responderWillDeactivate:(req_UIResponder)responder;

- (void)                                      binding:(req_AKAKeyboardControlViewBinding)binding
                               responderDidDeactivate:(req_UIResponder)responder;

- (BOOL)                                      binding:(req_AKAKeyboardControlViewBinding)binding
                       responderRequestedActivateNext:(req_UIResponder)responder;

- (BOOL)                                      binding:(req_AKAKeyboardControlViewBinding)binding
                           responderRequestedGoOrDone:(req_UIResponder)responder;

@end
