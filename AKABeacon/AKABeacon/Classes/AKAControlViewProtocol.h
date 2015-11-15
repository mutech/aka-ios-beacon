//
//  AKAControlViewProtocol.h
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;
@import AKACommons.AKANullability;

#import "AKAControlConfiguration.h"


/**
 Identifies an object (typically an instance of UIView) as serving the role of a control view.

 A control view is a view which allows the user to interactively change the data presented by the view or more generally to change the state of the application.
 
 The name "ControlView" loosely corresponds to the concept of UIControls, however, a control view does not have to be a subclass of UIControl and while all subclasses of UIControl are conceptually control views, they are not automatically supported as such.
 
 Control views can be bound to source data using AKAControlViewBindings. Supported control views typically provide a specific binding type which adapts the control views visual state to a binding target property. The binding takes care of converting and validating source and target values and generally propagates changes in both directions.
 
 Control views are recognized by AKAControls and when a form control is scanning a view hierarchy, it will create an instance of AKAControl for each view implementing this interface.

 If such a view is encountered when a composite control is scanning view hierarchies, a control will be created and configured with the information specified in the control configuration.
 
 @see UIControl
 @see AKAControlViewBinding
 @see AKAControlConfiguration
 @see AKAControl
 */
@protocol AKAControlViewProtocol

/**
 An object holding configuration information. This information is used by AKAControl
 instances owning the AKAControlViewBinding associated with this control view (if any).
 
 @note Do not rely on implementation details of AKAControlConfiguration or use the information outside of AKAControl implementations.
 */
@property(nonatomic, readonly, nonnull) AKAControlConfiguration* aka_controlConfiguration;

/**
 Sets the specified value for the configuration item with the specified key.

 @note Do not use this method for any other purpose than to implement IB inpsectable properties for configuration parameters of AKAControl instances.

 @param value the new value of the configuration item
 @param key the name of the configuration item
 */
- (void)aka_setControlConfigurationValue:(opt_id)value forKey:(req_NSString)key;

@end


