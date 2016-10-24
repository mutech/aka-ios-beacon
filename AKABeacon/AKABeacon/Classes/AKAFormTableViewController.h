//
//  AKAFormTableViewController.h
//  AKABeacon
//
//  Created by Michael Utech on 24.04.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AKAFormControl.h"
#import "AKATVDataSourceSpecification.h"

@class AKAReference;
@class AKATableViewCellCompositeControl;

@interface AKAFormTableViewController : UITableViewController<AKAControlDelegate>

@property(nonatomic) id model;
@property(nonatomic, readonly) AKAFormControl* formControl;
@property(nonatomic, readonly) AKATVDataSourceSpecification* defaultDataSource;

#pragma mark - Initialization

- (void)initializeTableViewMultiplexedDataSourceAndDelegate;

- (void)                              initializeFormControl;

- (void)                         initializeFormControlTheme;

- (void)                       initializeFormControlMembers;

- (void)                        activateFormControlBindings;

- (void)                      deactivateFormControlBindings;

#pragma mark - Accessing tagged controls

/**
 * Returns an array containing all row controls which are
 * tagged with the specified value.
 *
 * @param tag a tag value
 *
 * @return An array containing all row controls which are tagged with the specified value.
 */
- (NSArray*)rowControlsTaggedWith:(NSString*)tag;

#pragma mark - Hiding and Unhinding Rows

- (BOOL)isRowControlHidden:(AKATableViewCellCompositeControl*)rowControl;

/**
 * Hides all rows bound to controls contained in the specified rowControls array.
 *
 * @param rowControls an array containing row controls
 * @param rowAnimation the animation to be used
 */
- (void)hideRowControls:(NSArray<AKATableViewCellCompositeControl*>*)rowControls
       withRowAnimation:(UITableViewRowAnimation)rowAnimation;

/**
 * Unhides all rows bound to controls contained in the specified rowControls array.
 *
 * @param rowControls an array containing row controls
 * @param rowAnimation the animation to use
 */
- (void)unhideRowControls:(NSArray<AKATableViewCellCompositeControl*>*)rowControls
         withRowAnimation:(UITableViewRowAnimation)rowAnimation;

@end
