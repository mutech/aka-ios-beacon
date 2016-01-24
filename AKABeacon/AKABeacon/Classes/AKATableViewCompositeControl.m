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
@property(nonatomic) BOOL tableViewNeedsUpdate;

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

- (void)                    control:(req_AKAControl)control
                            binding:(req_AKABinding)binding
               didUpdateTargetValue:(id)oldTargetValue
                                 to:(id)newTargetValue
{
    if ([self.controlViewBinding isKindOfClass:[AKABinding_UITableView_dataSourceBinding class]])
    {
        AKABinding_UITableView_dataSourceBinding* dsBinding = (id)self.controlViewBinding;
        UITableView* tableView = dsBinding.tableView;

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
