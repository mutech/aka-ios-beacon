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
    dynamic var dateValue: Date
    dynamic var doubleValue: Double

    dynamic var numberFormatter: NumberFormatter
    dynamic var dateFormatter: DateFormatter

    dynamic var pattern: String?
    dynamic var patternOptions: NSString.CompareOptions

    dynamic var matchingSearchResultBackgroundColor: UIColor?

    init(
        text: String = "Default text",
        date: Date = Date(),
        double: Double = 12345.678,
        numberFormatter: NumberFormatter = NumberFormatter(),
        dateFormatter: DateFormatter = DateFormatter(),
        pattern: String? = nil,
        patternOptions: NSString.CompareOptions = .literal)
    {
        self.textValue = text
        self.dateValue = date
        self.doubleValue = double

        self.numberFormatter = numberFormatter
        self.dateFormatter = dateFormatter

        self.pattern = pattern
        self.patternOptions = patternOptions

        self.matchingSearchResultBackgroundColor = UIColor(
            red: 1.0,
            green: 1.0,
            blue: 0.0,
            alpha: 1.0)
    }

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
