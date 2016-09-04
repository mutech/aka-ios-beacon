//
//  AKAAlertOperation.h
//  AKABeacon
//
//  Created by Michael Utech on 02.09.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAPresentViewControllerOperation.h"


@interface AKAAlertOperation: AKAPresentViewControllerOperation

#pragma mark - Initialization

/**
 Creates a new operation that will present the specified alert controller from the specified presenter.

 If no presenter is specified, the operation will inspect the current key window and use it's root view controller (resolving UINavigationContoller and UITabBarController instances to their visible or selected view controllers).

 @param alertController the alert controller to be presented.
 @param presenter       the presenting view controller or nil to let the operation find a suitable view controller for presentation.

 @return a new operation
 */
+ (nonnull instancetype)      operationForController:(nonnull UIAlertController *)alertController
                                 presentationContext:(nullable UIViewController *)presenter;

/**
 Creates a new instance of UIAlertViewController configued with the specified parameters and an operation that will present if from the specified presenter.

 If no presenter is specified, the operation will inspect the current key window and use it's root view controller (resolving UINavigationContoller and UITabBarController instances to their visible or selected view controllers).

 @param title     the alert's title
 @param message   the alert's message
 @param style     the alert's preferred style
 @param actions   alert actions.
 @param presenter       the presenting view controller or nil to let the operation find a suitable view controller for presentation.

 @return a new operation
 */
+ (nonnull instancetype)  operationForAlertWithTitle:(nullable NSString *)title
                                             message:(nullable NSString *)message
                                      preferredStyle:(UIAlertControllerStyle)style
                                             actions:(nullable NSArray<UIAlertAction *> *)actions
                                 presentationContext:(nullable UIViewController*)presenter;

/**
 Creates a new operation presenting a new alert controller configured with the specified parameters and adds the operation to the main operation queue.

 If no presenter is specified, the operation will inspect the current key window and use it's root view controller (resolving UINavigationContoller and UITabBarController instances to their visible or selected view controllers).

 @param title     the alert's title
 @param message   the alert's message
 @param style     the alert's preferred style
 @param actions   alert actions.
 @param presenter       the presenting view controller or nil to let the operation find a suitable view controller for presentation.

 @return the new operation
 */
+ (nonnull AKAAlertOperation*) presentAlertWithTitle:(nullable NSString*)title
                                             message:(nullable NSString*)message
                                      preferredStyle:(UIAlertControllerStyle)style
                                             actions:(nullable NSArray<UIAlertAction*>*)actions
                                 presentationContext:(nullable UIViewController*)presenter;

+ (nonnull AKAAlertOperation*)presentAlertController:(nonnull UIAlertController*)alertController
                                 presentationContext:(nullable UIViewController*)presenter;

#pragma mark - Configuration

/**
 The alert controller's title. The effect of setting this property once the operation has been added to an operation queue is undefined.
 */
@property(nonatomic, nullable) NSString*             alertTitle;

/**
 The alert controller's message. The effect of setting this property once the operation has been added to an operation queue is undefined.
 */
@property(nonatomic, nullable) NSString*             alertMessage;

/**
 The alert controller's actions.
 */
@property(nonatomic, readonly, nullable) NSArray<UIAlertAction*>* alertActions;

/**
 Adds the specified action to the alert controller. The effect of adding an action once the operation has been added to an operation queue is undefined.

 @param action the alert action to add to the alert controller.
 */
- (void)                                   addAction:(nonnull UIAlertAction*)action;

@end
