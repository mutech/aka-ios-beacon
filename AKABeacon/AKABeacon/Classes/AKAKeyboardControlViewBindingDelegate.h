//
//  AKAKeyboardControlViewBindingDelegate.h
//  AKABeacon
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKAControlViewBindingDelegate.h"


@protocol AKAKeyboardControlViewBindingDelegate<AKAControlViewBindingDelegate>

#pragma mark - Keyboard Navigation Requests

@optional
- (BOOL)                                            binding:(req_AKAKeyboardControlViewBinding)binding
                             responderRequestedActivateNext:(req_UIResponder)responder;

@optional
- (BOOL)                                            binding:(req_AKAKeyboardControlViewBinding)binding
                                 responderRequestedGoOrDone:(req_UIResponder)responder;

#pragma mark - UIResponder Events

@optional
- (BOOL)                                      shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                          responderActivate:(req_UIResponder)responder;

@optional
- (void)                                            binding:(req_AKAKeyboardControlViewBinding)binding
                                      responderWillActivate:(req_UIResponder)responder;

@optional
- (void)                                            binding:(req_AKAKeyboardControlViewBinding)binding
                                       responderDidActivate:(req_UIResponder)responder;

@optional
- (BOOL)                                      shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                        responderDeactivate:(req_UIResponder)responder;

@optional
- (void)                                            binding:(req_AKAKeyboardControlViewBinding)binding
                                    responderWillDeactivate:(req_UIResponder)responder;

@optional
- (void)                                            binding:(req_AKAKeyboardControlViewBinding)binding
                                     responderDidDeactivate:(req_UIResponder)responder;

@end
