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

@interface AKAAlertOperation()

@property(nonatomic, readonly, nonnull) UIAlertController* alertController;

@end


@implementation AKAAlertOperation

#pragma mark - Initialization

+ (instancetype)operationForController:(UIAlertController *)alertController
                   presentationContext:(id)presenter
{
    AKAAlertOperation* result = [[AKAAlertOperation alloc] initWithViewController:alertController
                                                               presentationContext:presenter];
    return result;
}

+ (AKAAlertOperation*)operationForAlertWithTitle:(NSString *)title
                                         message:(NSString *)message
                                  preferredStyle:(UIAlertControllerStyle)style
                                         actions:(NSArray<UIAlertAction *> *)actions
                             presentationContext:(id)presenter
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:style];
    for (UIAlertAction* action in actions)
    {
        [alertController addAction:action];
    }

    return [AKAAlertOperation operationForController:alertController
                                 presentationContext:presenter];
}

+ (AKAAlertOperation*)presentAlertController:(UIAlertController *)alertController
                         presentationContext:(id)presenter
{
    AKAAlertOperation* operation = [AKAAlertOperation operationForController:alertController
                                                         presentationContext:presenter];
    if (operation)
    {
        [operation addToOperationQueue:[NSOperationQueue mainQueue]];
    }
    return operation;
}

+ (AKAAlertOperation*)presentAlertWithTitle:(NSString *)title
                                    message:(NSString *)message
                             preferredStyle:(UIAlertControllerStyle)style
                                    actions:(NSArray<UIAlertAction *> *)actions
                        presentationContext:(id)presenter
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:style];
    for (UIAlertAction* action in actions)
    {
        [alertController addAction:action];
    }

    return [self presentAlertController:alertController presentationContext:presenter];
}

- (instancetype)initWithViewController:(UIAlertController *)alertController
                   presentationContext:(id)presenter
{
    if (self = [super initWithViewController:alertController
                         presentationContext:presenter])
    {
        [self addCondition:[AKAAlertControllerCondition new]];
    }
    return self;
}

- (BOOL)shouldMonitorPresentedViewControllersLifeCycleEvents
{
    return YES;
}

#pragma mark - Name

- (NSString *)name
{
    NSString* result = [super name];
    if (result.length == 0)
    {
        NSString* title = self.alertTitle.length == 0 ? @"" : [NSString stringWithFormat:@" Title=\"%@\"", self.alertTitle];
        NSString* message = self.alertMessage.length == 0 ? @"" : [NSString stringWithFormat:@" Message=\"%@\"", self.alertMessage];
        NSString* actions = @"";
        for (UIAlertAction* action in self.alertActions)
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

- (BOOL)tryUpdateConfigurationUsingBlock:(void(^)())block
{
    __block BOOL result = NO;
    [self performSynchronizedBlock:^{
        block();
        result = YES;
    }
           ifCurrentStateSatisfies:^BOOL(AKAOperationState state) {
               return state < AKAOperationStatePending;
           }];
    return result;
}

- (NSString *)alertTitle
{
    return self.alertController.title;
}

- (void)setAlertTitle:(NSString *)alertTitle
{
    [self tryUpdateConfigurationUsingBlock:^{ self.alertController.title = alertTitle; }];
}

- (NSString *)alertMessage
{
    return self.alertController.message;
}

- (void)setAlertMessage:(NSString *)alertMessage
{
    [self tryUpdateConfigurationUsingBlock:^{ self.alertController.message = alertMessage; }];
}

- (NSArray<UIAlertAction *> *)alertActions
{
    return self.alertController.actions;
}

- (void)addAction:(UIAlertAction *)action
{
    [self tryUpdateConfigurationUsingBlock:^{ [self.alertController addAction:action]; }];
}

@end
