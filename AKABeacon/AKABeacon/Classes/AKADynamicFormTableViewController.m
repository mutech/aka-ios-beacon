//
//  AKADynamicFormTableViewController.m
//  AKABeacon
//
//  Created by Michael Utech on 14.12.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.AKAErrors;
@import AKACommons.AKALog;
@import AKACommons.UIView_AKAHierarchyVisitor;

#import "AKADynamicFormTableViewController.h"
#import "AKABindingContextProtocol.h"
#import "UIView+AKABindingSupport.h"
#import "AKABinding.h"

#import "AKAFormControl.h"
#import "AKACompositeControl.h"
#import "AKAControl_Internal.h"


@interface AKADynamicFormTableViewCellBindingContext: NSObject<AKABindingContextProtocol>

- (instancetype)initWithRoot:(id<AKABindingContextProtocol>)root
                 dataContext:(id)dataContext;

@property(nonatomic, readonly)id<AKABindingContextProtocol> rootContext;
@property(nonatomic, readonly)id dataContext;

@end


@implementation AKADynamicFormTableViewCellBindingContext

- (instancetype)initWithRoot:(id<AKABindingContextProtocol>)root
                 dataContext:(id)dataContext
{
    if (self = [self init])
    {
        _rootContext = root;
        _dataContext = dataContext;
    }
    return self;
}

- (id)dataContextValueForKeyPath:(NSString *)keyPath
{
    return [self dataContextPropertyForKeyPath:keyPath
                            withChangeObserver:nil].value;
}

- (id)rootDataContextValueForKeyPath:(NSString *)keyPath
{
    return [self rootDataContextPropertyForKeyPath:keyPath
                                withChangeObserver:nil].value;
}

- (id)controlValueForKeyPath:(NSString *)keyPath
{
    return [self controlPropertyForKeyPath:keyPath
                        withChangeObserver:nil].value;
}

- (AKAProperty *)dataContextPropertyForKeyPath:(NSString *)keyPath
                            withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    return [AKAProperty propertyOfWeakKeyValueTarget:self.dataContext
                                             keyPath:keyPath
                                      changeObserver:valueDidChange];
}

- (AKAProperty *)rootDataContextPropertyForKeyPath:(NSString *)keyPath
                                withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    return [self.rootContext dataContextPropertyForKeyPath:keyPath
                                        withChangeObserver:valueDidChange];
}

- (AKAProperty *)controlPropertyForKeyPath:(NSString *)keyPath
                        withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    (void)keyPath;
    (void)valueDidChange;
    return nil;
}

@end


@interface AKADynamicFormTableViewController() <AKABindingContextProtocol, AKAControlDelegate>

@property(nonatomic, readonly, nonnull) NSMutableDictionary<NSIndexPath*, AKACompositeControl*>* visibleCellControlsByIndexPath;

@end


@implementation AKADynamicFormTableViewController

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    _formControl = [[AKAFormControl alloc] initWithDataContext:self delegate:self];
    _visibleCellControlsByIndexPath = [NSMutableDictionary new];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.formControl startObservingChanges];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeAllRowControls];
    [self.formControl stopObservingChanges];

    [super viewWillDisappear:animated];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)                       tableView:(UITableView *)tableView
                                cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id dataContext = [self              tableView:tableView
                          dataContextForIndexPath:indexPath];
    NSString* cellIdentifier = [self    tableView:tableView
                     cellIdentifierForDataContext:dataContext];

    UITableViewCell* result = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                              forIndexPath:indexPath];

    return result;
}

#pragma mark - UITableViewDelegate

- (void)                                    tableView:(UITableView *)tableView
                                      willDisplayCell:(UITableViewCell *)cell
                                    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Will display cell %p for row at index path %ld-%ld",
               cell, (unsigned long)indexPath.section, (unsigned long)indexPath.row);

    id dataContext = [self tableView:tableView dataContextForIndexPath:indexPath];

    AKACompositeControl* control = [[AKACompositeControl alloc] initWithDataContext:dataContext
                                                                      configuration:nil];
    [control setView:cell];

    [self addControl:control forRowAtIndexPath:indexPath];

    [control addControlsForControlViewsInViewHierarchy:cell.contentView];
}

- (void)                                    tableView:(UITableView *)tableView
                                 didEndDisplayingCell:(UITableViewCell *)cell
                                    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    (void)tableView;
    NSLog(@"Did end displaying cell %p for row at index path %ld-%ld",
          cell, (unsigned long)indexPath.section, (unsigned long)indexPath.row);

    [self removeControlForRowAtIndexPath:indexPath];
}

- (void)                                   addControl:(AKACompositeControl*)control
                                    forRowAtIndexPath:(NSIndexPath*)indexPath
{
    self.visibleCellControlsByIndexPath[indexPath] = control;

    [self.formControl addControl:control];
}

- (void)              removeControlForRowAtIndexPath:(NSIndexPath*)indexPath
{
    AKACompositeControl* control = self.visibleCellControlsByIndexPath[indexPath];
    if (control)
    {
        [self.formControl removeControl:control];
        [self.visibleCellControlsByIndexPath removeObjectForKey:indexPath];
        control = nil;
    }
}

- (void)                        removeAllRowControls
{
    for (NSIndexPath* indexPath in self.visibleCellControlsByIndexPath.allKeys)
    {
        [self removeControlForRowAtIndexPath:indexPath];
    }
}

#pragma mark - Abstract Methods - Data Context Mapping

- (req_NSString)                            tableView:(UITableView*)tableView
                         cellIdentifierForDataContext:(id)dataContext
{
    (void)tableView;
    (void)dataContext;
    AKAErrorAbstractMethodImplementationMissing();
}

- (id)                                      tableView:(UITableView*)tableView
                              dataContextForIndexPath:(NSIndexPath*)indexPath
{
    (void)tableView;
    (void)indexPath;
    AKAErrorAbstractMethodImplementationMissing();
}

#pragma mark - Abstract Methods - UITableViewDataSource

- (NSInteger)             numberOfSectionsInTableView:(UITableView *)tableView
{
    (void)tableView;
    AKAErrorAbstractMethodImplementationMissing();
}

- (NSInteger)                               tableView:(UITableView *)tableView
                                numberOfRowsInSection:(NSInteger)section
{
    (void)tableView;
    (void)section;
    AKAErrorAbstractMethodImplementationMissing();
}

#pragma mark - AKABindingContextProtocol

- (id)dataContextValueForKeyPath:(NSString *)keyPath
{
    return [self dataContextPropertyForKeyPath:keyPath
                            withChangeObserver:nil].value;
}

- (id)rootDataContextValueForKeyPath:(NSString *)keyPath
{
    return [self rootDataContextPropertyForKeyPath:keyPath
                                withChangeObserver:nil].value;
}

- (id)controlValueForKeyPath:(NSString *)keyPath
{
    return [self controlPropertyForKeyPath:keyPath
                        withChangeObserver:nil].value;
}

- (AKAProperty *)dataContextPropertyForKeyPath:(NSString *)keyPath
                            withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    return [AKAProperty propertyOfWeakKeyValueTarget:self
                                             keyPath:keyPath
                                      changeObserver:valueDidChange];
}

- (AKAProperty *)rootDataContextPropertyForKeyPath:(NSString *)keyPath
                                withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    return [self dataContextPropertyForKeyPath:keyPath
                            withChangeObserver:valueDidChange];
}

- (AKAProperty *)controlPropertyForKeyPath:(NSString *)keyPath
                        withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    (void)keyPath;
    (void)valueDidChange;
    return nil;
}

@end
