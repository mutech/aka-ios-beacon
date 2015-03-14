//
//  ViewController.m
//  AKACommonsDemoApp
//
//  Created by Michael Utech on 11.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "ViewController.h"
#import <AKACommons/AKACompositeControl.h>
#import <AKACommons/UIView+AKAHierarchyVisitor.h>

@interface ViewController ()

@property(nonatomic) NSMutableDictionary* model;
@property(nonatomic) AKAProperty* textField1ModelValue;

@property(nonatomic) AKAControl* textField1Control;
@property(nonatomic) AKAControl* viewValueLabelControl;
@property(nonatomic) AKAControl* modelValueLabelControl;
@property(nonatomic) AKAControl* switchControl;

@property(nonatomic) AKACompositeControl* formControl;

@end

@implementation ViewController

- (void)initializeModel
{
    NSDictionary* model = @{ @"textField1": @"Initial value" };
    self.model = [NSMutableDictionary dictionaryWithDictionary:model];
    self.textField1ModelValue =
        [AKAProperty propertyOfKeyValueTarget:self.model
                                      keyPath:self.textField.textKeyPath
                               changeObserver:^(id oldValue, id newValue)
                                 {
                                     self.modelValueLabel.text = newValue;
                                     self.textField.text = newValue;
                                 }];
    self.modelValueLabel.text = self.textField1ModelValue.value;
    [self.textField1ModelValue startObservingChanges];
}

- (void)initializeControls
{
    self.formControl = [AKACompositeControl controlWithDataContext:self keyPath:nil];
    [self.formControl addControlsForControlViewsInViewHierarchy:self.view];
    [self.formControl startObservingChanges];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeModel];
    [self initializeControls];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)dismissKeyboard:(id)sender
{
    [self.textField resignFirstResponder];
}

@end
