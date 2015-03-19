//
//  ViewController.m
//  AKAControlsDemo
//
//  Created by Michael Utech on 19.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAControlsDemoBaseViewController.h"

#import <AKAControls/AKATextField.h>
#import <AKAControls/AKACompositeControl.h>

@interface AKAControlsDemoBaseViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property(nonatomic) NSMutableDictionary* model;
@property(nonatomic) AKACompositeControl* form;

@end

@implementation AKAControlsDemoBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeModel];
    self.form = [AKACompositeControl controlWithDataContext:self];
    [self.form addControlsForControlViewsInViewHierarchy:self.view];
    [self.form setupKeyboardActivationSequence];

    [self registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.form startObservingChanges];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.form stopObservingChanges];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;

    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;

    UIView* activeField = self.form.activeLeafControl.view;

    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)initializeModel
{
    self.model = [NSMutableDictionary dictionaryWithDictionary:
                  @{ @"name": @"AKA Sarl",
                     @"phone": @"+1-234-5678",
                     @"email": @"info@demo.org"
                     }];
}

@end
