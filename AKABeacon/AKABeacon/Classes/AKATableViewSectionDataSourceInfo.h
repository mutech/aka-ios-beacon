//
//  AKATableViewSectionDataSourceInfo.h
//  AKABeacon
//
//  Created by Michael Utech on 21.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;
@import CoreData;

#import "AKATableViewCellFactory.h"


@class AKATableViewSectionDataSourceInfo;


@protocol AKATableViewSectionDataSourceInfoDelegate <NSObject>

@optional
- (void)    sectionInfoWillChangeContent:(AKATableViewSectionDataSourceInfo*)sectionInfo;

@optional
- (void)                     sectionInfo:(AKATableViewSectionDataSourceInfo*)sectionInfo
                         didInsertObject:(id)object
                              atRowIndex:(NSInteger)index;

@optional
- (void)                     sectionInfo:(AKATableViewSectionDataSourceInfo*)sectionInfo
                         didUpdateObject:(id)object
                              atRowIndex:(NSInteger)index;

@optional
- (void)                     sectionInfo:(AKATableViewSectionDataSourceInfo*)sectionInfo
                         didDeleteObject:(id)object
                              atRowIndex:(NSInteger)index;

@optional
- (void)                     sectionInfo:(AKATableViewSectionDataSourceInfo*)sectionInfo
                           didMoveObject:(id)object
                            fromRowIndex:(NSInteger)index
                              toRowIndex:(NSInteger)index;

@optional
- (void)     sectionInfoDidChangeContent:(AKATableViewSectionDataSourceInfo*)sectionInfo;


@end


#pragma mark - AKATableViewSectionDataSourceInfo Interface
#pragma mark -

@interface AKATableViewSectionDataSourceInfo: NSObject

@property(nonatomic, weak) id<AKATableViewSectionDataSourceInfoDelegate> delegate;

@property(nonatomic) id                                 rowsSource;
@property(nonatomic) NSString*                          headerTitle;
@property(nonatomic) NSString*                          footerTitle;
@property(nonatomic) NSArray<AKATableViewCellFactory*>* cellMapping;

@property(nonatomic, readonly) BOOL                     usesFetchedResultsController;
@property(nonatomic, readonly) NSFetchedResultsController* fetchedResultsController;
@property(nonatomic, readonly) BOOL                     willSendDelegateChangeNotifications;
@property(nonatomic, readonly) NSArray*                 rows;

- (BOOL)isObservingChanges;
- (void)startObservingChanges;
- (void)stopObservingChanges;

@end
