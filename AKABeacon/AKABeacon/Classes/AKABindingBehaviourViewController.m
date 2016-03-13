//
//  AKABindingBehaviourViewController.m
//  AKABeacon
//
//  Created by Michael Utech on 13.03.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.UIView_AKAHierarchyVisitor;

#import "AKABindingBehaviourViewController.h"
#import "AKAEditorControlView.h"
#import "AKAFormControl.h"
#import "AKADelegateDispatcher.h"


@interface AKABindingBehaviourDelegateDispatcher : AKADelegateDispatcher<AKABindingBehaviourDelegate>

- (instancetype)initWithBehaviour:(AKABindingBehaviourViewController*)behaviour
                         delegate:(id<AKABindingBehaviourDelegate>)delegate;

@property(nonatomic, weak, readonly) id<AKABindingBehaviourDelegate> delegate;

@end


@implementation AKABindingBehaviourDelegateDispatcher

- (instancetype)initWithBehaviour:(AKABindingBehaviourViewController *)behaviour delegate:(id<AKABindingBehaviourDelegate>)delegate
{
    // The behaviour view controller implements AKAControlDelegate, which is a super protocol of
    // AKABindingBehaviourDelegate. These methods will potentially be overridden by the behaviour
    // view controller (or its sub classes).
    if (self = [self initWithProtocols:@[ @protocol(AKABindingBehaviourDelegate) ]
                             delegates:@[ behaviour, delegate]])
    {
        _delegate = delegate;
    }
    return self;
}

@end


@interface AKABindingBehaviourViewController() <AKAControlDelegate>

@property(nonatomic) AKABindingBehaviourDelegateDispatcher* delegateDispatcher;

@property(nonatomic, weak) UIResponder*     activeResponder;

@property(nonatomic) double                 aka_keyboardAdjustment;
@property(nonatomic) double                 aka_rotationAnimationDuration;
@property(nonatomic) UIViewAnimationCurve   aka_rotationAnimationCurve;

@end


@implementation AKABindingBehaviourViewController

#pragma mark - Initialization

+ (void)addToViewController:(UIViewController *)viewController
{
    AKABindingBehaviourViewController* bindingBehaviour = [AKABindingBehaviourViewController new];

    [bindingBehaviour addToViewController:viewController];
}

- (void)addToViewController:(UIViewController*)viewController
{
    [viewController addChildViewController:self];
    [viewController.view addSubview:self.view];
    [self didMoveToParentViewController:viewController];
}

- (void)removeFromViewController:(UIViewController*)viewController
{
    NSParameterAssert(viewController == self.parentViewController);

    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.view.alpha = 0.0;
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if ([parent conformsToProtocol:@protocol(AKABindingBehaviourDelegate)])
    {
        id<AKABindingBehaviourDelegate> delegate = (id)parent;
        _delegateDispatcher = [[AKABindingBehaviourDelegateDispatcher alloc] initWithBehaviour:self
                                                                                      delegate:delegate];
    }
    _formControl = [[AKAFormControl alloc] initWithDataContext:parent
                                                      delegate:self.delegateDispatcher];
    [self initializeFormControl];
}

- (void)                                    viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self startObservingKeyboardEvents];
    [self activateFormControlBindings];
}

- (void)                                 viewWillDisappear:(BOOL)animated
{
    [self deactivateFormControlBindings];
    [self stopObservingKeyboardEvents];

    [super viewWillDisappear:animated];
}

#pragma mark - Properties

- (id<AKABindingBehaviourDelegate>)delegate
{
    return self.delegateDispatcher.delegate;
}

- (UIScrollView *)scrollView
{
    UIViewController* parent = self.parentViewController;
    UIScrollView* result = nil;
    if ([parent respondsToSelector:@selector(scrollView)])
    {
        result = [parent valueForKey:NSStringFromSelector(@selector(scrollView))];
    }
    return result;
}

#pragma mark - Form Control

- (void)                             initializeFormControl
{


    // Setup theme name before adding controls for subviews (TODO: order should not matter)
    [self initializeFormControlTheme];

    [self initializeFormControlMembers];
}

- (void)                        initializeFormControlTheme
{
    [self.formControl setThemeName:@"default" forClass:[AKAEditorControlView class]];
}

- (void)                      initializeFormControlMembers
{
    UIViewController* parent = self.parentViewController;
    [self.formControl addControlsForControlViewsInViewHierarchy:parent.view
                                                   excludeViews:[AKACompositeControl viewsToExcludeFromScanningViewController:parent]];
}

- (void)                       activateFormControlBindings
{
    [self.formControl startObservingChanges];
}

- (void)                     deactivateFormControlBindings
{
    [self.formControl stopObservingChanges];
}

#pragma mark - Form Control Delegate

- (void)                                           control:(req_AKAControl)control
                                                   binding:(req_AKAKeyboardControlViewBinding)binding
                                     responderWillActivate:(req_UIResponder)responder
{
    (void)control;
    (void)binding;

    self.activeResponder = responder;
}

- (void)                                           control:(req_AKAControl)control
                                                   binding:(req_AKAKeyboardControlViewBinding)binding
                                      responderDidActivate:(req_UIResponder)responder
{
    (void)control;
    (void)binding;

    if (!self.activeResponder)
    {
        // There is no guarantee that responderWillActivate will be called, so we might have to do it's job here
        self.activeResponder = responder;
    }
    [self scrollViewToVisible:responder animated:YES];
}

- (void)                                           control:(req_AKAControl)control
                                                   binding:(req_AKAKeyboardControlViewBinding)binding
                                    responderDidDeactivate:(req_UIResponder)responder
{
    (void)control;
    (void)binding;
    (void)responder;

    self.activeResponder = nil;
}

#pragma mark - Keyboard Notifications

- (void)                      startObservingKeyboardEvents
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)                       stopObservingKeyboardEvents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)                          viewWillTransitionToSize:(CGSize)size
                                 withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.aka_rotationAnimationCurve = [context completionCurve];
        self.aka_rotationAnimationDuration = [context transitionDuration];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        (void)context;

        self.aka_rotationAnimationCurve = 0;
        self.aka_rotationAnimationDuration = 0.0;
    }];
}

- (void)                           keyboardWillChangeFrame:(NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];

    CGRect keyboardFrame = ((NSValue*)userInfo[UIKeyboardFrameEndUserInfoKey]).CGRectValue;
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:self.view];
    CGFloat newHeight = keyboardFrame.size.height;
    if (newHeight != 0.0 && [UIKeyboardWillHideNotification isEqualToString:notification.name])
    {
        newHeight = 0.0;
    }

    if (self.aka_rotationAnimationDuration == 0)
    {
        NSTimeInterval duration = ((NSNumber*)userInfo[UIKeyboardAnimationDurationUserInfoKey]).doubleValue;
        if (duration == 0)
        {
            [self adjustViewsForKeyboardHeightChangeTo:newHeight];
        }
        else
        {
            UIViewAnimationCurve curve = ((NSNumber*)userInfo[UIKeyboardAnimationCurveUserInfoKey]).integerValue;
            [self adjustViewsForKeyboardHeightChangeTo:newHeight
                                          withDuration:duration
                                        animationCurve:curve];
        }
    }
    else
    {
        if ([UIView areAnimationsEnabled])
        {
            [self adjustViewsForKeyboardHeightChangeTo:newHeight];
        }
        else
        {
            [UIView setAnimationsEnabled:YES];
            [self adjustViewsForKeyboardHeightChangeTo:newHeight
                                          withDuration:self.aka_rotationAnimationDuration
                                        animationCurve:self.aka_rotationAnimationCurve];
            [UIView setAnimationsEnabled:NO];
        }
    }
}

- (void)              adjustViewsForKeyboardHeightChangeTo:(CGFloat)newHeight
                                              withDuration:(NSTimeInterval)duration
                                            animationCurve:(UIViewAnimationCurve)curve
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];

    [self adjustViewsForKeyboardHeightChangeTo:newHeight];

    [UIView commitAnimations];
}

- (void)              adjustViewsForKeyboardHeightChangeTo:(CGFloat)newHeight
{
    UIScrollView* scrollView = self.scrollView;
    UIEdgeInsets svi = scrollView.contentInset;
    scrollView.contentInset = UIEdgeInsetsMake(svi.top, svi.left,
                                                    svi.bottom + newHeight - (CGFloat)self.aka_keyboardAdjustment,
                                                    svi.right);

    UIEdgeInsets svsii = scrollView.scrollIndicatorInsets;
    scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(svsii.top, svsii.left,
                                                             svsii.bottom + newHeight - (CGFloat)self.aka_keyboardAdjustment,
                                                             svsii.right);

    self.aka_keyboardAdjustment = newHeight;

    [self scrollViewToVisible:self.activeResponder animated:NO];
}

- (void)                               scrollViewToVisible:(UIResponder*)activeResponder animated:(BOOL)animated
{
    UIScrollView* scrollView = self.scrollView;
    if (scrollView)
    {
        if ([activeResponder isKindOfClass:[UIView class]])
        {
            UIView* firstResponder = (UIView*)activeResponder;

            BOOL isIOS9 = ([[[UIDevice currentDevice] systemVersion] compare:@"9.0"
                                                                     options:NSNumericSearch] == NSOrderedAscending);
            BOOL isAutoScrollingControl = [firstResponder isKindOfClass:[UITextField class]];
            UIScrollView* closestScrollView = [firstResponder aka_superviewOfType:[UIScrollView class]];

            // Since  iOS9, textfields automatically scroll to visible, which means that we don't have to do
            // that anymore (thanks), but we can't control it either (thanks) so our "friendlyFrame"
            // computation doesn't work anymore. We could wrap the text field in another disabled scrollview
            // to fix this, but we'll leave out the hacks until it's needed.
            //
            // In the case where there is another scrollview nested in self.scrollView, we still want to do
            // the scrolling.
            if (!(isIOS9 && isAutoScrollingControl) || (scrollView != closestScrollView))
            {
                CGRect friendlyFrame = [self friendlyFrameForFirstResponder:firstResponder];
                CGRect convertedFriendlyFrame = [firstResponder.superview convertRect:friendlyFrame
                                                                               toView:scrollView];

                [scrollView scrollRectToVisible:convertedFriendlyFrame animated:animated];
            }
        }
    }
}

- (CGRect)                  friendlyFrameForFirstResponder:(UIView*)firstResponder
{
    // Include some content above and below, just enough to probably also show at least parts
    // of a label above and a status indicator (error message) below.
    CGRect frame = firstResponder.frame;
    CGRect friendlyFrame = CGRectMake(frame.origin.x,
                                      frame.origin.y -30.0f,
                                      frame.size.width,
                                      frame.size.height + 50.0f);
    return friendlyFrame;
}

@end
