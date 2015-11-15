//
//  AKABinding_UILabel_textBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 15.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAViewBinding.h"


@interface AKABinding_UILabel_textBinding: AKAViewBinding

#pragma mark - Binding Configuration

@property(nonatomic, nullable) NSString* textForUndefinedValue;
@property(nonatomic, nullable) NSString* textForYes;
@property(nonatomic, nullable) NSString* textForNo;

@property(nonatomic, nullable) NSNumberFormatter* numberFormatter;
@property(nonatomic, nullable) NSDateFormatter* dateFormatter;
@property(nonatomic, nullable) NSFormatter* formatter;

@end
