import Quick
import Nimble
import AKABeacon

class UILabelBindingsSpec: QuickSpec {
    override func spec() {
        describe("UILabelView") {
            context("when bound to a text") {
                let initialText = "Initial text";
                let view = UILabel(frame: CGRect());
                view.text = initialText;

                let property = Selector("textBinding_aka")
                view.textBinding_aka = "textValue"
                let expression: AKABindingExpression! = view.aka_bindingExpressionForProperty(property)!

                let bindingContext = TestModel();
                let initialModelValue = bindingContext.textValue;

                let bindingType: AKABinding.Type = expression.bindingType as! AKABinding.Type;
                let binding = try! bindingType.init (
                    target: view,
                    property: property,
                    expression: expression,
                    context: bindingContext,
                    delegate: nil);

                let textAfterBindingCreation = view.text;

                it("does not change its initial text") {
                    expect(textAfterBindingCreation).to(equal(initialText));
                }

                context("when observing changes") {
                    binding.startObservingChanges()
                    let textAfterStartObservingChanges = view.text;

                    it("updates text to bound value") {
                        expect(textAfterStartObservingChanges).to(equal(initialModelValue))
                    }

                    context("when model changes") {
                        let changedModelValue = "new value"
                        bindingContext.textValue = changedModelValue
                        let textAfterModelChange = view.text

                        it("updates text to new value") {
                            expect(textAfterModelChange).to(equal(changedModelValue))
                        }
                    }

                    context("when no longer observing changes") {
                        binding.stopObservingChanges()
                        let textAfterStopObservingChanges = view.text
                        it("reverts text to initial value") {
                            expect(textAfterStopObservingChanges).to(equal(initialText));
                        }
                    }
                }
            }

            context("when bound to a date") {
                let initialText = "Initial text";
                let view = UILabel(frame: CGRect());
                view.text = initialText;

                let property = Selector("textBinding_aka")
                view.textBinding_aka = "dateValue { dateFormatter: dateFormatter }"
                let expression: AKABindingExpression! = view.aka_bindingExpressionForProperty(property)!

                let bindingContext = TestModel();
                let initialFormattedModelValue = bindingContext.dateFormatter.stringFromDate(bindingContext.dateValue);

                let bindingType: AKABinding.Type = expression.bindingType as! AKABinding.Type;
                let binding = try! bindingType.init (
                    target: view,
                    property: property,
                    expression: expression,
                    context: bindingContext,
                    delegate: nil);

                let textAfterBindingCreation = view.text;

                it("does not change its initial text") {
                    expect(textAfterBindingCreation).to(equal(initialText));
                }

                context("when observing changes") {
                    binding.startObservingChanges()
                    let textAfterStartObservingChanges = view.text;

                    it("updates text to bound value") {
                        expect(textAfterStartObservingChanges).to(equal(initialFormattedModelValue))
                    }

                    context("when model changes") {
                        let changedModelValue = NSDate()
                        bindingContext.dateValue = changedModelValue
                        let changedFormattedModelValue = bindingContext.dateFormatter.stringFromDate(changedModelValue)
                        let textAfterModelChange = view.text

                        it("updates text to new value") {
                            expect(textAfterModelChange).to(equal(changedFormattedModelValue))
                        }
                    }

                    context("when no longer observing changes") {
                        binding.stopObservingChanges()
                        let textAfterStopObservingChanges = view.text
                        it("reverts text to initial value") {
                            expect(textAfterStopObservingChanges).to(equal(initialText));
                        }
                    }
                }
            }

            context("when bound to a number") {
                let initialText = "Initial text";
                let view = UILabel(frame: CGRect());
                view.text = initialText;

                let property = Selector("textBinding_aka")
                view.textBinding_aka = "doubleValue { numberFormatter: numberFormatter }"
                let expression: AKABindingExpression! = view.aka_bindingExpressionForProperty(property)!

                let bindingContext = TestModel();
                let initialFormattedModelValue = bindingContext.numberFormatter.stringFromNumber(bindingContext.doubleValue);

                let bindingType: AKABinding.Type = expression.bindingType as! AKABinding.Type;
                let binding = try! bindingType.init (
                    target: view,
                    property: property,
                    expression: expression,
                    context: bindingContext,
                    delegate: nil);

                let textAfterBindingCreation = view.text;

                it("does not change its initial text") {
                    expect(textAfterBindingCreation).to(equal(initialText));
                }

                context("when observing changes") {
                    binding.startObservingChanges()
                    let textAfterStartObservingChanges = view.text;

                    it("updates text to bound value") {
                        expect(textAfterStartObservingChanges).to(equal(initialFormattedModelValue))
                    }

                    context("when model changes") {
                        let changedModelValue = 4.99;
                        bindingContext.doubleValue = changedModelValue
                        let changedFormattedModelValue = bindingContext.numberFormatter.stringFromNumber(changedModelValue)
                        let textAfterModelChange = view.text

                        it("updates text to new value") {
                            expect(textAfterModelChange).to(equal(changedFormattedModelValue))
                        }
                    }

                    context("when no longer observing changes") {
                        binding.stopObservingChanges()
                        let textAfterStopObservingChanges = view.text
                        it("reverts text to initial value") {
                            expect(textAfterStopObservingChanges).to(equal(initialText));
                        }
                    }
                }
            }
        }
    }
}
