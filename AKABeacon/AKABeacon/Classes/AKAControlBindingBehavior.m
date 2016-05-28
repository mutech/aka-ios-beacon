//
//  AKAControlBindingBehavior.m
//  AKABeacon
//
//  Created by Michael Utech on 24.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

// New and obsolete: Support AKAFormControl based binding behavior until AKAControl's are completely replaced by AKABindingController's and can be removed.

#import "AKAControlBindingBehavior.h"

#import "UIView+AKAHierarchyVisitor.h"

#import "AKABindingBehavior.h"
#import "AKADelegateDispatcher.h"
#import "AKAContentSizeCategoryChangeListener.h"

#import "AKAEditorControlView.h"
#import "AKAFormControl.h"


@interface AKAControlBindingBehaviourDelegateDispatcher : AKADelegateDispatcher<AKAControlBindingBehaviorDelegate>

- (instancetype)initWithBehaviour:(AKAControlBindingBehavior *)behaviour
                         delegate:(id<AKAControlBindingBehaviorDelegate>)delegate;

@property(nonatomic, weak, readonly) id<AKAControlBindingBehaviorDelegate> delegate;

@end

@implementation AKAControlBindingBehaviourDelegateDispatcher

- (instancetype)initWithBehaviour:(AKAControlBindingBehavior *)behaviour delegate:(id<AKAControlBindingBehaviorDelegate>)delegate
{
    // The behaviour view controller implements AKAControlDelegate, which is a super protocol of
    // AKABindingBehaviorDelegate. These methods will potentially be overridden by the behaviour
    // view controller (or its sub classes).
    if (self = [self initWithProtocols:@[ @protocol(AKAControlBindingBehaviorDelegate) ]
                             delegates:@[ behaviour, delegate]])
    {
        _delegate = delegate;
    }
    return self;
}

@end


@interface AKAControlBindingBehavior () <AKAControlDelegate>

@property(nonatomic) AKAFormControl*                        formControl;

@property(nonatomic) AKAControlBindingBehaviourDelegateDispatcher* delegateDispatcher;
@property(nonatomic) NSMutableSet<AKAProperty*>*            observations;

@property(nonatomic, readonly, weak) UIScrollView*          scrollView;
@property(nonatomic, weak) UIResponder*                     activeResponder;
@property(nonatomic) double                                 keyboardAdjustment;
@property(nonatomic) double                                 rotationAnimationDuration;
@property(nonatomic) UIViewAnimationCurve                   rotationAnimationCurve;

@property(nonatomic, readonly) NSHashTable<id<AKAContentSizeCategoryChangeListener>>*
contentSizeCategoryChangeListeners;

@property(nonatomic, readonly) BOOL                         isObservingChanges;

@end


@implementation AKAControlBindingBehavior


#pragma mark - Initialization

+ (void)                                addToViewController:(UIViewController *)viewController
{
    id<AKAControlBindingBehaviorDelegate> delegate = nil;
    if ([viewController conformsToProtocol:@protocol(AKAControlBindingBehaviorDelegate)])
    {
        delegate = (id)viewController;
    }

    [self addToViewController:viewController withDataContext:viewController delegate:delegate];
}


+ (void)                                addToViewController:(UIViewController*)viewController
                                            withDataContext:(id)dataContext
                                                   delegate:(id<AKAControlBindingBehaviorDelegate>)delegate
{
    AKAControlBindingBehavior* behavior = [[AKAControlBindingBehavior alloc] initWithDataContext:dataContext
                                                                          delegate:delegate];
    [behavior addToViewController:viewController];
}

- (instancetype)                        initWithDataContext:(id)dataContext
                                                   delegate:(id<AKAControlBindingBehaviorDelegate>)delegate
{
    if (self = [super init])
    {
        self.view.alpha = 0.0;
        if (delegate)
        {
            self.delegateDispatcher = [[AKAControlBindingBehaviourDelegateDispatcher alloc] initWithBehaviour:self
                                                                                              delegate:delegate];
        }

        self.formControl = [[AKAFormControl alloc] initWithDataContext:dataContext
                                                              delegate:self.delegateDispatcher ? self.delegateDispatcher : self];
    }
    return self;
}

#pragma mark - Activation

- (void)                                addToViewController:(UIViewController*)viewController
{
    [viewController addChildViewController:self];
    [viewController.view addSubview:self.view];
    [self didMoveToParentViewController:viewController];
}

- (void)                           removeFromViewController:(UIViewController*)viewController
{
    NSParameterAssert(viewController == self.parentViewController);

    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

#pragma mark - View Life Cycle

- (void)                     didMoveToParentViewController:(UIViewController*)parent
{
    if (parent != nil)
    {
        [self initializeBindings];
    }
    else
    {
        [self stopObservingContentSizeCategoryEvents];
        [self deactivateBindings];
        [self stopObservingKeyboardEvents];
    }
}

- (void)                                    viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self startObservingChanges];
}

- (void)                                 viewWillDisappear:(BOOL)animated
{
    [self stopObservingChanges];

    [super viewWillDisappear:animated];
}

#pragma mark - Form Control

- (void)                                initializeBindings
{
    // Setup theme name before adding controls for subviews (TODO: order should not matter)
    [self.formControl setThemeName:@"default" forClass:[AKAEditorControlView class]];

    UIViewController* parent = self.parentViewController;
    [self.formControl addControlsForControlViewsInViewHierarchy:parent.view
                                                   excludeViews:[AKACompositeControl viewsToExcludeFromScanningViewController:parent]];
}

- (void)                                  activateBindings
{
    [self.formControl startObservingChanges];
}

- (void)                                deactivateBindings
{
    [self.formControl stopObservingChanges];
}

#pragma mark - Change Tracking

- (void)startObservingChanges
{
    if (!self.isObservingChanges)
    {
        [self startObservingKeyboardEvents];
        [self activateBindings];
        [self.observations enumerateObjectsUsingBlock:
         ^(AKAProperty * _Nonnull property, BOOL * _Nonnull stop __unused)
         {
             [property startObservingChanges];
         }];
        [self startObservingContentSizeCategoryEvents];
        _isObservingChanges = YES;
    }
}

- (void)stopObservingChanges
{
    if (self.isObservingChanges)
    {
        [self stopObservingContentSizeCategoryEvents];
        [self.observations enumerateObjectsWithOptions:NSEnumerationReverse
                                            usingBlock:
         ^(AKAProperty * _Nonnull property, BOOL * _Nonnull stop __unused)
         {
             [property stopObservingChanges];
         }];
        [self deactivateBindings];
        [self stopObservingKeyboardEvents];
        _isObservingChanges = NO;
    }
}

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

- (void)           startObservingContentSizeCategoryEvents
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentSizeCategoryDidChange:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)            stopObservingContentSizeCategoryEvents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

#pragma mark - Auxilliary Observations

- (AKAProperty *)                       observeWeakTarget:(NSObject *)target
                                                  keyPath:(NSString *)keyPath
                                        changesUsingBlock:(void (^)(id _Nullable, id _Nullable))didChangeValue
{
    AKAProperty* result = nil;

    result= [AKAProperty propertyOfWeakKeyValueTarget:target
                                              keyPath:keyPath
                                       changeObserver:didChangeValue];
    [self addObservation:result];

    return result;
}

- (void)                                   addObservation:(AKAProperty*)property
{
    if (_observations == nil)
    {
        _observations = [NSMutableSet new];
    }

    [self.observations addObject:property];
    if (self.isObservingChanges)
    {
        [property startObservingChanges];
    }
}

- (void)                                removeObservation:(AKAProperty*)property
{
    [property stopObservingChanges];
    [self.observations removeObject:property];
}

#pragma mark - Properties

- (id<AKAControlBindingBehaviorDelegate>)                delegate
{
    return self.delegateDispatcher.delegate;
}

- (UIScrollView *)                              scrollView
{
    UIViewController* parent = self.parentViewController;
    UIScrollView* result = nil;
    if ([parent respondsToSelector:@selector(scrollView)])
    {
        result = [parent valueForKey:NSStringFromSelector(@selector(scrollView))];
    }
    return result;
}

#pragma mark - Form Control Delegate

- (void)                                           control:(req_AKAControl)control
                                                   binding:(req_AKAKeyboardControlViewBinding)binding
                                     responderWillActivate:(req_UIResponder)responder
{
    (void)control;
    (void)binding;

    self.activeResponder = responder;

    id<AKAControlBindingBehaviorDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:responderWillActivate:)])
    {
        [delegate control:control binding:binding responderWillActivate:responder];
    }
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

    id<AKAControlBindingBehaviorDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:responderDidActivate:)])
    {
        [delegate control:control binding:binding responderDidActivate:responder];
    }
}

- (void)                                           control:(req_AKAControl)control
                                                   binding:(req_AKAKeyboardControlViewBinding)binding
                                    responderDidDeactivate:(req_UIResponder)responder
{
    (void)control;
    (void)binding;
    (void)responder;

    self.activeResponder = nil;

    id<AKAControlBindingBehaviorDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:responderDidDeactivate:)])
    {
        [delegate control:control binding:binding responderDidDeactivate:responder];
    }
}

#pragma mark - Content Size Category Notifications

- (void)                      contentSizeCategoryDidChange:(NSNotification*__unused)notification
{
    for (id<AKAContentSizeCategoryChangeListener> listener in self.contentSizeCategoryChangeListeners)
    {
        [listener contentSizeCategoryChanged];
    }
    [self.parentViewController.view setNeedsLayout];
}

- (void)                                           control:(AKAControl*__unused)control
                                             didAddBinding:(AKABinding*)binding
                                                   forView:(UIView*__unused)view
                                                  property:(SEL __unused)bindingProperty
                                     withBindingExpression:(AKABindingExpression*__unused)bindingExpression
{
    if ([binding conformsToProtocol:@protocol(AKAContentSizeCategoryChangeListener)])
    {
        id<AKAContentSizeCategoryChangeListener> listener = (id)binding;
        if (!self.contentSizeCategoryChangeListeners)
        {
            _contentSizeCategoryChangeListeners = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        }
        [self.contentSizeCategoryChangeListeners addObject:listener];
    }
}

#pragma mark - Keyboard Notifications

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

    if (self.rotationAnimationDuration == 0)
    {
        // No rotation animation
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
        // Keyboard height change is part of a device rotation, animate alongside the rotation animation
        if ([UIView areAnimationsEnabled])
        {
            [self adjustViewsForKeyboardHeightChangeTo:newHeight];
        }
        else
        {
            [UIView setAnimationsEnabled:YES];
            [self adjustViewsForKeyboardHeightChangeTo:newHeight
                                          withDuration:self.rotationAnimationDuration
                                        animationCurve:self.rotationAnimationCurve];
            [UIView setAnimationsEnabled:NO];
        }
    }
}

#pragma mark - Keyboard Height and Geometry Changes

- (void)                          viewWillTransitionToSize:(CGSize)size
                                 withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    // Record animation curve and duration of geometry changes to implement smooth animations alongside geometry changes (rotations):

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.rotationAnimationCurve = [context completionCurve];
        self.rotationAnimationDuration = [context transitionDuration];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        (void)context;

        self.rotationAnimationCurve = 0;
        self.rotationAnimationDuration = 0.0;
    }];
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
                                               svi.bottom + newHeight - (CGFloat)self.keyboardAdjustment,
                                               svi.right);

    UIEdgeInsets svsii = scrollView.scrollIndicatorInsets;
    scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(svsii.top, svsii.left,
                                                        svsii.bottom + newHeight - (CGFloat)self.keyboardAdjustment,
                                                        svsii.right);

    self.keyboardAdjustment = newHeight;

    [self scrollViewToVisible:self.activeResponder animated:YES];
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
                                                                     options:NSNumericSearch] != NSOrderedAscending);
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


@implementation UIViewController(AKAControlBindingBehavior)

- (AKAControlBindingBehavior *)aka_controlBindingBehavior
{
    __block AKAControlBindingBehavior* result = nil;
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[AKAControlBindingBehavior class]])
        {
            *stop = YES;
            result = obj;
        }
    }];
    return result;
}

@end
