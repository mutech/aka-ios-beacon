//
//  AKAControlViewProtocol.h
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
#import "AKAControlConfiguration.h"

/**
 * This protocol identifies an object as serving the role of a control view. If such a view
 * is encountered when a composite control is scanning view hierarchies, a control will be
 * created and configured with the information specified in the control configuration.
 */
@protocol AKAControlViewProtocol

@property(nonatomic, readonly) AKAControlConfiguration* aka_controlConfiguration;

- (void)aka_setControlConfigurationValue:(id)value forKey:(NSString*)key;

@end


