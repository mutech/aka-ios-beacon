//
//  AKAAlertOperation.m
//  AKABeacon
//
//  Created by Michael Utech on 02.09.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAAlertOperation.h"
#import "AKAOperation_Internal.h"


#pragma mark - AKAAlertControllerCondition
#pragma mark -

@interface AKAAlertControllerCondition: AKAOperationCondition
@end

@implementation AKAAlertControllerCondition

+ (BOOL)isMutuallyExclusive
{
    return YES;
}

- (void)evaluateForOperation:(AKAOperation *__unused)operation
                  completion:(void (^)(BOOL, NSError * _Nullable))completion
{
    completion(YES, nil);
}

@end


#pragma mark - AKAAlertOperation
#pragma mark -

@implementation AKAAlertOperation

#pragma mark - Initialization

+ (UIAlertController*) alertControllerWithTitle:(NSString *)title
                                        message:(NSString *)message
                                 preferredStyle:(UIAlertControllerStyle)style
                                        actions:(NSArray<UIAlertAction*>*)actions
{
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:title
                                                                        message:message
                                                                 preferredStyle:style];
    for (UIAlertAction* action in actions)
    {
        [controller addAction:action];
    }

    return controller;
}

+ (AKAAlertOperation *)          alertWithTitle:(NSString *)title
                                        message:(NSString *)message
{
    UIAlertController* controller = [self alertControllerWithTitle:title
                                                           message:message
                                                    preferredStyle:UIAlertControllerStyleAlert
                                                           actions:nil];
    AKAAlertOperation* result = [[AKAAlertOperation alloc] initWithViewController:controller];

    return result;
}

+ (AKAAlertOperation *)    actionSheetWithTitle:(NSString *)title
                                        message:(NSString *)message
                             fromViewController:(UIViewController *)presenter
                                  barButtonItem:(UIBarButtonItem *)barButtonItem
{
    UIAlertController* controller = [self alertControllerWithTitle:title
                                                           message:message
                                                    preferredStyle:UIAlertControllerStyleActionSheet
                                                           actions:nil];
    AKAAlertOperation* result = [[AKAAlertOperation alloc] initWithViewController:controller
                                 presentingViewController:presenter
                                 barButtonItem:barButtonItem];

    return result;
}

+ (AKAAlertOperation *)    actionSheetWithTitle:(NSString *)title
                                        message:(NSString *)message
                             fromViewController:(UIViewController *)presenter
                                     sourceView:(UIView *)sourceView
{
    UIAlertController* controller = [self alertControllerWithTitle:title
                                                           message:message
                                                    preferredStyle:UIAlertControllerStyleActionSheet
                                                           actions:nil];
    AKAAlertOperation* result = [[AKAAlertOperation alloc] initWithViewController:controller
                                                         presentingViewController:presenter
                                                                       sourceView:sourceView];
    
    return result;
}

+ (AKAAlertOperation *)    actionSheetWithTitle:(NSString *)title
                                        message:(NSString *)message
                             fromViewController:(UIViewController *)presenter
                                     sourceView:(UIView *)sourceView
                                     sourceRect:(CGRect)sourceRect
{
    UIAlertController* controller = [self alertControllerWithTitle:title
                                                           message:message
                                                    preferredStyle:UIAlertControllerStyleActionSheet
                                                           actions:nil];
    AKAAlertOperation* result = [[AKAAlertOperation alloc] initWithViewController:controller
                                                         presentingViewController:presenter
                                                                       sourceView:sourceView
                                                                       sourceRect:sourceRect];

    return result;
}

+ (AKAAlertOperation *)    actionSheetWithTitle:(NSString *)title
                                        message:(NSString *)message
                             fromViewController:(UIViewController *)presenter
                                         sender:(id)sender
{
    AKAAlertOperation* result = nil;
    if ([sender isKindOfClass:[UIView class]])
    {
        result = [self actionSheetWithTitle:title
                                    message:message
                         fromViewController:presenter
                                 sourceView:(UIView*)sender];
    }
    else if ([sender isKindOfClass:[UIBarButtonItem class]])
    {
        result = [self actionSheetWithTitle:title
                                    message:message
                         fromViewController:presenter
                              barButtonItem:(UIBarButtonItem*)sender];
    }
    else if (presenter != nil)
    {
        result = [self actionSheetWithTitle:title
                                    message:message
                         fromViewController:presenter
                                 sourceView:presenter.view];
    }
    return result;
}

- (instancetype)initWithViewController:(UIAlertController *)alertController
{
    if (self = [super initWithViewController:alertController])
    {
        [self addCondition:[AKAAlertControllerCondition new]];
    }
    return self;
}

- (BOOL)shouldMonitorPresentedViewControllersLifeCycleEvents
{
    return YES;
}

#pragma mark - Presentation

- (void)present
{
    [self addToOperationQueue:[NSOperationQueue mainQueue]];
}

#pragma mark - Fluent Configuration

- (AKAAlertOperation *(^)(NSString *))setTitle
{
    return ^AKAAlertOperation*(NSString* title) {
        self.alertController.title = title;
        return self;
    };
}

- (AKAAlertOperation *(^)(NSString *))setMessage
{
    return ^AKAAlertOperation*(NSString* message) {
        self.alertController.message = message;
        return self;
    };
}

- (AKAAlertOperation *(^)(NSString *, void (^block)(UIAlertAction*_Nonnull)))addAction
{
    return ^AKAAlertOperation*(NSString* title, void(^block)()) {
        UIAlertAction* action = [UIAlertAction actionWithTitle:title
                                                         style:UIAlertActionStyleDefault
                                                       handler:block];
        [self.alertController addAction:action];
        return self;
    };
}

- (AKAAlertOperation *(^)(NSString *, void (^block)(UIAlertAction*_Nonnull)))addCancelAction
{
    return ^AKAAlertOperation*(NSString* title, void(^block)()) {
        UIAlertAction* action = [UIAlertAction actionWithTitle:title
                                                         style:UIAlertActionStyleCancel
                                                       handler:block];
        [self.alertController addAction:action];
        return self;
    };
}

- (AKAAlertOperation *(^)(NSString *, void (^block)(UIAlertAction*_Nonnull)))addDestructiveAction
{
    return ^AKAAlertOperation*(NSString* title, void(^block)()) {
        UIAlertAction* action = [UIAlertAction actionWithTitle:title
                                                         style:UIAlertActionStyleDestructive
                                                       handler:block];
        [self.alertController addAction:action];
        return self;
    };
}

#pragma mark - Name

- (NSString *)name
{
    NSString* result = [super name];
    if (result.length == 0)
    {
        NSString* title = self.alertController.title.length == 0 ? @"" : [NSString stringWithFormat:@" Title=\"%@\"", self.alertController.title];
        NSString* message = self.alertController.message.length == 0 ? @"" : [NSString stringWithFormat:@" Message=\"%@\"", self.alertController.message];
        NSString* actions = @"";
        for (UIAlertAction* action in self.alertController.actions)
        {
            if (actions.length == 0)
            {
                actions = [NSString stringWithFormat:@" Actions=\"%@\"", action.title];
            }
            else
            {
                actions = [NSString stringWithFormat:@"%@, \"%@\"", actions, action.title];
            }
        }
        result = [NSString stringWithFormat:
                  @"%@:%@%@%@",
                  NSStringFromClass(self.class),
                  title,
                  message,
                  actions];
    }
    return result;
}

#pragma mark - Configuration

- (UIAlertController *)alertController
{
    NSAssert(self.viewController == nil || [self.viewController isKindOfClass:[UIAlertController class]], nil);
    return (UIAlertController*)self.viewController;
}

@end
