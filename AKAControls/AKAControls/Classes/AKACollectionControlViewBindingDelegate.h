//
//  AKACollectionControlViewBindingDelegate.h
//  AKABeacon
//
//  Created by Michael Utech on 19.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
@import AKACommons.AKANullability;

#import "AKACollectionControlViewBinding.h"
#import "AKAControlViewBindingDelegate.h"

@class AKACollectionControlViewBinding;
typedef AKACollectionControlViewBinding*_Nonnull  req_AKACollectionControlViewBinding;
typedef AKACollectionControlViewBinding*_Nullable opt_AKACollectionControlViewBinding;

@protocol AKACollectionControlViewBindingDelegate<AKAControlViewBindingDelegate>

- (void)                            binding:(req_AKACollectionControlViewBinding)binding
          sourceControllerWillChangeContent:(req_id)sourceDataController;

- (void)                            binding:(req_AKACollectionControlViewBinding)binding
                           sourceController:(req_id)sourceDataController
                               insertedItem:(opt_id)sourceCollectionItem
                                atIndexPath:(req_NSIndexPath)indexPath;

- (void)                            binding:(req_AKACollectionControlViewBinding)binding
                           sourceController:(req_id)sourceDataController
                                updatedItem:(opt_id)sourceCollectionItem
                                atIndexPath:(req_NSIndexPath)indexPath;

- (void)                            binding:(req_AKACollectionControlViewBinding)binding
                           sourceController:(req_id)sourceDataController
                                deletedItem:(opt_id)sourceCollectionItem
                                atIndexPath:(req_NSIndexPath)indexPath;

- (void)                            binding:(req_AKACollectionControlViewBinding)binding
                           sourceController:(req_id)sourceDataController
                                  movedItem:(opt_id)sourceCollectionItem
                              fromIndexPath:(req_NSIndexPath)fromIndexPath
                                toIndexPath:(req_NSIndexPath)toIndexPath;

- (void)                            binding:(req_AKACollectionControlViewBinding)binding
           sourceControllerDidChangeContent:(req_id)sourceDataController;

@end