//
//  TestModel.swift
//  AKABeacon
//
//  Created by Michael Utech on 22.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

import Foundation
import AKABeacon

@objc
class TestModel: NSObject, AKABindingContextProtocol {
    dynamic var textValue: String
    dynamic var dateValue: NSDate
    dynamic var doubleValue: Double

    dynamic var numberFormatter: NSNumberFormatter
    dynamic var dateFormatter: NSDateFormatter

    init(text: String = "Default text", date: NSDate = NSDate(), double: Double = 12345.678, numberFormatter: NSNumberFormatter = NSNumberFormatter(), dateFormatter: NSDateFormatter = NSDateFormatter()) {
        self.textValue = text
        self.dateValue = date
        self.doubleValue = double

        self.numberFormatter = numberFormatter
        self.dateFormatter = dateFormatter
    }

    func dataContextPropertyForKeyPath(keyPath: String?, withChangeObserver valueDidChange: AKAPropertyChangeObserver?) -> AKAProperty? {
        return AKAProperty.init(ofWeakKeyValueTarget: self, keyPath: keyPath, changeObserver: valueDidChange);
    }

    func dataContextValueForKeyPath(keyPath: String) -> AnyObject? {
        return dataContextPropertyForKeyPath(keyPath, withChangeObserver: nil)?.value;
    }

    func rootDataContextPropertyForKeyPath(keyPath: String?, withChangeObserver valueDidChange: AKAPropertyChangeObserver?) -> AKAProperty? {
        return self.dataContextPropertyForKeyPath(keyPath, withChangeObserver: valueDidChange);
    }

    func rootDataContextValueForKeyPath(keyPath: String) -> AnyObject? {
        return rootDataContextPropertyForKeyPath(keyPath, withChangeObserver: nil)?.value;
    }

    func controlPropertyForKeyPath(keyPath: String, withChangeObserver valueDidChange: AKAPropertyChangeObserver?) -> AKAProperty? {
        return nil;
    }

    func controlValueForKeyPath(keyPath: String) -> AnyObject? {
        return nil;
    }
}
