//
//  AKAFormTableViewController.m
//  AKAControls
//
//  Created by Michael Utech on 24.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKATVMultiplexedDataSource;
@import AKACommons.AKALog;
@import AKACommons.NSObject_AKAAssociatedValues;
@import AKACommons.UIView_AKAHierarchyVisitor;

#import "AKAControl_Protected.h"
#import "AKAFormTableViewController.h"
#import "AKAEditorControlView.h"
#import "AKADynamicPlaceholderTableViewCellCompositeControl.h"
#import "AKADynamicPlaceholderTableViewCell.h"
#import "AKAControlDelegate.h"

@interface AKAArrayTableViewDataSourceAndDelegate: NSObject<UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithControl:(AKADynamicPlaceholderTableViewCellCompositeControl*)control;

@property(nonatomic, readonly) AKADynamicPlaceholderTableViewCellCompositeControl* placeholderControl;
@property(nonatomic, readonly) AKADynamicPlaceholderTableViewCell* placeholderCell;

@end

@implementation AKAArrayTableViewDataSourceAndDelegate

@synthesize placeholderControl = _control;

#pragma mark - Initialization

- (instancetype)initWithControl:(AKADynamicPlaceholderTableViewCellCompositeControl*)control
{
    if (self = [self init])
    {
        _control = control;
    }
    return self;
}

#pragma mark - UITableViewDataSource Implementation

- (AKADynamicPlaceholderTableViewCell *)placeholderCell
{
    NSAssert([self.placeholderControl.view isKindOfClass:[AKADynamicPlaceholderTableViewCell class]], @"Expected placeholder cell view type");
    return (AKADynamicPlaceholderTableViewCell*)self.placeholderControl.view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    (void)tableView;
    return 1;
}

- (NSInteger)           tableView:(UITableView *)tableView
            numberOfRowsInSection:(NSInteger)section
{
    (void)tableView;
    return [self.placeholderControl countOfControls];
}

- (UITableViewCell *)   tableView:(UITableView *)tableView
            cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    (void)tableView;

    AKACompositeControl* memberControl = [self.placeholderControl objectInControlsAtIndex:indexPath.row];

    UITableViewCell* result = [memberControl aka_associatedValueForKey:@"strongCellReference"];

    if (result == nil)
    {
        result = [tableView dequeueReusableCellWithIdentifier:self.placeholderCell.reuseIdentifier];
        if (result == nil)
        {
            // TODO: this is probably not a good idea, however I didn't find a better way yet to use the
            // placeholder cell as a prototype for instances.
            NSData* archived = [NSKeyedArchiver archivedDataWithRootObject:self.placeholderCell];
            result = [NSKeyedUnarchiver unarchiveObjectWithData:archived];
            //AKALogDebug(@"Cloned placeholder cell %@ for row at index path %@: %@", self.placeholderCell, indexPath, result);
            [memberControl aka_setAssociatedValue:result forKey:@"strongCellReference"];
        }
        [memberControl removeAllControls];
        if ([result isKindOfClass:[AKADynamicPlaceholderTableViewCell class]])
        {
            [memberControl addControlsForControlViewsInViewHierarchy:result.contentView];
            [memberControl startObservingChanges];
        }
    }

    return result;
}

#pragma mark - UITableViewDelegate Implementation

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (CGFloat)             tableView:tableView
          heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)             tableView:(UITableView *)tableView
         heightForHeaderInSection:(NSInteger)section
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)             tableView:(UITableView *)tableView
         heightForFooterInSection:(NSInteger)section
{
    return UITableViewAutomaticDimension;
}

- (NSInteger)           tableView:(UITableView *)tableView
    indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

- (NSIndexPath *)       tableView:(UITableView *)tableView
         willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}

- (void)                tableView:(UITableView *)tableView
          didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end


@interface AKAFormTableViewController ()

@property(nonatomic, readonly) NSMutableDictionary* hiddenControlCellsInfo;
@property(nonatomic, readonly) AKATVMultiplexedDataSource* multiplexedDataSource;
@property(nonatomic, readonly) NSMutableSet* dynamicPlaceholderCellControls;

@end

@implementation AKAFormTableViewController

static NSString* const defaultDataSourceKey = @"default";

- (void)viewDidLoad
{
    [super viewDidLoad];

    _hiddenControlCellsInfo = [NSMutableDictionary new];
    _dynamicPlaceholderCellControls = [NSMutableSet new];

    // Initialize formControl with the original tableView/dataSource to capture all static cells
    // containing control views.
    _formControl = [AKAFormControl controlWithDataContext:self configuration:nil];

    self.formControl.delegate = self;

    // Setup theme name before adding controls for subviews (TODO: order should not matter)
    [self.formControl setThemeName:@"tableview" forClass:[AKAEditorControlView class]];


    _multiplexedDataSource =
    [AKATVMultiplexedDataSource proxyDataSourceAndDelegateForKey:defaultDataSourceKey
                                                     inTableView:self.tableView];
    AKATVDataSourceSpecification* defaultDataSource = [_multiplexedDataSource dataSourceForKey:defaultDataSourceKey];
    UITableView* tvProxy = [defaultDataSource proxyForTableView:self.tableView];

    if (self.tableView.tableHeaderView)
    {
        [self.formControl addControlsForControlViewsInViewHierarchy:self.tableView.tableHeaderView];
    }

    [self.formControl addControlsForControlViewsInStaticTableView:tvProxy
                                                       dataSource:defaultDataSource.dataSource];
    if (self.tableView.tableFooterView)
    {
        [self.formControl addControlsForControlViewsInViewHierarchy:self.tableView.tableFooterView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.formControl startObservingChanges];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.formControl stopObservingChanges];
    [super viewWillDisappear:animated];
}

#pragma mark - Control Membership Delegate (Setup for Controls)

- (void)    control:(AKACompositeControl *)compositeControl
      didAddControl:(AKAControl *)memberControl
            atIndex:(NSUInteger)index
{
    if ([memberControl isKindOfClass:[AKADynamicPlaceholderTableViewCellCompositeControl class]])
    {
        // Please note that instances for placeholder controls which are added to the
        // placeholder are using AKACompositeControl's and will not be covered here
        // (which would result in some chaotic recursion)

        AKADynamicPlaceholderTableViewCellCompositeControl* placeholder = (id)memberControl;

        [self.dynamicPlaceholderCellControls addObject:placeholder];

        AKATVDataSourceSpecification* defaultDataSource = [self dataSourceForKey:@"default"
                                                                   inMultiplexer:self.multiplexedDataSource];
        [self.multiplexedDataSource excludeRowFromSourceIndexPath:placeholder.indexPath
                                                     inDataSource:defaultDataSource
                                                 withRowAnimation:UITableViewRowAnimationNone];

        AKATVDataSourceSpecification* dataSource = [self dataSourceForDynamicPlaceholder:placeholder];
        if (dataSource != nil)
        {
            [self updateDynamicRowsForPlaceholderControl:placeholder];
        }
    }
}

- (void)    control:(AKACompositeControl *)compositeControl
  willRemoveControl:(AKAControl *)memberControl
          fromIndex:(NSUInteger)index
{
    // TODO: we need to inspect the sub tree of a removed control to
    // be sure that we detect all removals of placeholder cell controls.
    if ([memberControl isKindOfClass:[AKATableViewCellCompositeControl class]])
    {
        if ([memberControl.viewBinding.configuration isKindOfClass:[AKADynamicPlaceholderTableViewCellBindingConfiguraton class]])
        {
            [self.dynamicPlaceholderCellControls removeObject:memberControl];

            // TODO: remove dynamic rows if any
        }
    }
}

- (NSString*)dataSourceKeyForDynamicPlaceholder:(AKATableViewCellCompositeControl*)placeholder
{
    NSString* key = [placeholder aka_associatedValueForKey:@"dataSourceKey"];
    if (key == nil)
    {
        if ([placeholder.view isKindOfClass:[UITableViewCell class]] &&
            ((UITableViewCell*)placeholder.view).reuseIdentifier.length > 0)
        {
            key = ((UITableViewCell*)placeholder.view).reuseIdentifier;
        }
        else
        {
            key = [NSString stringWithFormat:@"dynamic_cells@%ld_%ld",
                   (long)placeholder.indexPath.section,
                   (long)placeholder.indexPath.row];
        }
        [placeholder aka_setAssociatedValue:key forKey:@"dataSourceKey"];
    }
    return key;
}

- (AKATVDataSourceSpecification*)dataSourceForKey:(NSString*)key
                                    inMultiplexer:(AKATVMultiplexedDataSource*)multiplexedDataSource
{
    return [multiplexedDataSource dataSourceForKey:key];
}

- (AKATVDataSourceSpecification*)dataSourceForDynamicPlaceholder:(AKADynamicPlaceholderTableViewCellCompositeControl*)placeholder
{
    AKADynamicPlaceholderTableViewCellBindingConfiguraton* config = (id)placeholder.viewBinding.configuration;

    NSString* key = [self dataSourceKeyForDynamicPlaceholder:placeholder];

    // Entry point for sub classes to provide an alternative data source by redefining
    // the dataSourceForKey:inMultiplexer method:
    AKATVDataSourceSpecification* dataSource = [self dataSourceForKey:key
                                                        inMultiplexer:self.multiplexedDataSource];

    if (dataSource == nil && config.valueKeyPath.length > 0)
    {
        id<UITableViewDataSource> uitvDataSource = nil;
        id<UITableViewDelegate> uitvDelegate = nil;

        if (config.dataSourceKeyPath.length > 0)
        {
            // Use the configured data source
            uitvDataSource = [placeholder dataContextValueForKeyPath:config.dataSourceKeyPath];
        }
        else if (config.valueKeyPath.length > 0)
        {
            // Create a data source for configured value (-> expecting a collection value)
            uitvDataSource = [[AKAArrayTableViewDataSourceAndDelegate alloc] initWithControl:placeholder];
            // Use the delegate implementation provided by the data source by default, might
            // be overwritten below
            uitvDelegate = (id)uitvDataSource;
            // Keep a strong reference of the data source:
            [placeholder aka_setAssociatedValue:uitvDataSource forKey:@"arrayDataSource"];
        }

        if (config.delegateKeyPath.length > 0)
        {
            // Use the configured delegate
            uitvDelegate = [placeholder dataContextValueForKeyPath:config.delegateKeyPath];
        }

        if (uitvDataSource != nil)
        {
            dataSource = [self.multiplexedDataSource addDataSource:uitvDataSource
                                                      withDelegate:uitvDelegate
                                                            forKey:key];
        }
    }
    return dataSource;
}

#pragma mark - Hiding and Unhiding Table View Row Controls

- (NSArray*)rowControlsTaggedWith:(NSString*)tag
{
    NSMutableArray* result = [NSMutableArray new];
    [self.formControl enumerateControlsUsingBlock:^(AKAControl *control, NSUInteger index, BOOL *stop) {
        if ([control isKindOfClass:[AKATableViewCellCompositeControl class]])
        {
            if ([control.tags containsObject:tag])
            {
                [result addObject:control];
            }
        }
    }];
    return result;
}

- (NSArray*)rowControls:(NSArray*)rowControls
          sortedInOrder:(NSComparisonResult)order
{
    __block NSArray* result = rowControls;
    if (order != NSOrderedSame)
    {
        AKATVDataSourceSpecification* dsSpec = [self.multiplexedDataSource dataSourceForKey:@"default"];
        result = [rowControls sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            AKATableViewCellCompositeControl* cell1 = obj1;
            AKATableViewCellCompositeControl* cell2 = obj2;
            NSIndexPath* i1 = [dsSpec tableViewMappedIndexPath:cell1.indexPath];
            NSIndexPath* i2 = [dsSpec tableViewMappedIndexPath:cell2.indexPath];
            NSComparisonResult result = order == NSOrderedAscending ? [i1 compare:i2] : [i2 compare:i1];
            return result;
        }];
    }
    return result;
}

- (BOOL)hideRowControl:(AKATableViewCellCompositeControl*)rowControl
         withAnimation:(UITableViewRowAnimation)rowAnimation
{
    AKATVDataSourceSpecification* dsSpec = [self.multiplexedDataSource dataSourceForKey:@"default"];
    BOOL result = [self.multiplexedDataSource excludeRowFromSourceIndexPath:rowControl.indexPath
                                                               inDataSource:dsSpec
                                                           withRowAnimation:rowAnimation];
    return result;
}

- (void)hideRowControls:(NSArray*)rowControls
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

- (BOOL)unhideRowControl:(AKATableViewCellCompositeControl*)rowControl
           withAnimation:(UITableViewRowAnimation)rowAnimation
{
    BOOL result = NO;
    if (![rowControl isKindOfClass:[AKADynamicPlaceholderTableViewCellCompositeControl class]])
    {
        AKATVDataSourceSpecification* dsSpec = [self.multiplexedDataSource dataSourceForKey:@"default"];
        result = [self.multiplexedDataSource includeRowFromSourceIndexPath:rowControl.indexPath
                                                              inDataSource:dsSpec
                                                          withRowAnimation:rowAnimation];
    }
    return result;
}

- (void)unhideRowControls:(NSArray*)rowControls
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

#pragma mark - Dynamic Placeholder Cell Controls

- (void)addDynamicDataSource:(id<UITableViewDataSource>)dataSource
                withDelegate:(id<UITableViewDelegate>)delegate
                      forKey:(NSString*)key
{
    NSParameterAssert([self.multiplexedDataSource dataSourceForKey:key] == nil);
    [self.multiplexedDataSource addDataSource:dataSource
                                 withDelegate:delegate
                                       forKey:key];
    for (AKATableViewCellCompositeControl* placeholder in self.dynamicPlaceholderCellControls)
    {
        NSString* placeholderKey = [self dataSourceKeyForDynamicPlaceholder:placeholder];
        if ([key isEqualToString:placeholderKey])
        {
            [self updateDynamicRowsForPlaceholderControl:placeholder];
        }
    }
}

- (BOOL)updateDynamicRowsForPlaceholderControl:(AKADynamicPlaceholderTableViewCellCompositeControl*)placeholder
{
    NSString* key = [self dataSourceKeyForDynamicPlaceholder:placeholder];

    AKATVDataSourceSpecification* defaultDS = [self.multiplexedDataSource dataSourceForKey:defaultDataSourceKey];
    AKADynamicPlaceholderTableViewCellBindingConfiguraton* config =
        (id)placeholder.viewBinding.configuration;

    NSIndexPath* targetIndexPath = [defaultDS tableViewMappedIndexPath:placeholder.indexPath];
    BOOL result = (targetIndexPath != nil);

    id modelValue = placeholder.modelValue;
    NSArray* items = nil;
    if ([modelValue isKindOfClass:[NSSet class]])
    {
        items = [((NSSet*)modelValue) allObjects];
    }
    else if ([modelValue isKindOfClass:[NSMutableArray class]])
    {
        items = [NSArray arrayWithArray:modelValue];
    }
    else if ([modelValue isKindOfClass:[NSArray class]])
    {
        items = modelValue;
    }
    else
    {
        items = @[];
    }

    NSMutableArray* deferredReloadIndexes = NSMutableArray.new;

    [self.multiplexedDataSource beginUpdates];

    // Controls are recreated on every call to make things a bit easier
    [placeholder removeAllControls];

    // Remove items no longer in new items collection
    NSMutableArray* oldItems = nil;
    if (placeholder.actualItems.count > 0)
    {
        oldItems = [NSMutableArray arrayWithArray:placeholder.actualItems];
        for (NSInteger i=oldItems.count-1; i >= 0; --i)
        {
            id oldItem = oldItems[i];
            if ([items indexOfObject:oldItem] == NSNotFound)
            {
                [oldItems removeObjectAtIndex:i];
                NSIndexPath* tip = [NSIndexPath indexPathForRow:targetIndexPath.row+i
                                                      inSection:targetIndexPath.section];
                if (result)
                {
                    [self.multiplexedDataSource removeUpTo:1
                                         rowsFromIndexPath:tip
                                          withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
        }
    }
    else
    {
        oldItems = NSMutableArray.new;
    }

    // Process insertions and movements
    NSUInteger insertedItemCount = 0;

    for (NSInteger i=0; i < ((NSArray*)items).count; ++i)
    {
        id item = ((NSArray*)items)[i];
        NSInteger oldIndex = [oldItems indexOfObject:item];

        if (oldIndex == NSNotFound)
        {
            NSIndexPath* tip = [NSIndexPath indexPathForRow:targetIndexPath.row+i
                                                  inSection:targetIndexPath.section];
            NSIndexPath* sourceIndexPath = [NSIndexPath indexPathForRow:config.rowIndex+i
                                                              inSection:config.sectionIndex];
            if (result)
            {
                [self.multiplexedDataSource insertRowsFromDataSource:key
                                                     sourceIndexPath:sourceIndexPath
                                                               count:1
                                                         atIndexPath:tip
                                                    withRowAnimation:UITableViewRowAnimationFade];
            }
            ++insertedItemCount;
        }
        else if (oldIndex + insertedItemCount != i)
        {
            NSAssert(oldIndex + insertedItemCount > i, @"");

            [oldItems removeObjectAtIndex:oldIndex];

            if (result)
            {
                NSIndexPath* fromTip = [NSIndexPath indexPathForRow:targetIndexPath.row+oldIndex + insertedItemCount
                                                          inSection:targetIndexPath.section];
                NSIndexPath* toTip = [NSIndexPath indexPathForRow:targetIndexPath.row+i
                                                        inSection:targetIndexPath.section];
                [self.multiplexedDataSource rowAtIndexPath:fromTip
                                            didMoveToIndexPath:toTip];
            }
            ++insertedItemCount;
        }
        else
        {
            // Assume a content change for non-inserted/deleted/moved items
            if (result)
            {
                [deferredReloadIndexes addObject:[NSIndexPath indexPathForRow:targetIndexPath.row+i
                                                                    inSection:targetIndexPath.section]];
            }
        }
    }

    // (Re-)create controls for dynamic rows
    NSInteger i=0;
    for (id item in items)
    {
        AKACompositeViewBindingConfiguration* configuration = AKACompositeViewBindingConfiguration.new;
        configuration.valueKeyPath = [NSString stringWithFormat:@"#%ld", (long)i++];
        AKACompositeControl* composite = [AKACompositeControl controlWithOwner:placeholder
                                                                 configuration:configuration];
        // keep a strong reference to the item
        [composite aka_setAssociatedValue:item forKey:@"data_item"];
        [placeholder addControl:composite];
    }

    placeholder.actualItems = items;
    placeholder.actualNumberOfRows = 0;
    
    [self.multiplexedDataSource endUpdates];
    if (deferredReloadIndexes.count > 0)
    {
        [self.multiplexedDataSource reloadRowsAtIndexPaths:deferredReloadIndexes
                                          withRowAnimation:UITableViewRowAnimationFade];
    }

    [self.tableView beginUpdates];
    [self.tableView endUpdates];

    return result;
}

#pragma mark - Managing Activation

- (NSIndexPath*)indexPathForInvisibleCell:(UITableViewCell*)cell
{
    NSIndexPath* result = nil;
    for (NSInteger si = 0; si < [self numberOfSectionsInTableView:self.tableView]; ++si)
    {
        for(NSInteger ri = 0; ri < [self tableView:self.tableView numberOfRowsInSection:si]; ++ri)
        {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:ri inSection:si];
            id c = [self.tableView.dataSource tableView:self.tableView cellForRowAtIndexPath:indexPath];
            if (c == cell)
            {
                result = indexPath;
                break;
            }
        }
    }
    return result;
}


- (BOOL)tableView:(UITableView*)tableView
     scrollToCell:(UITableViewCell*)cell
 atScrollPosition:(UITableViewScrollPosition)scrollPosition
         animated:(BOOL)animated
{
    BOOL result = NO;
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath == nil)
    {
        indexPath = [self indexPathForInvisibleCell:cell];
    }
    if (indexPath && indexPath.row != NSNotFound)
    {
        result = YES;
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionNone
                                      animated:animated];
    }
    return result;
}

- (void)                                              control:(req_AKAControl)control
                                                      binding:(req_AKABinding)binding
                                        responderWillActivate:(req_UIResponder)responder
{
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
                [self tableView:self.tableView
                   scrollToCell:cell
               atScrollPosition:UITableViewScrollPositionBottom
                       animated:YES];
            }
        }
    }
}

- (BOOL)                control:(AKAControl *)control
                validationState:(NSError *)oldError
                      changedTo:(NSError *)newError
 updateValidationMessageDisplay:(void (^)())block
{
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

         UITableViewCell* cell = (id)[control.view aka_superviewOfType:[UITableViewCell class]];
         if (cell)
         {
             [self tableView:self.tableView
                scrollToCell:cell
            atScrollPosition:UITableViewScrollPositionNone
                    animated:YES];
         }

         result = YES;
     }
                     completion:^(BOOL finished) {

                     }];
    return result;
}


@end
