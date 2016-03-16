import Quick
import Nimble
import AKABeacon

class UITextViewBindingsSpec: QuickSpec {

    override func spec() {
        describe("UITextView") {
            // Arrange
            let initialText = "Initial text";
            let view = UITextView(frame: CGRect());
            view.text = initialText;

            context("when bound") {
                // Arrange
                let property = Selector("textBinding_aka")
                view.textBinding_aka = "textValue"
                let expression: AKABindingExpression! = view.aka_bindingExpressionForProperty(property)!

                let bindingContext = TestModel();
                let initialModelValue = bindingContext.textValue;

                let bindingType: AKAViewBinding.Type? = expression.specification?.bindingType as? AKAViewBinding.Type;

                // Act
                let binding = try! bindingType?.init (
                    view: view,
                    expression: expression,
                    context: bindingContext,
                    delegate: nil);
                let textAfterBindingCreation = view.text;

                // Assert
                it("did not yet change its initial text") {
                    expect(textAfterBindingCreation).to(equal(initialText));
                }

                context("when observing changes") {
                    binding!.startObservingChanges()
                    let textAfterStartObservingChanges = view.text;

                    it("updates its text to bound value") {
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

                    context("when view changes") {
                        let changedViewValue = "new view Value"
                        view.text = changedViewValue;
                        view.delegate?.textViewDidChange!(view);
                        let modelValueAfterViewChange = bindingContext.textValue;


                        it("updates model value") {
                            expect(modelValueAfterViewChange).to(equal(changedViewValue))
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
