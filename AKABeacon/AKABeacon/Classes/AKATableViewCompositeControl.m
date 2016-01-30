//
//  AKATableViewCompositeControl.m
//  AKABeacon
//
//  Created by Michael Utech on 06.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.UIView_AKAHierarchyVisitor                              ;

#import "AKATableViewCompositeControl.h"
#import "AKAControl_Internal.h"
#import "AKABinding_UITableView_dataSourceBinding.h"

@interface AKATableViewCompositeControl()

@property(nonatomic, readonly) NSMutableDictionary<NSIndexPath*, AKAControl*>* controlsByIndexPath;
@property(nonatomic) BOOL addingDynamicBindings;

@end


@implementation AKATableViewCompositeControl

#pragma mark - Initialization

- (instancetype)               init
{
    if (self = [super init])
    {
        _controlsByIndexPath = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark - View Binding Delegate (Cell bindings)

- (void)                    binding:(AKABinding_UITableView_dataSourceBinding*)binding
          addDynamicBindingsForCell:(UITableViewCell *)cell
                          indexPath:(NSIndexPath*)indexPath
                        dataContext:(id)dataContext
{
    (void)binding;

    // TODO: Check: I thought the bindings would be released before data contexts (as soon as owner controls are removed), there might be another retain cycle involved
    
    // If table view cells are created in response to manual reloads (e.g. not triggered by
    // data source binding), dynamic bindings have not been removed. This may lead to a situation
    // where observed data contexts could be released before observing bindings which in turn
    // results in exceptions.
    AKAControl* previousControlAtIndexPath = self.controlsByIndexPath[indexPath];
    if (previousControlAtIndexPath)
    {
        UITableViewCell* previousCell = (UITableViewCell*)previousControlAtIndexPath.view;
        NSAssert(previousCell == nil || [previousCell isKindOfClass:[UITableViewCell class]], nil);

        [self binding:binding removeDynamicBindingsForCell:previousCell indexPath:indexPath];
    }

    // TODO: obsolete, remove if new update logic in data source binding proves to do the job:
    BOOL wasAddingDynamicBindings = self.addingDynamicBindings;
    self.addingDynamicBindings = YES;

    AKACompositeControl* control = [[AKACompositeControl alloc] initWithDataContext:dataContext
                                                                      configuration:nil];
    [control setView:cell];
    self.controlsByIndexPath[indexPath] = control;
    [self addControl:control];
    // TODO: get the exclusion views from delegate?
    [control addControlsForControlViewsInViewHierarchy:cell.contentView
                                          excludeViews:nil];

    self.addingDynamicBindings = wasAddingDynamicBindings;
}

- (void)                    binding:(AKABinding_UITableView_dataSourceBinding*)binding
       removeDynamicBindingsForCell:(UITableViewCell *)cell
                          indexPath:(NSIndexPath*)indexPath
{
    (void)binding;
    (void)cell;

    if (indexPath)
    {
        AKAControl* control = self.controlsByIndexPath[indexPath];
        [self.controlsByIndexPath removeObjectForKey:indexPath];
        [self removeControl:control];
    }
}

@end
