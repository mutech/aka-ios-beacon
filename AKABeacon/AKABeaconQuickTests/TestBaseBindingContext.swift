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

    func dataContextProperty(forKeyPath keyPath: String?, withChangeObserver valueDidChange: AKAPropertyChangeObserver?) -> AKAProperty? {
        return AKAProperty.init(ofWeakKeyValueTarget: self, keyPath: keyPath, changeObserver: valueDidChange);
    }

    func dataContextValue(forKeyPath keyPath: String?) -> AnyObject? {
        return dataContextProperty(forKeyPath: keyPath, withChangeObserver: nil)?.value as AnyObject?;
    }

    func rootDataContextProperty(forKeyPath keyPath: String?, withChangeObserver valueDidChange: AKAPropertyChangeObserver?) -> AKAProperty? {
        return self.dataContextProperty(forKeyPath: keyPath, withChangeObserver: valueDidChange);
    }

    func rootDataContextValue(forKeyPath keyPath: String?) -> AnyObject? {
        return rootDataContextProperty(forKeyPath: keyPath, withChangeObserver: nil)?.value as AnyObject?;
    }

    func controlProperty(forKeyPath keyPath: String, withChangeObserver valueDidChange: AKAPropertyChangeObserver?) -> AKAProperty? {
        return nil;
    }

    func controlValue(forKeyPath keyPath: String?) -> AnyObject? {
        return nil;
    }
}
