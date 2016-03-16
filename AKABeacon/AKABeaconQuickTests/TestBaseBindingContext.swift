//
//  TestBaseBindingContext.swift
//  AKABeacon
//
//  Created by Michael Utech on 09.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

import Foundation
import AKABeacon

class TestBaseBindingContext: NSObject, AKABindingContextProtocol {

    func dataContextPropertyForKeyPath(keyPath: String?, withChangeObserver valueDidChange: AKAPropertyChangeObserver?) -> AKAProperty? {
        return AKAProperty.init(ofWeakKeyValueTarget: self, keyPath: keyPath, changeObserver: valueDidChange);
    }

    func dataContextValueForKeyPath(keyPath: String?) -> AnyObject? {
        return dataContextPropertyForKeyPath(keyPath, withChangeObserver: nil)?.value;
    }

    func rootDataContextPropertyForKeyPath(keyPath: String?, withChangeObserver valueDidChange: AKAPropertyChangeObserver?) -> AKAProperty? {
        return self.dataContextPropertyForKeyPath(keyPath, withChangeObserver: valueDidChange);
    }

    func rootDataContextValueForKeyPath(keyPath: String?) -> AnyObject? {
        return rootDataContextPropertyForKeyPath(keyPath, withChangeObserver: nil)?.value;
    }

    func controlPropertyForKeyPath(keyPath: String, withChangeObserver valueDidChange: AKAPropertyChangeObserver?) -> AKAProperty? {
        return nil;
    }

    func controlValueForKeyPath(keyPath: String?) -> AnyObject? {
        return nil;
    }
}