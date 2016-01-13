import Quick
import Nimble
import AKABeacon
import AKACommons

class AKATableViewCellFactoryArrayPropertyBindingSpec: QuickSpec {

    class CellFactoryTestBindingContext: TestBaseBindingContext {
        dynamic var cellMapping: [AKATableViewCellFactory]?
    }

    override func spec() {
        describe("AKATableViewCellFactoryArrayPropertyBinding") {
            context("set up with type predicate and fallback") {
                let bindingContext = CellFactoryTestBindingContext()

                let targetProperty = AKAProperty(
                    ofWeakKeyValueTarget: bindingContext,
                    keyPath: "cellMapping",
                    changeObserver: nil)

                let mappings = [
                    "{ predicate: <NSString>, cellIdentifier: \"string\" }",
                    "{ cellIdentifier: \"default\" }",
                ]
                let expressionText = "[ \(mappings.joinWithSeparator(", "))]"
                let expression = try! AKABindingExpression(
                    string: expressionText,
                    bindingType: AKATableViewCellFactoryArrayPropertyBinding.self)

                let binding = try! AKATableViewCellFactoryArrayPropertyBinding(
                    target: targetProperty,
                    property: nil,
                    expression: expression,
                    context: bindingContext,
                    delegate: nil)

                context("when observing changes") {
                    binding.startObservingChanges()

                    let cellMapping = bindingContext.cellMapping

                    describe("cell mapping") {
                        it("is defined") {
                            expect(cellMapping).toNot(beNil())
                        }

                        it("contains two cell factories") {
                            expect(cellMapping!.count).to(equal(2))
                        }

                        describe("first factory") {
                            let firstFactory = cellMapping![0]

                            it("defines cellIndentifier as string") {
                                expect(firstFactory.cellIdentifier).to(equal("string"))
                            }

                            it("defines a predicate") {
                                expect(firstFactory.predicate).toNot(beNil())
                            }
                        }

                        describe("second factory") {
                            let secondFactory = cellMapping![1]

                            it("defines cellIdentifier as default") {
                                expect(secondFactory.cellIdentifier).to(equal("default"))
                            }

                            it("does not define a predicate") {
                                expect(secondFactory.predicate).to(beNil())
                            }
                        }
                    }
                    binding.stopObservingChanges()
                }
            }
        }
    }
}
