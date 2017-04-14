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


#pragma mark - AKAPresentViewControllerOperation (Private Interface)
#pragma mark -


@interface AKAPresentViewControllerOperation()

@property(nonatomic, nullable, weak) UIViewController*      presentingViewController;
@property(nonatomic, readonly, weak) UIView*                sourceView;
@property(nonatomic, readonly) CGRect                       sourceRect;
@property(nonatomic, readonly, weak) UIBarButtonItem*       barButtonItem;

@property(nonatomic) AKAVCLifeCycleNotificationBehavior*    notifyBehavior;

@property(nonatomic) UIWindow*                              presentationWindow;

@end


#pragma mark - AKAPresentViewControllerOperation (Implementation)
#pragma mark -

@implementation AKAPresentViewControllerOperation

#pragma mark - Initialization

- (instancetype)                      initWithViewController:(UIViewController *)viewController
{
    if (self = [super init])
    {
        _viewController = viewController;
        if ([self shouldMonitorPresentedViewControllersLifeCycleEvents])
        {
            [AKAVCLifeCycleNotificationBehavior addToController:self.viewController
                                                   withDelegate:self];
        }
    }
    return self;
}

- (instancetype)                      initWithViewController:(UIViewController *)viewController
                                    presentingViewController:(UIViewController *)presenter
{
    if (self = [self initWithViewController:viewController])
    {
        _presentingViewController = presenter;
    }
    return self;
}

- (instancetype)                      initWithViewController:(UIViewController *)viewController
                                    presentingViewController:(UIViewController *)presenter
                                                  sourceView:(UIView *)sourceView
                                                  sourceRect:(CGRect)sourceRect
{
    if (self = [self initWithViewController:viewController presentingViewController:presenter])
    {
        _sourceView = sourceView;
        _sourceRect = sourceRect;
    }
    return self;
}

- (instancetype)                      initWithViewController:(UIViewController*)viewController
                                    presentingViewController:(UIViewController*)presenter
                                                  sourceView:(UIView*)sourceView
{
    self = [self initWithViewController:viewController
               presentingViewController:presenter
                             sourceView:sourceView
                             sourceRect:sourceView.bounds];
    return self;
}

- (nonnull instancetype)              initWithViewController:(UIViewController*)viewController
                                    presentingViewController:(UIViewController*)presenter
                                               barButtonItem:(UIBarButtonItem*)popoverAnchor
{
    if (self = [self initWithViewController:viewController presentingViewController:presenter])
    {
        _barButtonItem = popoverAnchor;
    }
    return self;
}

#pragma mark - Configuration

- (BOOL)                      shouldCreatePresentationWindow
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
        UIViewController* presenter = [self presenterInContext:self.presentingViewController];
        if (self.presentingViewController == nil)
        {
            self.presentingViewController = presenter;
        }
        
        if (presenter)
        {
            [presenter presentViewController:self.viewController
                                    animated:YES
                                  completion:nil];
            if (self.viewController.modalPresentationStyle == UIModalPresentationPopover)
            {
                UIPopoverPresentationController* popoverPresenter = self.viewController.popoverPresentationController;

                if (self.barButtonItem)
                {
                    popoverPresenter.barButtonItem = self.barButtonItem;
                }
                else if (self.sourceView)
                {
                    popoverPresenter.sourceView = self.sourceView;
                    popoverPresenter.sourceRect = self.sourceRect;
                }
            }
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

        // TODO: handle direct calls to -[finish] seperate from UI triggered dismissal of presented view

        // Remove this first to decrease likelyhood of interference from view events if finish was
        // called directly.
        [self.notifyBehavior removeFromController:self.viewController];
        self.notifyBehavior = nil;

        // Dismiss view controller if finish was called directly (otherwise the
        [self.viewController.presentingViewController dismissViewControllerAnimated:YES
                                                                         completion:NULL];

        // TODO: this might disrupt the dismissal animation:
        [self removePresentationWindow];

        // Ensure that finish is called after the presentation windows has been removed.
        [super finish];

    } waitForCompletion:NO];
}

#pragma mark - Implementation

- (void)createPresentationWindowIfNeeded
{
    if (self.presentingViewController == nil &&
        self.presentationWindow == nil &&
        [self shouldCreatePresentationWindow])
    {
        UIApplication* app = [UIApplication sharedApplication];

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

        self.presentingViewController = self.presentationWindow.rootViewController;

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

#pragma mark - View Life Cycle Notifications

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
    [self finish];
}

- (void)notificationBehavior:(AKAVCLifeCycleNotificationBehavior *)behavior didStopObservingEventsForController:(UIViewController *)controller
{
    NSParameterAssert(behavior == self.notifyBehavior);
    NSParameterAssert(controller == nil || controller == self.viewController);
    [self cancel];
    if (self.viewController.presentingViewController == self.presentingViewController &&
        self.presentingViewController != nil)
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
