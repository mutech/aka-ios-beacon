//
//  ViewController.m
//  AKAControlsDemo
//
//  Created by Michael Utech on 19.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAControlsDemoBaseViewController.h"

#import <AKAControls/AKAControl.h>
#import <AKAControls/AKAFormControl.h>
#import <AKAControls/AKATheme.h>
#import <AKAControls/AKAEditorControlView.h>

@interface AKAControlsDemoBaseViewController () <AKAControlDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property(nonatomic) NSMutableDictionary* model;
@property(nonatomic) AKACompositeControl* form;

@property(nonatomic) NSArray* themeNames;
@property(nonatomic) NSUInteger currentThemeIndex;

@end

@interface PhoneNumberValidator: NSObject<AKAControlValidatorProtocol>
@end

@implementation AKAControlsDemoBaseViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.themeNames = @[ @"default", @"tableview" ];
    self.currentThemeIndex = 0;

    [self initializeModel];
    self.form = [AKAFormControl controlWithDataContext:self];
    self.form.delegate = self;
    [self.form setThemeName:@"default" forClass:[AKAEditorControlView class]];
    [self.form addControlsForControlViewsInViewHierarchy:self.view];

    [self registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.form startObservingChanges];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

#pragma mark - ViewModel

- (PhoneNumberValidator*)phoneValidator
{
    return PhoneNumberValidator.new;
}

#pragma mark - Theme switcher

- (IBAction)switchTheme:(id)sender
{
    self.currentThemeIndex = (self.currentThemeIndex + 1) % self.themeNames.count;
    NSString* themeName = self.themeNames[self.currentThemeIndex];
    [self.view setNeedsLayout];
    [UIView animateWithDuration:.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionShowHideTransitionViews
                     animations:^
     {
         [self.form setThemeName:themeName forClass:[AKAEditorControlView class]];
         [self.view layoutIfNeeded];
     }
                     completion:nil];
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
                     @"email": @"info@demo.org",
                     @"number": @(123.45)
                     }];
}

@end

@implementation PhoneNumberValidator

- (BOOL)validateModelValue:(id)modelValue error:(NSError *__autoreleasing *)error
{
    BOOL result = YES;
    NSString* message = nil;
    if ([modelValue isKindOfClass:[NSString class]])
    {
        NSString* text = modelValue;
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if (text.length > 0)
        {
            if (![text hasPrefix:@"+"])
            {
                result = NO;
                message = @"Telefonnummern müssen mit '+' beginnen (z.B.: '+49...')";
            }
        }
    }
    else
    {
        result = NO;
        message = [NSString stringWithFormat:@"Ungúltiger Datentyp: %@ - benötige einen Text (NSString)", NSStringFromClass([modelValue class])];
    }
    if (!result && message.length > 0 && error != nil)
    {
        *error = [NSError errorWithDomain:@"Demo" code:1 userInfo:@{ NSLocalizedDescriptionKey: message }];
    }
    return result;
}

@end