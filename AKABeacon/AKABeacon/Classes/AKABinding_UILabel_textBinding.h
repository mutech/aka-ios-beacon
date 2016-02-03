//
//  AKABinding_UILabel_textBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 15.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAViewBinding.h"
#import "AKAAttributedFormatter.h"

#define opt_AKATransitionAnimationParameters AKATransitionAnimationParameters*_Nullable

@interface AKATransitionAnimationParameters: NSObject

@property(nonatomic) CGFloat duration;
@property(nonatomic) UIViewAnimationOptions options;

@end

@interface AKABinding_UILabel_textBinding: AKAViewBinding

#pragma mark - Binding Configuration

@property(nonatomic, nullable) NSString* textForUndefinedValue;
@property(nonatomic, nullable) NSString* textForYes;
@property(nonatomic, nullable) NSString* textForNo;

@property(nonatomic, nullable) NSNumberFormatter* numberFormatter;
@property(nonatomic, nullable) NSDateFormatter* dateFormatter;
@property(nonatomic, nullable) NSFormatter* formatter;
@property(nonatomic, nullable) AKAAttributedFormatter* textAttributeFormatter;

#pragma mark - Animations

@property(nonatomic, readonly) BOOL isTransitionAnimationActive;
@property(nonatomic)           opt_AKATransitionAnimationParameters transitionAnimation;

@end
