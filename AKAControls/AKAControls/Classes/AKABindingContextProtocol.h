//
//  AKABindingContextProtocol.h
//  AKABeacon
//
//  Created by Michael Utech on 19.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
@import AKACommons.AKANullability;
@import AKACommons.AKAProperty;


@protocol AKABindingContextProtocol;
typedef id<AKABindingContextProtocol> _Nonnull        req_AKABindingContext;
typedef id<AKABindingContextProtocol> _Nullable       opt_AKABindingContext;


@protocol AKABindingContextProtocol <NSObject>

- (opt_AKAProperty)     dataContextPropertyForKeyPath:(opt_NSString)keyPath
                                   withChangeObserver:(opt_AKAPropertyChangeObserver)valueDidChange;

- (opt_AKAProperty) rootDataContextPropertyForKeyPath:(opt_NSString)keyPath
                                   withChangeObserver:(opt_AKAPropertyChangeObserver)valueDidChange;

- (opt_AKAProperty)         controlPropertyForKeyPath:(req_NSString)keyPath
                                   withChangeObserver:(opt_AKAPropertyChangeObserver)valueDidChange;

- (opt_id)                 dataContextValueForKeyPath:(req_NSString)keyPath;

- (opt_id)             rootDataContextValueForKeyPath:(req_NSString)keyPath;

- (opt_id)                     controlValueForKeyPath:(req_NSString)keyPath;

@end
