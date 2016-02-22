//
//  AKAFormViewController.m
//  AKABeacon
//
//  Created by Michael Utech on 12.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAFormViewController.h"

#import "AKAControl.h"
#import "AKAEditorControlView.h"

@interface AKAFormViewController()

@property(nonatomic, weak) UIResponder* activeResponder;

@property(nonatomic) double                 aka_keyboardAdjustment;
@property(nonatomic) double                 aka_rotationAnimationDuration;
@property(nonatomic) UIViewAnimationCurve   aka_rotationAnimationCurve;

@end

@implementation AKAFormViewController

#pragma mark - View Life Cycle

- (void)                                       viewDidLoad
{
    [super viewDidLoad];

    //[self setupScrollView];

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

#pragma mark - Form Control

- (void)                             initializeFormControl
{
    _formControl = [[AKAFormControl alloc] initWithDataContext:self
                                                      delegate:self];

    [self initializeFormControlTheme];
    [self initializeFormControlMembers];
}

- (void)                        initializeFormControlTheme
{
    // Setup theme name before adding controls for subviews (TODO: order should not matter)
    [self.formControl setThemeName:@"default" forClass:[AKAEditorControlView class]];
}

- (void)                      initializeFormControlMembers
{
    [self.formControl addControlsForControlViewsInViewHierarchy:self.view
                                                   excludeViews:[AKACompositeControl viewsToExcludeFromScanningViewController:self]];
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
    UIEdgeInsets svi = self.scrollView.contentInset;
    self.scrollView.contentInset = UIEdgeInsetsMake(svi.top, svi.left,
                                                    svi.bottom + newHeight - (CGFloat)self.aka_keyboardAdjustment,
                                                    svi.right);

    UIEdgeInsets svsii = self.scrollView.scrollIndicatorInsets;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(svsii.top, svsii.left,
                                                             svsii.bottom + newHeight - (CGFloat)self.aka_keyboardAdjustment,
                                                             svsii.right);

    self.aka_keyboardAdjustment = newHeight;

    [self scrollViewToVisible:self.activeResponder animated:NO];
}

- (void)                               scrollViewToVisible:(UIResponder*)activeResponder animated:(BOOL)animated
{
    if ([activeResponder isKindOfClass:[UIView class]])
    {
        UIView* firstResponder = (UIView*)activeResponder;

        // Since  iOS9, textfields automatically scroll to visible, which means that we don't have to do
        // that anymore (thanks), but we can't control it either (thanks) so our "friendlyFrame"
        // computation doesn't work anymore. We could wrap the text field in another disabled scrollview
        // to fix this, but we'll leave out the hacks until it's needed.
        if (!(([[[UIDevice currentDevice] systemVersion] compare:@"9.0"
                                                         options:NSNumericSearch] == NSOrderedAscending) &&
              [firstResponder isKindOfClass:[UITextField class]]))
        {
            CGRect frame = firstResponder.frame;
            CGRect friendlyFrame = [firstResponder convertRect:CGRectMake(frame.origin.x,
                                                                          frame.origin.y -10.0f,
                                                                          frame.size.width,
                                                                          frame.size.height + 20.0f)
                                                        toView:self.scrollView];

            [self.scrollView scrollRectToVisible:friendlyFrame animated:animated];
        }
    }
}

- (UIScrollView *)scrollView
{
    return _scrollView;
}

- (void) setupScrollView
{
    if (self.scrollView == nil)
    {
        UIView* rootView = self.view;
        __block NSMutableArray* layoutSupportViews = [NSMutableArray new];
        __block NSMutableArray* subviews = [NSMutableArray new];
        [rootView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            (void)idx;
            (void)stop;
            if ([obj conformsToProtocol:@protocol(UILayoutSupport)])
            {
                [layoutSupportViews addObject:obj];
            }
            else
            {
                [subviews addObject:obj];
            }
        }];

        UIScrollView* scrollView = nil;
        if (subviews.count == 1)
        {
            if ([scrollView isKindOfClass:[UIScrollView class]])
            {
                scrollView = rootView.subviews.firstObject;
            }
            if (scrollView == nil)
            {
                scrollView = [[UIScrollView alloc] initWithFrame:rootView.bounds];
                scrollView.translatesAutoresizingMaskIntoConstraints = NO;
                scrollView.delaysContentTouches = YES;
                scrollView.canCancelContentTouches = YES;
                scrollView.userInteractionEnabled = YES;
                scrollView.multipleTouchEnabled = YES;
                scrollView.alwaysBounceHorizontal = NO;
                scrollView.alwaysBounceVertical = NO;

                UIView* contentView = subviews.firstObject;
                [contentView removeFromSuperview];
                [scrollView addSubview:contentView];
                [rootView addSubview:scrollView];


                NSArray* rootContraints =
                @[ [NSLayoutConstraint constraintWithItem:rootView
                                                attribute:NSLayoutAttributeTopMargin
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:scrollView
                                                attribute:NSLayoutAttributeTop
                                               multiplier:1
                                                 constant:0],
                   [NSLayoutConstraint constraintWithItem:scrollView
                                                attribute:NSLayoutAttributeBottom
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:rootView
                                                attribute:NSLayoutAttributeBottomMargin
                                               multiplier:1
                                                 constant:0],
                   [NSLayoutConstraint constraintWithItem:rootView
                                                attribute:NSLayoutAttributeLeading
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:scrollView
                                                attribute:NSLayoutAttributeLeading
                                               multiplier:1
                                                 constant:0],
                   [NSLayoutConstraint constraintWithItem:scrollView
                                                attribute:NSLayoutAttributeTrailing
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:rootView
                                                attribute:NSLayoutAttributeTrailing
                                               multiplier:1
                                                 constant:0],
                   [NSLayoutConstraint constraintWithItem:rootView
                                                attribute:NSLayoutAttributeWidth
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:contentView
                                                attribute:NSLayoutAttributeWidth
                                               multiplier:1.
                                                 constant:0.]];
                NSArray* scrollViewConstraints =
                @[ [NSLayoutConstraint constraintWithItem:scrollView
                                                attribute:NSLayoutAttributeTop
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:contentView
                                                attribute:NSLayoutAttributeTop
                                               multiplier:1
                                                 constant:0],
                   [NSLayoutConstraint constraintWithItem:contentView
                                                attribute:NSLayoutAttributeBottom
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:scrollView
                                                attribute:NSLayoutAttributeBottom
                                               multiplier:1
                                                 constant:0],
                   [NSLayoutConstraint constraintWithItem:scrollView
                                                attribute:NSLayoutAttributeLeading
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:contentView
                                                attribute:NSLayoutAttributeLeading
                                               multiplier:1
                                                 constant:0],
                   [NSLayoutConstraint constraintWithItem:contentView
                                                attribute:NSLayoutAttributeTrailing
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:scrollView
                                                attribute:NSLayoutAttributeTrailing
                                               multiplier:1
                                                 constant:0] ];
                [rootView addConstraints:rootContraints];
                [scrollView addConstraints:scrollViewConstraints];

                [rootView setNeedsLayout];
                [scrollView setNeedsLayout];
                [contentView setNeedsLayout];
                [rootView layoutIfNeeded];
            }
        }
        else if (subviews.count > 1)
        {
            NSLog(@"AKAFormViewController: will not automatically inject scroll view (more than one subview in view controllers top level content view). Scrolling in response to keyboard size changes will not be supported. If you need this feature, please add a scrollview and assign it to AKAFormViewController.scrollView outlet or wrap your views in a single UIView below the view controllers top level content view to enable auto injection of a scroll view");
        }

        self.scrollView = scrollView;
    }
}

@end