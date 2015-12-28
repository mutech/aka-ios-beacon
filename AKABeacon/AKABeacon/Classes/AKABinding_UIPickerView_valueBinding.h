//
//  AKABinding_UIPickerView_valueBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 24.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKASelectionControlViewBinding.h"

@interface AKABinding_UIPickerView_valueBinding : AKASelectionControlViewBinding

@property(nonatomic, readonly) opt_AKABindingExpression             choicesBindingExpression;
@property(nonatomic, readonly) opt_AKABindingExpression             titleBindingExpression;
@property(nonatomic, readonly) opt_NSString                         titleForUndefinedValue;
@property(nonatomic, readonly) opt_NSString                         titleForOtherValue;

@property(nonatomic, readonly) BOOL                                 needsReloadChoices;
@property(nonatomic, readonly, nullable) id                         otherValue;

- (NSComparisonResult)orderInChoicesForValue:(nullable id)firstValue value:(nullable id)secondValue;

@end
