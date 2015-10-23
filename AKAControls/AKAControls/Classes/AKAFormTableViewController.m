//
//  AKAFormTableViewController.m
//  AKAControls
//
//  Created by Michael Utech on 24.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

// TODO: rewrite dynamic placeholder stuff from scratch

@import AKACommons.AKATVMultiplexedDataSource;
@import AKACommons.AKALog;
@import AKACommons.NSObject_AKAAssociatedValues;
@import AKACommons.UIView_AKAHierarchyVisitor;

#import "AKAFormTableViewController.h"
#import "AKAEditorControlView.h"
#import "AKADynamicPlaceholderTableViewCellCompositeControl.h"
#import "AKADynamicPlaceholderTableViewCell.h"
#import "AKAControlDelegate.h"

#import "AKAControl_Internal.h" // TODO: expose constructors and remove this import

@interface AKAFormTableViewController ()

@property(nonatomic, readonly) NSMutableDictionary* hiddenControlCellsInfo;
@property(nonatomic, readonly) AKATVMultiplexedDataSource* multiplexedDataSource;
@property(nonatomic, readonly) NSMutableSet<AKADynamicPlaceholderTableViewCellCompositeControl*>* dynamicPlaceholderCellControls;

@end

@implementation AKAFormTableViewController

static NSString*const defaultDataSourceKey = @"default";

#pragma mark - View Life Cycle

- (void)                                       viewDidLoad
{
    [super viewDidLoad];

    _hiddenControlCellsInfo = [NSMutableDictionary new];
    _dynamicPlaceholderCellControls = [NSMutableSet new];

    [self initializeTableViewMultiplexedDataSourceAndDelegate];
    [self initializeFormControl];
}

- (void)                                    viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self activateFormControlBindings];
}

- (void)                                  viewWillDisappear:(BOOL)animated
{
    [self deactivateFormControlBindings];
    [super viewWillDisappear:animated];
}

#pragma mark - Form Control

- (void)initializeTableViewMultiplexedDataSourceAndDelegate
{
    _multiplexedDataSource =
        [AKATVMultiplexedDataSource proxyDataSourceAndDelegateForKey:defaultDataSourceKey
                                                         inTableView:self.tableView];
    [_multiplexedDataSource registerTableViewDelegateOverridesTo:[AKAFormTableViewController class]
                                                    fromDelegate:self];
}

- (void)                              initializeFormControl
{
    // Initialize formControl with the original tableView/dataSource to capture all static cells
    // containing control views.
    _formControl = [[AKAFormControl alloc] initWithDataContext:self
                                                 configuration:nil
                                                      delegate:self];

    [self initializeFormControlTheme];
    [self initializeFormControlMembers];
}

- (void)                         initializeFormControlTheme
{
    // Setup theme name before adding controls for subviews (TODO: order should not matter)
    [self.formControl setThemeName:@"tableview" forClass:[AKAEditorControlView class]];
}

- (void)                       initializeFormControlMembers
{
    AKATVDataSourceSpecification* defaultDataSource = [_multiplexedDataSource dataSourceForKey:defaultDataSourceKey];
    UITableView* tvProxy = [defaultDataSource proxyForTableView:self.tableView];

    if (self.tableView.tableHeaderView)
    {
        [self.formControl addControlsForControlViewsInViewHierarchy:self.tableView.tableHeaderView];
    }

    [self.formControl
     addControlsForControlViewsInStaticTableView:tvProxy
                                      dataSource:defaultDataSource.dataSource];

    if (self.tableView.tableFooterView)
    {
        [self.formControl addControlsForControlViewsInViewHierarchy:self.tableView.tableFooterView];
    }
}

- (void)                        activateFormControlBindings
{
    [self.formControl startObservingChanges];
}

- (void)                      deactivateFormControlBindings
{
    [self.formControl stopObservingChanges];
}

- (AKATVDataSourceSpecification*)           dataSourceForKey:(NSString*)key
                                               inMultiplexer:(AKATVMultiplexedDataSource*)multiplexedDataSource
{
    return [multiplexedDataSource dataSourceForKey:key];
}

#pragma mark - Managing Activation

- (NSIndexPath*)                    indexPathForInvisibleCell:(UITableViewCell*)cell
{
    NSIndexPath* result = nil;

    for (NSInteger si = 0; si < [self numberOfSectionsInTableView:self.tableView]; ++si)
    {
        for (NSInteger ri = 0; ri < [self tableView:self.tableView numberOfRowsInSection:si]; ++ri)
        {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:ri inSection:si];
            UITableView* tableView = self.tableView;
            id c = [tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];

            if (c == cell)
            {
                result = indexPath;
                break;
            }
        }
    }

    return result;
}

- (BOOL)                                            tableView:(UITableView*)tableView
                                                 scrollToCell:(UITableViewCell*)cell
                                             atScrollPosition:(UITableViewScrollPosition)scrollPosition
                                                     animated:(BOOL)animated
{
    (void)tableView;
    BOOL result = NO;
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];

    if (indexPath == nil)
    {
        indexPath = [self indexPathForInvisibleCell:cell];
    }

    if (indexPath && indexPath.row != NSNotFound)
    {
        result = YES;
        [self.tableView
         scrollToRowAtIndexPath:indexPath
               atScrollPosition:scrollPosition
                       animated:animated];
    }

    return result;
}

- (void)                                              control:(req_AKAControl)control
                                                      binding:(req_AKABinding)binding
                                        responderWillActivate:(req_UIResponder)responder
{
    (void)control;
    (void)binding;

    if ([responder isKindOfClass:[UIView class]])
    {
        UIView* view = (UIView*)responder;
        UITableViewCell* cell = (UITableViewCell*)[view aka_superviewOfType:[UITableViewCell class]];

        if (cell != nil)
        {
            if (![[self.tableView visibleCells] containsObject:cell])
            {
                // TODO: This should be animated, but if we animate it, a subsequent
                // keyboard resize (resulting from possible change of suggestion bar)
                // will not be animated
                [self   tableView:self.tableView
                     scrollToCell:cell
                 atScrollPosition:UITableViewScrollPositionBottom
                         animated:YES];
            }
        }
    }
}

- (BOOL)                                              control:(AKAControl*)control
                                              validationState:(NSError*)oldError
                                                    changedTo:(NSError*)newError
                               updateValidationMessageDisplay:(void (^)())block
{
    (void)oldError;
    (void)newError;

    __block BOOL result = NO;
    // Make sure the table view cell's layout is updated to accomodate for a possible error message
    [UIView animateWithDuration:.2
                          delay:0
                        options:(UIViewAnimationOptionCurveEaseInOut)
                     animations:^
     {
         block();
         [self.tableView beginUpdates];
         [self.tableView endUpdates];

         UITableViewCell* cell = (id)[control.view
                                      aka_superviewOfType:[UITableViewCell class]];

         if (cell)
         {
             [self   tableView:self.tableView
                  scrollToCell:cell
              atScrollPosition:UITableViewScrollPositionNone
                      animated:YES];
         }

         result = YES;
     }
                     completion:nil];

    return result;
}

#pragma mark - Hiding and Unhiding Table View Row Controls

- (NSArray*)                            rowControlsTaggedWith:(NSString*)tag
{
    NSMutableArray* result = [NSMutableArray new];

    [self.formControl
     enumerateControlsUsingBlock:^(AKAControl* control, NSUInteger index, BOOL* stop)
     {
         (void)index;
         (void)stop;

         if ([control isKindOfClass:[AKATableViewCellCompositeControl class]])
         {
             if ([control.tags
                  containsObject:tag])
             {
                 [result addObject:control];
             }
         }
     }];

    return result;
}

- (NSArray*)                                      rowControls:(NSArray*)rowControls
                                                sortedInOrder:(NSComparisonResult)order
{
    __block NSArray* result = rowControls;

    if (order != NSOrderedSame)
    {
        AKATVDataSourceSpecification* dsSpec = [self.multiplexedDataSource dataSourceForKey:@"default"];
        result = [rowControls sortedArrayUsingComparator:^NSComparisonResult (id obj1, id obj2)
                  {
                      AKATableViewCellCompositeControl* cell1 = obj1;
                      AKATableViewCellCompositeControl* cell2 = obj2;
                      NSIndexPath* i1 = [dsSpec tableViewMappedIndexPath:cell1.indexPath];
                      NSIndexPath* i2 = [dsSpec tableViewMappedIndexPath:cell2.indexPath];

                      return order == NSOrderedAscending ? [i1 compare:i2] : [i2 compare:i1];
                  }];
    }

    return result;
}

- (BOOL)                                       hideRowControl:(AKATableViewCellCompositeControl*)rowControl
                                                withAnimation:(UITableViewRowAnimation)rowAnimation
{
    AKATVDataSourceSpecification* dsSpec = [self.multiplexedDataSource dataSourceForKey:@"default"];
    BOOL result = [self.multiplexedDataSource
                   excludeRowFromSourceIndexPath:rowControl.indexPath
                                    inDataSource:dsSpec
                                withRowAnimation:rowAnimation];

    return result;
}

- (void)                                      hideRowControls:(NSArray*)rowControls
                                             withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    NSArray* sortedByIndexPath = [self rowControls:rowControls sortedInOrder:NSOrderedDescending];

    [self.multiplexedDataSource beginUpdates];
    for (AKATableViewCellCompositeControl* rowControl in sortedByIndexPath)
    {
        [self hideRowControl:rowControl withAnimation:rowAnimation];
    }
    [self.multiplexedDataSource endUpdates];
}

- (BOOL)                                     unhideRowControl:(AKATableViewCellCompositeControl*)rowControl
                                                withAnimation:(UITableViewRowAnimation)rowAnimation
{
    BOOL result = NO;

    if (![rowControl isKindOfClass:[AKADynamicPlaceholderTableViewCellCompositeControl class]])
    {
        AKATVDataSourceSpecification* dsSpec = [self.multiplexedDataSource dataSourceForKey:@"default"];
        result = [self.multiplexedDataSource
                  includeRowFromSourceIndexPath:rowControl.indexPath
                                   inDataSource:dsSpec
                               withRowAnimation:rowAnimation];
    }

    return result;
}

- (void)                                    unhideRowControls:(NSArray*)rowControls
                                             withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    NSArray* sortedByIndexPath = [self rowControls:rowControls sortedInOrder:NSOrderedAscending];

    [self.multiplexedDataSource beginUpdates];
    for (AKATableViewCellCompositeControl* rowControl in sortedByIndexPath)
    {
        [self unhideRowControl:rowControl withAnimation:rowAnimation];
    }
    [self.multiplexedDataSource endUpdates];
}

#pragma mark - Control Membership Delegate (Setup for Controls)

- (void)                                              control:(AKACompositeControl*)compositeControl
                                                didAddControl:(AKAControl*)memberControl
                                                      atIndex:(NSUInteger)index
{
    (void)compositeControl;
    (void)index;

    if ([memberControl isKindOfClass:[AKADynamicPlaceholderTableViewCellCompositeControl class]])
    {
        // Please note that instances for placeholder controls which are added to the
        // placeholder are using AKACompositeControl's and will not be covered here
        // (which would result in some chaotic recursion)

        AKADynamicPlaceholderTableViewCellCompositeControl* placeholder = (id)memberControl;
        AKABinding_AKADynamicPlaceholderTableViewCell_collectionBinding* collectionBinding = placeholder.collectionBinding;

        NSIndexPath* indexPath = placeholder.indexPath;
        if (indexPath != nil)
        {
            collectionBinding.placeholderIndexPath = indexPath;
            collectionBinding.multiplexer = self.multiplexedDataSource;
            if (collectionBinding.multiplexedDataSourceKey.length <= 0)
            {
                collectionBinding.multiplexedDataSourceKey =
                [NSString stringWithFormat:@"dynamic_cells@%ld_%ld",
                 (long)placeholder.indexPath.section,
                 (long)placeholder.indexPath.row];
            }
            [self.multiplexedDataSource addDataSourceAndDelegate:placeholder
                                                          forKey:collectionBinding.multiplexedDataSourceKey];
        }
        AKATVDataSourceSpecification* defaultDataSource = [self dataSourceForKey:@"default"
                                                                   inMultiplexer:self.multiplexedDataSource];
        collectionBinding.placeholderOriginDataSourceSpecification = defaultDataSource;

        [self.dynamicPlaceholderCellControls addObject:placeholder];

        [self.multiplexedDataSource excludeRowFromSourceIndexPath:placeholder.indexPath
                                                     inDataSource:defaultDataSource
                                                 withRowAnimation:UITableViewRowAnimationNone];

        [collectionBinding startObservingChanges];
    }
}

- (void)                                              control:(AKACompositeControl*)compositeControl
                                            willRemoveControl:(AKAControl*)memberControl
                                                    fromIndex:(NSUInteger)index
{
    (void)compositeControl;
    (void)index;

    // TODO: we need to inspect the sub tree of a removed control to
    // be sure that we detect all removals of placeholder cell controls.
    if ([memberControl isKindOfClass:[AKADynamicPlaceholderTableViewCellCompositeControl class]])
    {
        [self.dynamicPlaceholderCellControls removeObject:(AKADynamicPlaceholderTableViewCellCompositeControl*)memberControl];

        // TODO: remove dynamic rows if any
    }
}

- (void)                                              control:(req_AKACompositeControl)control
                                                      binding:(req_AKACollectionControlViewBinding)binding
                             sourceControllerDidChangeContent:(req_id)sourceDataController
{
    (void)control;
    (void)binding;
    (void)sourceDataController;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

@end


