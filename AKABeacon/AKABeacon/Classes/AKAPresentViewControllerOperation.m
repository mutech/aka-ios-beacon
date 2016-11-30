//
//  AKAPresentViewControllerOperation.m
//  AKABeacon
//
//  Created by Michael Utech on 03.09.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAPresentViewControllerOperation.h"
#import "AKAOperation_Internal.h"
#import "AKAOperationErrors.h"
#import "NSObject+AKAConcurrencyTools.h"


#pragma mark - AKAVCLifeCycleNotificationBehavior
#pragma mark -

@interface AKAVCLifeCycleNotificationBehavior()

@property(nonatomic, weak) UIViewController* previousParentViewController;

@end

@implementation AKAVCLifeCycleNotificationBehavior

#pragma mark - Initialization

+ (nonnull AKAVCLifeCycleNotificationBehavior*)addToController:(UIViewController*)controller withDelegate:(nonnull id<AKAVCLifeCycleNotificationBehaviorDelegate>)delegate
{
    AKAVCLifeCycleNotificationBehavior* behavior =
        [[AKAVCLifeCycleNotificationBehavior alloc] initWithDelegate:delegate];
    [controller addChildViewController:behavior];
    [controller.view addSubview:behavior.view];
    [behavior didMoveToParentViewController:controller];
    return behavior;
}

- (void)removeFromController:(UIViewController *)controller
{
    NSParameterAssert(controller == self.parentViewController);

    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (nonnull instancetype)initWithDelegate:(nonnull id<AKAVCLifeCycleNotificationBehaviorDelegate>)delegate
{
    if (self = [super init])
    {
        _controllerState = AKAViewControllerLifeCycleStateUnknown;
        _delegate = delegate;
        self.view.alpha = 0.0;
    }
    return self;
}

#pragma mark - Life Cycle Events


- (void)willMoveToParentViewController:(UIViewController *)parent
{
    self.previousParentViewController = self.parentViewController;
    [super willMoveToParentViewController:parent];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    id<AKAVCLifeCycleNotificationBehaviorDelegate> delegate = self.delegate;
    if (parent)
    {
        if ([delegate respondsToSelector:@selector(notificationBehavior:didStartObservingEventsForController:)])
        {
            [delegate notificationBehavior:self didStartObservingEventsForController:parent];
        }
    }
    else
    {
        if ([delegate respondsToSelector:@selector(notificationBehavior:didStopObservingEventsForController:)])
        {
            [delegate notificationBehavior:self didStopObservingEventsForController:self.previousParentViewController];
        }
        self.previousParentViewController = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _controllerState = AKAViewControllerLifeCycleStateDidLoad;
    id<AKAVCLifeCycleNotificationBehaviorDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(viewControllerViewDidLoad:)])
    {
        [delegate viewControllerViewDidLoad:self.parentViewController];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _controllerState = AKAViewControllerLifeCycleStateWillAppear;
    id<AKAVCLifeCycleNotificationBehaviorDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(viewController:viewWillAppear:)])
    {
        [delegate viewController:self.parentViewController viewWillAppear:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _controllerState = AKAViewControllerLifeCycleStateDidAppear;
    id<AKAVCLifeCycleNotificationBehaviorDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(viewController:viewDidAppear:)])
    {
        [delegate viewController:self.parentViewController viewDidAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    UIViewController* parentViewController = self.parentViewController;

    [super viewWillDisappear:animated];
    _controllerState = AKAViewControllerLifeCycleStateWillDisapear;
    id<AKAVCLifeCycleNotificationBehaviorDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(viewController:viewWillDisappear:)])
    {
        [delegate viewController:parentViewController viewWillDisappear:animated];
    }

    if (self.isMovingFromParentViewController ||
        self.isBeingDismissed ||
        parentViewController.isBeingDismissed)
    {
        _controllerState = AKAViewControllerLifeCycleStateWillBeDismissed;
        if ([delegate respondsToSelector:@selector(viewControllerWillBeDismissed:)])
        {
            [delegate viewControllerWillBeDismissed:parentViewController];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    UIViewController* parentViewController = self.parentViewController;

    [super viewDidDisappear:animated];
    _controllerState = AKAViewControllerLifeCycleStateDidDisapear;
    id<AKAVCLifeCycleNotificationBehaviorDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(viewController:viewDidDisappear:)])
    {
        [delegate viewController:parentViewController viewDidDisappear:animated];
    }

    if (self.controllerState ==  AKAViewControllerLifeCycleStateDidDisapear ||
        self.isMovingFromParentViewController ||
        self.isBeingDismissed ||
        parentViewController.isBeingDismissed)
    {
        _controllerState = AKAViewControllerLifeCycleStateHasBeenDismissed;
        if ([delegate respondsToSelector:@selector(viewControllerHasBeenDismissed:)])
        {
            [delegate viewControllerHasBeenDismissed:parentViewController];
        }
    }
}

@end


#pragma mark - AKAPresentViewControllerOperation
#pragma mark -


@interface AKAPresentViewControllerOperation()

@property(nonatomic, readwrite, nullable, weak) id presenter;

@property(nonatomic) AKAVCLifeCycleNotificationBehavior* notifyBehavior;

@property(nonatomic) UIWindow* presentationWindow;
@property(nonatomic, weak) UIWindow* originalKeyWindow;

@end


@implementation AKAPresentViewControllerOperation

#pragma mark - Initialization

- (instancetype)initWithViewController:(UIViewController *)viewController
                   presentationContext:(UIViewController *)presenter
{
    if (self = [super init])
    {
        _viewController = viewController;
        _presenter = presenter;
        if ([self shouldMonitorPresentedViewControllersLifeCycleEvents])
        {
            [AKAVCLifeCycleNotificationBehavior addToController:self.viewController
                                                   withDelegate:self];
        }
    }
    return self;
}

+ (instancetype)operationForController:(UIViewController *)viewController presentationContext:(UIViewController *)presenter
{
    return [[AKAPresentViewControllerOperation alloc] initWithViewController:viewController
                                                         presentationContext:presenter];
}

#pragma mark - Configuration

- (BOOL)shouldCreatePresentationWindow
{
    return YES;
}

- (BOOL)shouldMonitorPresentedViewControllersLifeCycleEvents
{
    return YES;
}

#pragma mark - Execution

- (void)execute
{
    [self aka_performBlockInMainThreadOrQueue:^{
        [self createPresentationWindowIfNeeded];
        UIViewController* presenter = [self presenterInContext:self.presenter];
        if (self->_presenter == nil)
        {
            self->_presenter = presenter;
        }

        if (presenter)
        {
            if (self.popoverAnchor)
            {
                UIPopoverPresentationController* popoverPresenter = self.viewController.popoverPresentationController;
                popoverPresenter.sourceView = self.popoverAnchor;
                popoverPresenter.sourceRect = self.popoverAnchor.bounds;
            }
            [presenter presentViewController:self.viewController
                                    animated:YES
                                  completion:nil];
        }
        else
        {
            [self cancelWithError:[AKAOperationErrors presentViewControllerOperationFailedNoPresenter:self]];
        }
    } waitForCompletion:NO];
}

- (void)finish
{
    [self aka_performBlockInMainThreadOrQueue:^{
        [self.notifyBehavior removeFromController:self.viewController];
        self.notifyBehavior = nil;

        // Typically, finish has been called as a result of the view controller being dismissed.
        // This only covers cases where the operation has been manually finished.
        [self.viewController.presentingViewController dismissViewControllerAnimated:YES
                                                                         completion:NULL];

        // TODO: this might disrupt the dismissal animation:
        [self removePresentationWindow];

        // Ensure that finish is called after the presentation windows has been removed.
        [super finish];

    } waitForCompletion:NO];
}

#pragma mark - Alert Controller View Life Cycle Notifications

- (void)notificationBehavior:(AKAVCLifeCycleNotificationBehavior *)behavior didStartObservingEventsForController:(UIViewController *)controller
{
    NSParameterAssert(controller == self.viewController);
    self.notifyBehavior = behavior;
}

- (void)viewController:(UIViewController *__unused)viewController
        viewWillAppear:(BOOL __unused)animated
{
    if (!self.isCancelled)
    {
        if (!self.isExecuting)
        {
            // UIAlertController will appear but operation is not executing.
            [self cancel];
            [self finish];
        }
    }
}

- (void)viewController:(UIViewController *__unused)viewController
         viewDidAppear:(BOOL __unused)animated
{
    if (!self.isCancelled)
    {
        if (!self.isExecuting)
        {
            // UIAlertController will appear but operation is not executing.
            [self cancel];
            [self finish];
        }
    }
}

- (void)viewControllerHasBeenDismissed:(UIViewController *__unused)viewController
{
    if (!self.isCancelled && self.isExecuting)
    {
        // UIAlertController did disappear while operation was in executing state, finish it
        // to ensure it's not left dangling around and blocking it's queue
        [self finish];
    }
}

- (void)notificationBehavior:(AKAVCLifeCycleNotificationBehavior *)behavior didStopObservingEventsForController:(UIViewController *)controller
{
    NSParameterAssert(behavior == self.notifyBehavior);
    NSParameterAssert(controller == nil || controller == self.viewController);
    [self cancel];
    if (self.viewController.presentingViewController == self.presenter &&
        self.presenter != nil)
    {
        [self.presenter dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Implementation

- (void)createPresentationWindowIfNeeded
{
    if (self.presenter == nil && self.presentationWindow == nil && [self shouldCreatePresentationWindow])
    {
        UIApplication* app = [UIApplication sharedApplication];
        self.originalKeyWindow = app.keyWindow;

        CGFloat maxWindowLevel = 0;
        for (UIWindow* window in app.windows)
        {
            if (window.windowLevel > maxWindowLevel)
            {
                maxWindowLevel = window.windowLevel;
            }
        }

        self.presentationWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.presentationWindow.windowLevel = maxWindowLevel + 1.0;
        self.presentationWindow.rootViewController = [UIViewController new];
        //self.presentationWindow.rootViewController.view.alpha = 0.0;
        
        self.presenter = self.presentationWindow.rootViewController;

        [self.presentationWindow makeKeyAndVisible];
    }
}

- (void)removePresentationWindow
{
    if (self.presentationWindow)
    {
        [self.presentationWindow.rootViewController dismissViewControllerAnimated:NO completion:NULL];
        self.presentationWindow.hidden = YES;
        self.presentationWindow = nil;

        /*
        if (self.originalKeyWindow && !self.originalKeyWindow.isKeyWindow)
        {
            [self.originalKeyWindow makeKeyWindow];
        }
        */
    }
}

- (UIViewController*)presenterInContext:(id)presentationContext
{
    UIViewController* result = nil;
    if (presentationContext == nil)
    {
        result = [self presenterInContext:[UIApplication sharedApplication].keyWindow.rootViewController];
    }
    else if ([presentationContext isKindOfClass:[UINavigationController class]])
    {
        result = [self presenterInContext:[(UINavigationController*)presentationContext visibleViewController]];
    }
    else if ([presentationContext isKindOfClass:[UITabBarController class]])
    {
        result = [self presenterInContext:[(UITabBarController*)presentationContext selectedViewController]];
    }
    else if ([presentationContext isKindOfClass:[UIViewController class]])
    {
        result = presentationContext;
    }
    else if ([presentationContext isKindOfClass:[UIView class]])
    {
        UIView* view = presentationContext;
        _popoverAnchor = view;
        for (UIResponder* responder = view.nextResponder; responder; responder = responder.nextResponder)
        {
            if ([responder isKindOfClass:[UIViewController class]])
            {
                result = (id)responder;
                break;
            }
        }
    }

    return result;
}

@end
