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
 Creates a new operation presenting a new alert controller configured with the specified parameters.

 @param title           the alert's title
 @param message         the alert's message

 @note To show the alert, call -[present] on the operation or add it to the main operation queue.
 @note The alert will be presented from a new window on top of all existing windows.
 @note If another alert operation is active, the operation will be enqueued.

 @return the new operation
 */
+ (nonnull AKAAlertOperation*)       alertWithTitle:(nullable NSString*)title
                                            message:(nullable NSString*)message;

/**
 Creates a new operation presenting a new action sheet alert controller configured with the specified parameters.

 @note To show the action sheet, call -[present] on the operation or add it to the main operation queue.

 @param title           the alert's title
 @param message         the alert's message
 @param presenter       the presenting view controller.
 @param barButtonItem   the bar button item to use as popover anchor

 @return the new operation
 */
+ (nonnull AKAAlertOperation*) actionSheetWithTitle:(nullable NSString*)title
                                            message:(nullable NSString*)message
                                 fromViewController:(nonnull UIViewController*)presenter
                                      barButtonItem:(nonnull UIBarButtonItem*)barButtonItem;

/**
 Creates a new operation presenting a new action sheet alert controller configured with the specified parameters.

 To show the action sheet, call -[present] on the operation or add it to the main operation queue.

 The operation will use the sourceView's bounds as source rectangle.

 @param title     the alert's title
 @param message   the alert's message
 @param presenter the presenting view controller.
 @param sourceView the view used as anchor for popover presentation.

 @return the new operation
 */
+ (nonnull AKAAlertOperation*) actionSheetWithTitle:(nullable NSString*)title
                                            message:(nullable NSString*)message
                                 fromViewController:(nonnull UIViewController*)presenter
                                         sourceView:(nonnull UIView*)sourceView;

/**
 Creates a new operation presenting a new action sheet alert controller configured with the specified parameters and adds the operation to the main operation queue.

 @param title     the alert's title
 @param message   the alert's message
 @param presenter the presenting view controller.
 @param sourceView the view used as anchor for popover presentation.
 @param sourceRect the source rectangle to use for popover presentation.

 @return the new operation
 */
+ (nonnull AKAAlertOperation*) actionSheetWithTitle:(nullable NSString*)title
                                            message:(nullable NSString*)message
                                 fromViewController:(nonnull UIViewController*)presenter
                                         sourceView:(nonnull UIView*)sourceView
                                         sourceRect:(CGRect)sourceRect;

/**
 Creates a new operation presenting a new action sheet alert controller configured with the specified parameters and adds the operation to the main operation queue.

 @param title     the alert's title
 @param message   the alert's message
 @param presenter the presenting view controller.
 @param sender    a view or bar button item used as anchor for popover presentation

 @return the new operation
 */
+ (nonnull AKAAlertOperation*) actionSheetWithTitle:(nullable NSString*)title
                                            message:(nullable NSString*)message
                                 fromViewController:(nonnull UIViewController*)presenter
                                             sender:(nullable id)sender;


#pragma mark - Presentation

- (void)present;

#pragma mark - Configuration

@property(nonatomic, readonly, nonnull) UIAlertController* alertController;

#pragma mark - Fluent Configuration

@property(nonatomic, readonly, nonnull, getter=setTitle)
    AKAAlertOperation*_Nonnull (^setTitle)(NSString*_Nonnull title);

@property(nonatomic, readonly, nonnull, getter=setMessage)
    AKAAlertOperation*_Nonnull (^setMessage)(NSString*_Nonnull message);

@property(nonatomic, readonly, nonnull)
    AKAAlertOperation*_Nonnull (^ addAction)(NSString*_Nonnull actionTitle, void(^_Nullable block)(UIAlertAction*_Nonnull action));

@property(nonatomic, readonly, nonnull)
    AKAAlertOperation*_Nonnull (^ addCancelAction)(NSString*_Nonnull actionTitle, void(^_Nullable action)(UIAlertAction*_Nonnull action));

@property(nonatomic, readonly, nonnull)
    AKAAlertOperation*_Nonnull (^ addDestructiveAction)(NSString*_Nonnull actionTitle, void(^_Nullable action)(UIAlertAction*_Nonnull action));

@end
