//
//  AKABinding_UISegmentedControl_valueBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 20.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKASelectionControlViewBinding.h"

@interface AKABinding_UISegmentedControl_valueBinding : AKASelectionControlViewBinding

@property(nonatomic, readonly) opt_AKABindingExpression             choicesBindingExpression;
@property(nonatomic, readonly) BOOL                                 preferTitleOverImage;
@property(nonatomic, readonly) opt_AKABindingExpression             titleBindingExpression;
@property(nonatomic, readonly) opt_NSString                         titleForUndefinedValue;
@property(nonatomic, readonly) opt_NSString                         titleForOtherValue;
@property(nonatomic, readonly) opt_AKABindingExpression             imageBindingExpression;
@property(nonatomic, readonly) opt_NSString                         imageForUndefinedValue;
@property(nonatomic, readonly) opt_NSString                         imageForOtherValue;

@property(nonatomic, readonly) BOOL                                 needsReloadChoices;
@property(nonatomic, readonly, nullable) id                         otherValue;

@end
