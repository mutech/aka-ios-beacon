//
//  AKAFormTableViewController.m
//  AKAControls
//
//  Created by Michael Utech on 24.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAControl_Protected.h"
#import "AKAFormTableViewController.h"
#import "AKAEditorControlView.h"
#import "AKADynamicPlaceholderTableViewCellCompositeControl.h"
#import "AKADynamicPlaceholderTableViewCell.h"
#import "AKAControlDelegate.h"
#import <AKACommons/AKATVMultiplexedDataSource.h>
#import <AKACommons/AKALog.h>
#import "NSObject+AKAAssociatedValues.h"

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
            AKALogDebug(@"Cloned placeholder cell %@ for row at index path %@: %@", self.placeholderCell, indexPath, result);
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

    if (self.tableView.tableHeaderView)
    {
        [self.formControl addControlsForControlViewsInViewHierarchy:self.tableView.tableHeaderView];
    }
    // Create controls for control views in tableview cells
    [self.formControl addControlsForControlViewsInStaticTableView:self.tableView
                                                       dataSource:self.tableView.dataSource];
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
        AKADynamicPlaceholderTableViewCellCompositeControl* placeholder = (id)memberControl;

        [self.dynamicPlaceholderCellControls addObject:placeholder];

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

    AKATVDataSourceSpecification* dataSource = [self dataSourceForKey:key inMultiplexer:self.multiplexedDataSource];

    if (dataSource == nil && config.valueKeyPath.length > 0)
    {
        id<UITableViewDataSource> uitvDataSource = nil;
        id<UITableViewDelegate> uitvDelegate = nil;

        if (config.dataSourceKeyPath.length > 0)
        {
            uitvDataSource = [placeholder dataContextValueAtKeyPath:config.dataSourceKeyPath];
        }
        else if (config.valueKeyPath.length > 0)
        {
            uitvDataSource = [[AKAArrayTableViewDataSourceAndDelegate alloc] initWithControl:placeholder];
            uitvDelegate = (id)uitvDataSource;
            // Keep a strong reference of the data source:
            [placeholder aka_setAssociatedValue:uitvDataSource forKey:@"arrayDataSource"];
        }

        if (config.delegateKeyPath.length > 0)
        {
            uitvDelegate = [placeholder dataContextValueAtKeyPath:config.delegateKeyPath];
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

- (void)hideRowControls:(NSArray*)rowControls
       withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    AKATVDataSourceSpecification* dsSpec = [self.multiplexedDataSource dataSourceForKey:@"default"];
    NSArray* sortedByIndexPath = [rowControls sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        AKATableViewCellCompositeControl* cell1 = obj1;
        AKATableViewCellCompositeControl* cell2 = obj2;
        NSIndexPath* i1 = [dsSpec tableViewMappedIndexPath:cell1.indexPath];
        NSIndexPath* i2 = [dsSpec tableViewMappedIndexPath:cell2.indexPath];
        NSComparisonResult result = [i1 compare:i2];
        if (result == NSOrderedAscending)
        {
            result = NSOrderedDescending;
        }
        else if (result == NSOrderedDescending)
        {
            result = NSOrderedAscending;
        }
        return result;
    }];
    [self.multiplexedDataSource beginUpdates];
    for (AKATableViewCellCompositeControl* controlCell in sortedByIndexPath)
    {
        __strong NSIndexPath* tableViewIndexPath = [dsSpec tableViewMappedIndexPath:controlCell.indexPath];
        if (tableViewIndexPath)
        {
            [self.multiplexedDataSource removeUpTo:1
                                 rowsFromIndexPath:tableViewIndexPath
                                  withRowAnimation:rowAnimation];
            self.hiddenControlCellsInfo[controlCell.indexPath] = tableViewIndexPath;
        }
    }
    [self.multiplexedDataSource endUpdates];
}

- (void)unhideRowControls:(NSArray*)rowControls
         withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    NSArray* sortedByIndexPath = [rowControls sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        AKATableViewCellCompositeControl* cell1 = obj1;
        AKATableViewCellCompositeControl* cell2 = obj2;
        NSIndexPath* i1 = self.hiddenControlCellsInfo[cell1.indexPath];
        NSIndexPath* i2 = self.hiddenControlCellsInfo[cell2.indexPath];
        NSComparisonResult result = [i1 compare:i2];
        return result;
    }];
    [self.multiplexedDataSource beginUpdates];
    for (AKATableViewCellCompositeControl* controlCell in sortedByIndexPath)
    {
        NSIndexPath* tableViewIndexPath = self.hiddenControlCellsInfo[controlCell.indexPath];
        if (tableViewIndexPath)
        {
            [self.multiplexedDataSource insertRowsFromDataSource:@"default"
                                                 sourceIndexPath:controlCell.indexPath
                                                           count:1
                                                     atIndexPath:tableViewIndexPath
                                                withRowAnimation:rowAnimation];
            [self.hiddenControlCellsInfo removeObjectForKey:controlCell.indexPath];
        }
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

- (BOOL)updateDynamicRowsForPlaceholderControl:(AKATableViewCellCompositeControl*)placeholder
{
    // Update control structure for model value item collection:
    [placeholder removeAllControls];
    id items = placeholder.modelValue;
    if ([items isKindOfClass:[NSSet class]])
    {
        items = [((NSSet*)items) allObjects];
    }
    if ([items isKindOfClass:[NSArray class]])
    {
        int i=0;
        for (id item in (NSArray*)items)
        {
            AKACompositeViewBindingConfiguration* configuration = AKACompositeViewBindingConfiguration.new;
            configuration.valueKeyPath = [NSString stringWithFormat:@"#%d", i++];
            // TODO: create a configuration based on placeholder config
            AKACompositeControl* composite = [AKACompositeControl controlWithOwner:placeholder
                                                                     configuration:configuration];
            // keep a strong reference to the item
            [composite aka_setAssociatedValue:item forKey:@"data_item"];
            [placeholder addControl:composite];
        }
    }

    AKADynamicPlaceholderTableViewCellBindingConfiguraton* config =
        (AKADynamicPlaceholderTableViewCellBindingConfiguraton*)placeholder.viewBinding.configuration;

    NSUInteger currentActualNumberOfRows = placeholder.actualNumberOfRows;

    NSString* key = [self dataSourceKeyForDynamicPlaceholder:placeholder];

    AKATVDataSourceSpecification* defaultDS = [self.multiplexedDataSource dataSourceForKey:@"default"];
    AKATVDataSourceSpecification* placeholderDS = [self dataSourceForKey:key
                                                   inMultiplexer:self.multiplexedDataSource];

    NSIndexPath* targetIndexPath = [defaultDS tableViewMappedIndexPath:placeholder.indexPath];
    BOOL result = (targetIndexPath != nil);

    if (result)
    {
        targetIndexPath = [NSIndexPath indexPathForRow:targetIndexPath.row + 1
                                             inSection:targetIndexPath.section];

        NSIndexPath* sourceIndexPath = [NSIndexPath indexPathForRow:config.rowIndex
                                                          inSection:config.sectionIndex];

        NSUInteger count = config.numberOfRows;
        if (count == 0)
        {
            count = [placeholderDS.dataSource tableView:self.multiplexedDataSource.tableView
                                  numberOfRowsInSection:0];
        }

        [self.multiplexedDataSource beginUpdates];
        if (currentActualNumberOfRows > 0)
        {
            [self.multiplexedDataSource removeUpTo:currentActualNumberOfRows
                                 rowsFromIndexPath:targetIndexPath
                                  withRowAnimation:UITableViewRowAnimationAutomatic];

        }
        if (count > 0)
        {
            [self.multiplexedDataSource insertRowsFromDataSource:key
                                                 sourceIndexPath:sourceIndexPath
                                                           count:count
                                                     atIndexPath:targetIndexPath
                                                withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        placeholder.actualNumberOfRows = count;
        [self.multiplexedDataSource endUpdates];

        [self.tableView reloadData];
    }
    else
    {
        placeholder.actualNumberOfRows = 0;
    }

    [self.tableView beginUpdates];
    [self.tableView endUpdates];

    return result;
}

@end
