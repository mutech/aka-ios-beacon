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

// DEBUGGING:
#import <objc/runtime.h>
#import "AKATestContainerView.h"

@interface AKAControlsDemoBaseViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property(nonatomic) NSMutableDictionary* model;
@property(nonatomic) AKACompositeControl* form;

@property (weak, nonatomic) IBOutlet AKATestContainerView *themeSwitchTarget;
@end

@implementation AKAControlsDemoBaseViewController

#pragma mark - DEBUGGING

- (NSSet*)propertyNamesOfObject:(id<NSObject>)object
{
    NSMutableSet* result = NSMutableSet.new;
    unsigned int count = 0;
    objc_property_t *props = class_copyPropertyList([object class], &count);
    for (int i=0; i < count; ++i) {
        NSString* name = [NSString stringWithUTF8String:property_getName(props[i])];
        [result addObject:name];
    }
    return result;
}

- (void)enumerateDifferencesBetween:(NSObject*)object1
                                and:(NSObject*)object2
                         usingBlock:(BOOL(^)(NSString* property, id value1, id value2, BOOL* stop))block
{
    NSSet* properties = nil;
    {
        NSSet* properties1 = [self propertyNamesOfObject:object1];
        NSSet* properties2 = [self propertyNamesOfObject:object2];
        NSMutableSet* commonProperties = [NSMutableSet setWithSet:properties1];
        [commonProperties intersectSet:properties2];
        properties = commonProperties;
    }

    [properties enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        NSString* propertyName = (NSString*)obj;
        id value1 = [object1 valueForKey:propertyName];
        id value2 = [object2 valueForKey:propertyName];
        BOOL equal = NO;
        if ([value1 isKindOfClass:[NSObject class]] && [value2 isKindOfClass:[NSObject class]])
        {
            equal = [(NSObject*)value1 isEqual:value2];
        }
        else
        {
            equal = (value1 == value2);
        }

        if (!equal)
        {
            block(propertyName, value1, value2, stop);
        }
    }];
}

#pragma mark - View Life Cycle

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

#pragma mark - Theme switcher

- (IBAction)switchTheme:(id)sender
{
    if (self.themeSwitchTarget)
    {
        if ([@"tableview" isEqualToString:self.themeSwitchTarget.theme])
        {
            self.themeSwitchTarget.theme = @"default";
        }
        else
        {
            self.themeSwitchTarget.theme = @"tableview";
        }
        [UIView animateWithDuration:.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionShowHideTransitionViews
                         animations:^
        {

            [self.themeSwitchTarget setNeedsLayout];
            //[self.themeSwitchTarget layoutIfNeeded];
            [self.view layoutIfNeeded];
        }
                         completion:nil];

    }
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
