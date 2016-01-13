import Quick
import Nimble

class UILabelBindingsWithTextAttributes: QuickSpec {

    override func spec() {
        describe("UILabelView") {
            let initialText = "Initial text";
            let view = UILabel(frame: CGRect());
            view.text = initialText;

            context("when bound with text attribute pattern") {
                let property = Selector("textBinding_aka")
                let attributesSpec = "textAttributeFormatter: { pattern: pattern, backgroundColor: matchingSearchResultBackgroundColor }";
                view.textBinding_aka = "textValue { \(attributesSpec) }";

                let expression: AKABindingExpression! = view.aka_bindingExpressionForProperty(property)!

                let bindingContext = TestModel();
                let initialModelValue = bindingContext.textValue;

                let bindingType: AKABinding.Type? = expression.specification?.bindingType as? AKABinding.Type;
                let binding: AKABinding_UILabel_textBinding? = try! bindingType?.init (
                    target: view,
                    property: property,
                    expression: expression,
                    context: bindingContext,
                    delegate: nil) as! AKABinding_UILabel_textBinding;

                /* TODO: refactor test, attributeBindings no longer available
                describe("binding") {
                    describe("textAttributeFormatter attribute binding") {
                        let textAttributeFormatterBinding = binding?.attributeBindings?["textAttributeFormatter"] as? AKABinding_AKABinding_attributedFormatter;
                        it("is not nil") {
                            expect(textAttributeFormatterBinding).toNot(beNil())
                        }
                        context("when observing changes") {
                            binding!.startObservingChanges()
                            describe("binding source") {
                                let bindingSourceProperty = textAttributeFormatterBinding!.bindingSource
                                it("is not nil") {
                                    expect(bindingSourceProperty).toNot(beNil())
                                }
                                describe("value") {
                                    let value = bindingSourceProperty.value
                                    it("is nil") {
                                        expect(value).to(beNil())
                                    }
                                }
                            }
                            describe("binding target") {
                                let bindingTargetProperty = textAttributeFormatterBinding!.bindingTarget
                                it("is not nil") {
                                    expect(bindingTargetProperty).toNot(beNil())
                                }
                                describe("value") {
                                    let value = bindingTargetProperty.value as? AKAAttributedFormatter
                                    it("is not nil") {
                                        expect(value).toNot(beNil())
                                    }
                                    it("targets the bindings attributedTextFormatter property") {
                                        expect(value).to(beIdenticalTo(binding?.textAttributeFormatter as? AnyObject))
                                    }
                                }
                            }

                            context("when pattern changes") {
                                let expectedPattern = "t"
                                bindingContext.pattern = expectedPattern
                                describe("attributed formatter") {
                                    let formatter = textAttributeFormatterBinding?.formatter as! AKAAttributedFormatter
                                    let pattern = formatter.pattern
                                    it("updated its pattern") {
                                        expect(pattern).to(equal(expectedPattern));
                                    }
                                }
                            }
                        }
                    }
                }
                */

                context("when observing changes") {
                    binding!.startObservingChanges()
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
                        binding!.stopObservingChanges()
                        let textAfterStopObservingChanges = view.text
                        it("does not revert text to initial value") {
                            expect(textAfterStopObservingChanges).toNot(equal(initialText));
                        }
                    }
                }
            }

        }
    }
}
