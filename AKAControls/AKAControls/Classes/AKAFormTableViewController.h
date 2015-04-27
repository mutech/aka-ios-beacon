//
//  AKAFormTableViewController.h
//  AKAControls
//
//  Created by Michael Utech on 24.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AKAFormControl.h"
#import <AKACommons/AKATVMultiplexedDataSource.h>

@class AKAReference;

@interface AKAFormTableViewController : UITableViewController

@property(nonatomic) id model;
@property(nonatomic, readonly) AKAFormControl* formControl;
@property(nonatomic, readonly) AKATVMultiplexedDataSource* multiplexedDataSource;

#pragma mark - Hiding and Unhinding Rows

- (NSArray*)rowControlsTaggedWith:(NSString*)tag;
- (void)hideRowControls:(NSArray*)rowControls
       withRowAnimation:(UITableViewRowAnimation)rowAnimation;
- (void)unhideRowControls:(NSArray*)rowControls
         withRowAnimation:(UITableViewRowAnimation)rowAnimation;

@end
