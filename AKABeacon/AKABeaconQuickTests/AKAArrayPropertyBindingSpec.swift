import Quick
import Nimble
import AKABeacon

class AKAArrayPropertyBindingSpec: QuickSpec {

    class ArrayTestBindingContext: NSObject, AKABindingContextProtocol {
        dynamic var array: NSArray?
        dynamic var numberValue: NSNumber?
        dynamic var stringValue: NSString?
        dynamic var booleanValue: Bool = true

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

    override func spec() {
        describe("AKAArrayPropertyBinding") {

            context("when set up with constant and variable items") {
                let bindingContext = ArrayTestBindingContext()

                let targetProperty = AKAProperty(
                    ofWeakKeyValueTarget: bindingContext,
                    keyPath: "array",
                    changeObserver: nil)

                let expressionText = "[numberValue, stringValue, booleanValue, 1.0, 2, $true]"
                let bindingType = AKAArrayPropertyBinding.self;
                let expression = try! AKABindingExpression(
                    string: expressionText,
                    bindingType: bindingType)

                let binding = try! AKAArrayPropertyBinding(
                    target: bindingContext,
                    targetValueProperty: targetProperty,
                    expression: expression,
                    context: bindingContext,
                    owner: nil,
                    delegate: nil);

                context("when observing changes") {
                    binding.startObservingChanges()

                    let initialArray = bindingContext.array!;
                    let initialArrayCount = initialArray.count;
                    let initialNumberValue = initialArray[0] is NSNull ? nil : initialArray[0] as? NSNumber

                    describe("initial array count") {
                        it("has 6 elements") {
                            expect(initialArrayCount).to(equal(6))
                        }
                    }
                    describe("initial number value") {
                        it("is undefined") {
                            expect(initialNumberValue).to(beNil()) // probably nsnull
                        }
                    }

                    context("when changing number value") {
                        let newSourceNumberValue = 1.234
                        bindingContext.numberValue = newSourceNumberValue
                        let newNumberValue = bindingContext.array![0] as! NSNumber;

                        describe("changed number value") {
                            it("has been updated") {
                                expect(newNumberValue).to(equal(newSourceNumberValue))
                            }
                        }
                    }

                    binding.stopObservingChanges()
                }
            }
        }
    }

}
