//
//  AKATableViewSectionDataSourceInfoPropertyBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 21.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAPropertyBinding.h"
#import "AKAArrayPropertyBinding.h"
#import "AKATableViewSectionDataSourceInfo.h"


#pragma mark - AKATableViewSectionDataSourceInfoPropertyBinding Interface
#pragma mark -

@interface AKATableViewSectionDataSourceInfoPropertyBinding: AKAPropertyBinding<AKAArrayPropertyBindingDelegate>

@property(nonatomic, readonly) AKATableViewSectionDataSourceInfo* sectionDataSourceInfo;

@end
