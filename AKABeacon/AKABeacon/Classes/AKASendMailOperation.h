//
//  AKASendMailOperation.h
//  AKABeacon
//
//  Created by Michael Utech on 03.09.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;
@import MessageUI;


#import "AKAPresentViewControllerOperation.h"

@interface AKASendMailOperation: AKAPresentViewControllerOperation

- (nonnull instancetype)initWithViewController:(nonnull MFMailComposeViewController*)viewController
                      presentingViewController:(nonnull UIViewController*)presenter;

- (nonnull instancetype)initWithViewController:(nonnull MFMailComposeViewController*)viewController
                      presentingViewController:(nonnull UIViewController*)presenter
                                 barButtonItem:(nonnull UIBarButtonItem*)popoverAnchor;

- (nonnull instancetype)initWithViewController:(nonnull MFMailComposeViewController*)viewController
                      presentingViewController:(nonnull UIViewController*)presenter
                                    sourceView:(nonnull UIView*)sourceView;

- (nonnull instancetype)initWithViewController:(nonnull MFMailComposeViewController*)viewController
                      presentingViewController:(nonnull UIViewController*)presenter
                                    sourceView:(nonnull UIView*)sourceView
                                    sourceRect:(CGRect)sourceRect;

+ (nonnull instancetype)operationForController:(nonnull MFMailComposeViewController*)controller
                      presentingViewController:(nonnull UIViewController*)presenter;

/**
 The result of the mail compose controller. 
 
 Please note that the value of this property is undefined until the operation is finished
 */
@property(nonatomic, readonly) MFMailComposeResult mailComposeResult;

@end
