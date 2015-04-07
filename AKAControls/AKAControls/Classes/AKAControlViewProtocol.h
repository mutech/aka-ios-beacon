//
//  AKAControlViewProtocol.h
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "AKAViewBindingConfiguration.h"

@class AKAControl;

/**
 * This protocol identifies an object as serving the role of a control view that can be
 * bound as view to an instance of AKAControl or one of its sub classes.
 *
 * A control view (an object conforming to this protocol) provides the <bindingConfiguration>
 * required to establish the binding.
 *
 * ControlViews are typically UIViews, but they might also represent things like the
 * title of a UIViewController.
 */
@protocol AKAControlViewProtocol

@property (nonatomic, readonly) AKAViewBindingConfiguration* bindingConfiguration;

@optional
/**
 * If implemented by the conforming class, this method is called whenever the
 * control view binding to this instance is changed.
 *
 * @param oldBinding the old binding
 * @param newBinding the current (new) binding
 */
- (void)viewBindingChangedFrom:(AKAControl*)oldBinding
                            to:(AKAControl*)newBinding;

@end
