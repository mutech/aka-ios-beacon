//
//  AKABindingProvider_UILabel_textBinding.h
//  AKAControls
//
//  Created by Michael Utech on 29.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABindingProvider.h"

@interface AKABindingProvider_UILabel_textBinding : AKABindingProvider

+ (instancetype _Nonnull)sharedInstance;

@end

@interface AKABinding_UILabel_textBinding: AKABinding

#pragma mark - Binding Configuration

@property(nonatomic, nullable) NSString* textForUndefinedValue;

@property(nonatomic, nullable) NSNumberFormatter* numberFormatter;

@end