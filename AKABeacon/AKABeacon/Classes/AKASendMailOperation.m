//
//  AKASendMailOperation.m
//  AKABeacon
//
//  Created by Michael Utech on 03.09.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKASendMailOperation.h"
#import "AKAAlertOperation.h"

#pragma mark - AKASendMailOperation
#pragma mark -

@interface AKASendMailOperation() <MFMailComposeViewControllerDelegate>

@property(nonatomic, readonly, nonnull) MFMailComposeViewController* mailComposeController;
@property(nonatomic, readonly, weak) id<MFMailComposeViewControllerDelegate> originalDelegate;

@end


@implementation AKASendMailOperation

+ (instancetype)operationForController:(nonnull MFMailComposeViewController*)controller
                   presentationContext:(nullable UIViewController*)presenter
{
    AKASendMailOperation* result = [[AKASendMailOperation alloc] initWithViewController:controller
                                                                    presentationContext:presenter];
    return result;
}

- (instancetype)initWithViewController:(nonnull MFMailComposeViewController*)viewController
                   presentationContext:(UIViewController *)presenter
{
    if ([MFMailComposeViewController canSendMail])
    {
        if (self = [super initWithViewController:viewController
                        presentingViewController:presenter])
        {
            _mailComposeResult = (MFMailComposeResult)NSNotFound;

            _originalDelegate = viewController.mailComposeDelegate;
            viewController.mailComposeDelegate = self;
        }
    }
    else
    {
        self = nil;
    }
    return self;
}

#pragma mark - Configuration

- (BOOL)shouldMonitorPresentedViewControllersLifeCycleEvents
{
    return NO;
}

- (MFMailComposeViewController *)mailComposeController
{
    return (MFMailComposeViewController*)self.viewController;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    NSParameterAssert(controller == self.mailComposeController);
    NSParameterAssert(result == MFMailComposeResultFailed ? error != nil : error == nil);

    id<MFMailComposeViewControllerDelegate> originalDelegate = self.originalDelegate;
    if ([originalDelegate respondsToSelector:@selector(mailComposeController:didFinishWithResult:error:)])
    {
        [originalDelegate mailComposeController:controller didFinishWithResult:result error:error];
    }

    _mailComposeResult = result;
    if (error)
    {
        [self addError:error];
    }

    if (controller.presentingViewController &&
        controller.presentingViewController.presentedViewController == controller)
    {
        [self.presenter dismissViewControllerAnimated:YES completion:^{
            [self viewControllerHasBeenDismissed:controller];
        }];
    }
    else
    {
        [controller dismissViewControllerAnimated:YES completion:^{
            [self viewControllerHasBeenDismissed:controller];
        }];
    }
}

@end
