//
//  AKATableViewSectionDataSourceInfo.h
//  AKABeacon
//
//  Created by Michael Utech on 21.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;

#import "AKATableViewCellFactory.h"

#pragma mark - AKATableViewSectionDataSourceInfo Interface
#pragma mark -

@interface AKATableViewSectionDataSourceInfo: NSObject

@property(nonatomic) NSArray* rows;
@property(nonatomic) NSString* headerTitle;
@property(nonatomic) NSString* footerTitle;
@property(nonatomic) NSArray<AKATableViewCellFactory*>* cellMapping;

@end
