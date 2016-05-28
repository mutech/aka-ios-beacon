//
//  UIView+AKAIBBindingProperties_styleBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 21.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit.UIView;


IB_DESIGNABLE
@interface UIView (AKAIBBindingProperties_styleBinding)

@property(nonatomic, nullable) IBInspectable NSString* styleBinding_aka;

#pragma mark - Sub classes

/**
 Used by styleBinding_aka to determine the type of style bindings. Sub classes
 can override this property to extend style bindings. The result has to be a
 subclass of AKABinding_UIView_styleBinding.
 */
@property(nonatomic, readonly, nonnull) Class aka_styleBindingType;

@end
