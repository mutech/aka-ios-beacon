//
//  AKATableViewCompositeControl.m
//  AKABeacon
//
//  Created by Michael Utech on 06.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKATableViewCompositeControl.h"
#import "AKAControl_Internal.h"
#import "AKABinding_UITableView_dataSourceBinding.h"

@interface AKATableViewCompositeControl()

@property(nonatomic, readonly) NSMutableDictionary<NSIndexPath*, AKAControl*>* controlsByIndexPath;

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
    [control addControlsForControlViewsInViewHierarchy:cell.contentView];
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

@end
