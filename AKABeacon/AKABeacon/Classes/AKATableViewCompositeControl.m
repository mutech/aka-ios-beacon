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
@property(nonatomic) NSMutableArray<NSIndexPath*>* indexPathsNeedingUpdate;
@property(nonatomic) BOOL tableViewNeedsUpdate;

@end


@implementation AKATableViewCompositeControl

#pragma mark - Initialization

- (instancetype)               init
{
    if (self = [super init])
    {
        _indexPathsNeedingUpdate = [NSMutableArray new];
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

    AKACompositeControl* control = [[AKACompositeControl alloc] initWithDataContext:dataContext
                                                                      configuration:nil];
    [control setView:cell];
    self.controlsByIndexPath[indexPath] = control;
    [self addControl:control];
    // TODO: get the exclusion views from delegate?
    [control addControlsForControlViewsInViewHierarchy:cell.contentView
                                          excludeViews:nil];
}

- (void)                    binding:(AKABinding_UITableView_dataSourceBinding*)binding
       removeDynamicBindingsForCell:(UITableViewCell *)cell
                          indexPath:(NSIndexPath*)indexPath
{
    (void)binding;
    (void)cell;
    
    AKAControl* control = self.controlsByIndexPath[indexPath];
    [self.controlsByIndexPath removeObjectForKey:indexPath];
    [self removeControl:control];
}

#pragma mark - 

- (UITableViewCell*)cellAffectedByBinding:(AKABinding*)binding
{
    UITableViewCell* result = nil;

    if ([binding isKindOfClass:[AKAViewBinding class]])
    {
        AKAViewBinding* viewBinding = (AKAViewBinding*)binding;
        UIView* targetView = viewBinding.view;
        result = [targetView aka_selfOrSuperviewOfType:[UITableViewCell class]];
    }
    else
    {
        id delegate = binding.delegate;
        if ([delegate isKindOfClass:[AKABinding class]])
        {
            result = [self cellAffectedByBinding:delegate];
        }
        else
        {
            // Controls
        }
    }

    return result;
}

- (NSIndexPath*)indexPathOfRowAffectedByBinding:(AKABinding*)binding
{
    UITableViewCell* cell = [self cellAffectedByBinding:binding];
    NSIndexPath* result = [(UITableView*)self.view indexPathForCell:cell];

    return result;
}

- (void)                    control:(req_AKAControl)control
                            binding:(req_AKABinding)binding
               didUpdateTargetValue:(id)oldTargetValue
                                 to:(id)newTargetValue
{
    if ([self.view isKindOfClass:[UITableView class]])
    {
        UITableView* tableView = (UITableView*)self.view;

        // Trigger a recomputation of table view row heights if any bindings
        // update target values. Dispatching the update to the main queue
        // will defer the update until the current queue job is finished which
        // should reduce unneccessary table view updates to a minimum and also
        // prevent nested updates from occuring when a binding change event would
        // trigger another change.
        if (!self.tableViewNeedsUpdate)
        {
            self.tableViewNeedsUpdate = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.tableViewNeedsUpdate = NO;
                [tableView beginUpdates];
                [tableView endUpdates];
            });
        }
    }

    [super                  control:control
                            binding:binding
               didUpdateTargetValue:oldTargetValue
                                 to:newTargetValue];
}

@end
