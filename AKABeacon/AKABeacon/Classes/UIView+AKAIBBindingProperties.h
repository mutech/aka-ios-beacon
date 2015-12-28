//
//  UIView+AKAIBBindingProperties.h
//  AKABeacon
//
//  Created by Michael Utech on 15.12.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;

IB_DESIGNABLE
@interface UIView (AKAIBBindingProperties)

@property(nonatomic, nullable) IBInspectable NSString* styleBinding_aka;

@end


@interface UIView (AKAIBBindingProperties_Protected)

/**
 Used by styleBinding_aka to determine the type of style bindings. Sub classes
 can override this property to extend style bindings. The result has to be a
 subclass of AKABinding_UIView_styleBinding.
 */
@property(nonatomic, readonly, nonnull) Class aka_styleBindingType;

@end