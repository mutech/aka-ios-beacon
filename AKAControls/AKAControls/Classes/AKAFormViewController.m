//
//  AKAFormViewController.m
//  AKAControls
//
//  Created by Michael Utech on 12.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAFormViewController.h"

#import "AKAControl.h"
#import "AKAEditorControlView.h"

@interface AKAFormViewController()

@property(nonatomic, weak) UIResponder* activeResponder;

@property(nonatomic) CGFloat                aka_keyboardAdjustment;
@property(nonatomic) CGFloat                aka_rotationAnimationDuration;
@property(nonatomic) UIViewAnimationCurve   aka_rotationAnimationCurve;

@end

@implementation AKAFormViewController

#pragma mark - View Life Cycle

- (void)                                       viewDidLoad
{
    [super viewDidLoad];

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
    [self.formControl addControlsForControlViewsInViewHierarchy:self.view];
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
    self.activeResponder = responder;
}

- (void)                                           control:(req_AKAControl)control
                                                   binding:(req_AKAKeyboardControlViewBinding)binding
                                      responderDidActivate:(req_UIResponder)responder
{
    [self scrollViewToVisible:responder animated:YES];
}

- (void)                                           control:(req_AKAControl)control
                                                   binding:(req_AKAKeyboardControlViewBinding)binding
                                    responderDidDeactivate:(req_UIResponder)responder
{
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
                                                    svi.bottom + newHeight - self.aka_keyboardAdjustment,
                                                    svi.right);

    UIEdgeInsets svsii = self.scrollView.scrollIndicatorInsets;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(svsii.top, svsii.left,
                                                             svsii.bottom + newHeight - self.aka_keyboardAdjustment,
                                                             svsii.right);

    self.aka_keyboardAdjustment = newHeight;

    [self scrollViewToVisible:self.activeResponder animated:NO];
}

- (void)                               scrollViewToVisible:(UIResponder*)activeResponder animated:(BOOL)animated
{
    if ([activeResponder isKindOfClass:[UIView class]])
    {
        UIView* firstResponder = (UIView*)activeResponder;

        CGRect frame = firstResponder.frame;
        CGRect friendlyFrame = CGRectMake(frame.origin.x, frame.origin.y - 10.0,
                                          frame.size.width, frame.size.height + 20.0);
        [self.scrollView scrollRectToVisible:friendlyFrame animated:animated];
    }
}

@end