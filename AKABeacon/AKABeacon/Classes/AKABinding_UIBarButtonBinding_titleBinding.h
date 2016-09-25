//
//  AKABinding_UIBarButtonBinding_titleBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 15.09.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAViewBinding.h"
#import "AKAAttributedFormatter.h"
#import "AKATransitionAnimationParameters.h"

@interface AKABinding_UIBarButtonBinding_titleBinding : AKABinding

#pragma mark - Binding Configuration

@property(nonatomic, nullable) NSString* textForUndefinedValue;
@property(nonatomic, nullable) NSString* textForYes;
@property(nonatomic, nullable) NSString* textForNo;

@property(nonatomic, nullable) NSNumberFormatter* numberFormatter;
@property(nonatomic, nullable) NSDateFormatter* dateFormatter;
@property(nonatomic, nullable) NSFormatter* formatter;

@end
