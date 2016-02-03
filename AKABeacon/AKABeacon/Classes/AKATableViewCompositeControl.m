//
//  AKATableViewCompositeControl.m
//  AKABeacon
//
//  Created by Michael Utech on 06.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.AKALog;
@import AKACommons.UIView_AKAHierarchyVisitor                              ;

#import "AKATableViewCompositeControl.h"
#import "AKAControl_Internal.h"
#import "AKABinding_UITableView_dataSourceBinding.h"

@interface AKATableViewCompositeControl()

@property(nonatomic, readonly) NSMutableDictionary<NSIndexPath*, AKAControl*>* controlsByIndexPath;
@property(nonatomic, readonly) NSMutableDictionary<NSIndexPath*, NSMutableSet<AKAControl*>*>* replacedControlsByIndexPath;

@end


@implementation AKATableViewCompositeControl

#pragma mark - Initialization

- (instancetype)               init
{
    if (self = [super init])
    {
        _controlsByIndexPath = [NSMutableDictionary new];
        _replacedControlsByIndexPath = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark - View Binding Delegate (Cell bindings)

- (void)replaceControl:(AKAControl*)control
           atIndexPath:(NSIndexPath*)indexPath
{
    NSMutableSet<AKAControl*>* replacedControls = self.replacedControlsByIndexPath[indexPath];
    if (replacedControls == nil)
    {
        replacedControls = [NSMutableSet new];
        self.replacedControlsByIndexPath[indexPath] = replacedControls;
    }
    [replacedControls addObject:control];
    [self.controlsByIndexPath removeObjectForKey:indexPath];
    [self removeControl:control];
}

- (BOOL)removeReplacedControlAtIndexPath:(NSIndexPath*)indexPath
                                 forCell:(UITableViewCell*)cell
{
    NSMutableSet* controls = self.replacedControlsByIndexPath[indexPath];

    __block AKAControl* match = nil;

    if (controls)
    {
        __block AKAControl* potentialMatch = nil;
        [self.replacedControlsByIndexPath[indexPath] enumerateObjectsUsingBlock:
         ^(AKAControl * _Nonnull control, BOOL * _Nonnull stop)
         {
             UIView* view = control.view;
             if (view == nil && cell == nil && potentialMatch == nil)
             {
                 potentialMatch = control;
             }
             else if (view == cell)
             {
                 *stop = YES;
                 match = control;
             }
         }];
        if (!match)
        {
            match = potentialMatch;
        }
        if (match)
        {
            [controls removeObject:match];
            if (controls.count == 0)
            {
                [self.replacedControlsByIndexPath removeObjectForKey:indexPath];
            }
        }
    }

    return match != nil;
}

- (void)                    binding:(AKABinding_UITableView_dataSourceBinding*)binding
          addDynamicBindingsForCell:(UITableViewCell *)cell
                          indexPath:(NSIndexPath*)indexPath
                        dataContext:(id)dataContext
{
    (void)binding;

    // Due to deferred updates (and possibly also in other situations), the order in which dynamic
    // bindings are added and removed is not necessarily as expected (remove old then add new for a
    // given indexpath). For that reason we keep a record of replaced cells but make sure their bindings
    // are deactivated (stopObservingChanges).

    AKAControl* previousControlAtIndexPath = self.controlsByIndexPath[indexPath];
    if (previousControlAtIndexPath)
    {
        UITableViewCell* previousCell = (UITableViewCell*)previousControlAtIndexPath.view;
        NSAssert(previousCell == nil || [previousCell isKindOfClass:[UITableViewCell class]], nil);

        [previousControlAtIndexPath stopObservingChanges];
        [self replaceControl:previousControlAtIndexPath atIndexPath:indexPath];
    }

    AKACompositeControl* control = [[AKACompositeControl alloc] initWithDataContext:dataContext
                                                                      configuration:nil];
    [control setView:cell];
    self.controlsByIndexPath[indexPath] = control;
    [self addControl:control];

    // TODO: get the exclusion views (for embedded view controllers) from delegate?
    [control addControlsForControlViewsInViewHierarchy:cell.contentView
                                          excludeViews:nil];
}

/*
 This has to be called at a point in time where it's known that a cell's bindings will be released but the data context is not yet released.
 
 The table view dataSourceBinding will call this method when it's scheduling an update of the table view for a change rows array while that array is still referenced (as oldValue in the change notification).
 
 If this is not done correctly, the result will most likely be exceptions for dangling observations on released objects. If you see these, double check if you call this method before the data context is released.
 */
- (void)                    binding:(AKABinding_UITableView_dataSourceBinding*)binding
      suspendDynamicBindingsForCell:(UITableViewCell *)cell
                          indexPath:(NSIndexPath*)indexPath
{
    (void)binding;
    (void)cell;

    if (indexPath)
    {
        AKAControl* control = self.controlsByIndexPath[indexPath];
        [control stopObservingChanges];
    }
}

- (void)                    binding:(AKABinding_UITableView_dataSourceBinding*)binding
       removeDynamicBindingsForCell:(UITableViewCell *)cell
                          indexPath:(NSIndexPath*)indexPath
{
    (void)binding;
    (void)cell;

    // Due to deferred updates (and possibly also in other situations), the order in which dynamic
    // bindings are added and removed is not necessarily as expected (remove old then add new for a
    // given indexpath). For that reason we keep a record of replaced cells and remove these if they match.

    if (indexPath)
    {
        if (![self removeReplacedControlAtIndexPath:indexPath forCell:cell])
        {
            AKAControl* control = self.controlsByIndexPath[indexPath];
            UIView* view = control.view;
            if (cell == nil || view == cell || view == nil)
            {
                [self.controlsByIndexPath removeObjectForKey:indexPath];
                [self removeControl:control];
            }
            else
            {
                // For some reason, tableView:didEndDisplayingCell:indexPath gets called multiple times for the replaced
                // cells.
                // TODO: check if we do something wrong which is causing this behaviour of if its just like that.
                NSString* message = [NSString stringWithFormat:@"Attempt to remove control %@ for non-matching cell %@", control, cell];
                AKALogWarn(@"%@", message);
            }
        }
    }
}

@end
