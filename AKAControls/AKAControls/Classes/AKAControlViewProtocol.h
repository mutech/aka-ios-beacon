//
//  AKAControlViewProtocol.h
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "AKAControlViewBindingConfigurationProtocol.h"

@class AKAControl;
@class AKACompositeControl;
@class AKAControlViewBinding;
@class AKAProperty;

/**
 * ControlViews are typically UIViews, but they might also represent things like the
 * title of a UIViewController. Control views implement the
 * AKAControlBindingConfigurationProtocol.
 */
@protocol AKAControlViewProtocol <AKAControlViewBindingConfigurationProtocol>

/**
 * The type of binding that should be used to bind this view. Views typically should
 * or even have to implement the binding configuration required by the binding type.
 *
 * If this property value is nil, the default binding type is used
 * which will try to find the best match depending on the type of this view.
 */
//@optional
@property(nonatomic, readonly) Class preferredBindingType;

@end
