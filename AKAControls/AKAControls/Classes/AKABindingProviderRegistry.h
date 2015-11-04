//
//  AKABindingProviderRegistry.h
//  AKABeacon
//
//  Created by Michael Utech on 20.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
@import AKACommons.AKANullability;

@interface AKABindingProviderRegistry : NSObject

- (void)registerBindingProvider:(req_AKABindingProvider)provider
                    forProperty:(req_SEL)selector
                         inType:(req_Class)type;

@end
