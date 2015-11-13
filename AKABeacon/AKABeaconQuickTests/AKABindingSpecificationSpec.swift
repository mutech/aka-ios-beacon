//
//  AKABindingSpecificationSpec.swift
//  AKABeacon
//
//  Created by Michael Utech on 12.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

import Quick
import Nimble;
import AKABeacon


func beASubclassOf(expectedClass: AnyClass) -> MatcherFunc<AnyClass> {
    return MatcherFunc { actualExpression, failureMessage in
        let instance: AnyClass? = try actualExpression.evaluate()
        if let validInstance = instance {
            failureMessage.actualValue = "<\(NSStringFromClass(validInstance as AnyClass))>"
        } else {
            failureMessage.actualValue = "<nil>"
        }
        failureMessage.postfixMessage = "be a subclass of \(NSStringFromClass(expectedClass))"
        return instance != nil && instance!.isSubclassOfClass(expectedClass)
    }
}

class AKABindingSpecificationSpec: QuickSpec
{
    class BaseBindingProvider: AKABindingProvider {
        override class func sharedInstance() -> BaseBindingProvider {
            struct Static {
                static var onceToken: dispatch_once_t = 0;
                static var result: BaseBindingProvider? = nil;
            }
            dispatch_once(&Static.onceToken) {
                Static.result = BaseBindingProvider();
            }
            return Static.result!;
        }
    }

    class TestBindingProvider: BaseBindingProvider {
        override class func sharedInstance() -> TestBindingProvider {
            struct Static {
                static var onceToken: dispatch_once_t = 0;
                static var result: TestBindingProvider? = nil;
            }
            dispatch_once(&Static.onceToken) {
                Static.result = TestBindingProvider();
            }
            return Static.result!;
        }
    }

    
    override func spec()
    {
        describe("a binding specification") {

            context("if it is created with a specification dictionary") {
                let bindingType = AKAKeyboardControlViewBinding.self;
                let bindingProviderType = AKAKeyboardControlViewBindingProvider.self;
                let expressionType = NSNumber(unsignedLongLong: AKABindingExpressionType.Any.rawValue);

                let dictionary: Dictionary<String, AnyObject> = [
                    "bindingType": bindingType,
                    "bindingProviderType": bindingProviderType,
                    "targetType": UIResponder.self,
                    "expressionType": expressionType,
                    "liveModelUpdates": [
                        "expressionType": NSNumber(unsignedLongLong: AKABindingExpressionType.Boolean.rawValue),
                    ],
                ];

                let specification: AKABindingSpecification? = AKABindingSpecification(
                    dictionary: dictionary,
                    basedOn: nil);

                it("initializes its properties correctly") {
                    expect(specification).notTo(beNil());
                    expect(specification!.bindingProvider).to(beAKindOf(bindingProviderType));
                    expect(specification!.bindingType).to(beASubclassOf(bindingType));
                }
            }
        }
    }
}
