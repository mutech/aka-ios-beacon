import Quick
import Nimble
import AKABeacon
import AKACommons

class AKAPredicatePropertyBindingSpec: QuickSpec {

    class PredicateTestBindingContext: TestBaseBindingContext {
        dynamic var predicate: NSPredicate?
        dynamic var predicateSource: AnyObject?

        dynamic var classPattern: AnyClass?
    }

    override func spec() {
        describe("AKAPredicatePropertyBinding") {

            context("when set up with format and substitution variables") {
                let bindingContext = PredicateTestBindingContext()
                bindingContext.classPattern = PredicateTestBindingContext.self
                
                let targetProperty = AKAProperty(
                    ofWeakKeyValueTarget: bindingContext,
                    keyPath: "predicate",
                    changeObserver: nil)

                let expressionText = "\"self isKindOfClass:$classPattern\" { classPattern: classPattern }"
                let expression = try! AKABindingExpression(
                    string: expressionText,
                    bindingType: AKAPredicatePropertyBinding.self)

                let binding = try! AKAPredicatePropertyBinding(
                    target: targetProperty,
                    expression: expression,
                    context: bindingContext,
                    delegate: nil);

                context("when observing changes") {
                    binding.startObservingChanges()
                    let initialPredicate = bindingContext.predicate

                    describe("initial predicate") {
                        let matchingObject = bindingContext;
                        let matchingObjectResult = initialPredicate!.evaluateWithObject(matchingObject)

                        let nonMatchingObject = "Some text expected not to satisfy the predicate"
                        let nonMatchingObjectResult = initialPredicate!.evaluateWithObject(nonMatchingObject)

                        it("is defined") {
                            expect(initialPredicate).toNot(beNil())
                        }
                        it("evaluates positively for matching object") {
                            expect(matchingObjectResult).to(beTrue())
                        }
                        it("evaluates negatively for nonmatching object") {
                            expect(nonMatchingObjectResult).to(beFalse())
                        }
                    }

                    context("when changing substitution value") {
                        bindingContext.classPattern = NSString.self
                        let newPredicate = bindingContext.predicate

                        describe("changed predicate") {
                            let matchingObject = "Some text expected not to satisfy the predicate"
                            let matchingObjectResult = newPredicate!.evaluateWithObject(matchingObject)

                            let nonMatchingObject = bindingContext
                            let nonMatchingObjectResult = newPredicate!.evaluateWithObject(nonMatchingObject)

                            it("is defined") {
                                expect(newPredicate).toNot(beNil())
                                expect(newPredicate).toNot(beIdenticalTo(initialPredicate))
                            }
                            it("evaluates positively for matching object") {
                                expect(matchingObjectResult).to(beTrue())
                            }
                            it("evaluates negatively for nonmatching object") {
                                expect(nonMatchingObjectResult).to(beFalse())
                            }
                        }
                    }

                    binding.stopObservingChanges()
                }
            }

            context("when set up with predicate key and substitution variables") {
                let bindingContext = PredicateTestBindingContext()
                bindingContext.classPattern = PredicateTestBindingContext.self
                bindingContext.predicateSource = NSPredicate(format: "self isKindOfClass:$classPattern")

                let targetProperty = AKAProperty(
                    ofWeakKeyValueTarget: bindingContext,
                    keyPath: "predicate",
                    changeObserver: nil)

                let expressionText = "predicateSource { classPattern: classPattern }"
                let expression = try! AKABindingExpression(
                    string: expressionText,
                    bindingType: AKAPredicatePropertyBinding.self)

                let binding = try! AKAPredicatePropertyBinding(
                    target: targetProperty,
                    expression: expression,
                    context: bindingContext,
                    delegate: nil);

                context("when observing changes") {
                    binding.startObservingChanges()
                    let initialPredicate = bindingContext.predicate

                    describe("initial predicate") {
                        let matchingObject = bindingContext;
                        let matchingObjectResult = initialPredicate!.evaluateWithObject(matchingObject)

                        let nonMatchingObject = "Some text expected not to satisfy the predicate"
                        let nonMatchingObjectResult = initialPredicate!.evaluateWithObject(nonMatchingObject)

                        it("is defined") {
                            expect(initialPredicate).toNot(beNil())
                        }
                        it("evaluates positively for matching object") {
                            expect(matchingObjectResult).to(beTrue())
                        }
                        it("evaluates negatively for nonmatching object") {
                            expect(nonMatchingObjectResult).to(beFalse())
                        }
                    }

                    context("when changing substitution value") {
                        bindingContext.classPattern = NSString.self
                        let predicateAfterSubsValueChanged = bindingContext.predicate

                        describe("changed predicate") {
                            let matchingObject = "Some text expected to satisfy the predicate"
                            let matchingObjectResult = predicateAfterSubsValueChanged!.evaluateWithObject(matchingObject)

                            let nonMatchingObject = bindingContext
                            let nonMatchingObjectResult = predicateAfterSubsValueChanged!.evaluateWithObject(nonMatchingObject)

                            it("is defined") {
                                expect(predicateAfterSubsValueChanged).toNot(beNil())
                                expect(predicateAfterSubsValueChanged).toNot(beIdenticalTo(initialPredicate))
                            }
                            it("evaluates positively for matching object") {
                                expect(matchingObjectResult).to(beTrue())
                            }
                            it("evaluates negatively for nonmatching object") {
                                expect(nonMatchingObjectResult).to(beFalse())
                            }
                        }
                    }

                    context("when changing predicate source to predicate") {
                        bindingContext.classPattern = PredicateTestBindingContext.self
                        
                        let previousPredicate = bindingContext.predicate
                        bindingContext.predicateSource = NSPredicate(format: "NOT self isKindOfClass:$classPattern")
                        let newPredicate = bindingContext.predicate

                        describe("changed predicate") {
                            let matchingObject = "Some text expected to satisfy the predicate"
                            let matchingObjectResult = newPredicate!.evaluateWithObject(matchingObject)

                            let nonMatchingObject = bindingContext
                            let nonMatchingObjectResult = newPredicate!.evaluateWithObject(nonMatchingObject)

                            it("is updated to another defined predicate") {
                                expect(newPredicate).toNot(beNil())
                                expect(newPredicate).toNot(beIdenticalTo(previousPredicate))
                            }
                            it("evaluates positively for matching object") {
                                expect(matchingObjectResult).to(beTrue())
                            }
                            it("evaluates negatively for nonmatching object") {
                                expect(nonMatchingObjectResult).to(beFalse())
                            }
                        }
                    }

                    context("when changing predicate source to constant true") {
                        let previousPredicate = bindingContext.predicate
                        bindingContext.predicateSource = true
                        let newPredicate = bindingContext.predicate

                        describe("changed predicate") {
                            let resultForNil = newPredicate!.evaluateWithObject(nil)
                            let resultForString = newPredicate!.evaluateWithObject("string")
                            let resultForBindingContext = newPredicate!.evaluateWithObject(bindingContext)

                            it("is updated to another defined predicate") {
                                expect(newPredicate).toNot(beNil())
                                expect(newPredicate).toNot(beIdenticalTo(previousPredicate))
                            }
                            it("evaluates positively for any object") {
                                expect(resultForNil).to(beTrue())
                                expect(resultForString).to(beTrue())
                                expect(resultForBindingContext).to(beTrue())
                            }
                        }
                    }

                    context("when changing predicate source to constant false") {
                        let previousPredicate = bindingContext.predicate
                        bindingContext.predicateSource = false
                        let newPredicate = bindingContext.predicate

                        describe("changed predicate") {
                            let resultForNil = newPredicate!.evaluateWithObject(nil)
                            let resultForString = newPredicate!.evaluateWithObject("string")
                            let resultForBindingContext = newPredicate!.evaluateWithObject(bindingContext)

                            it("is updated to another defined predicate") {
                                expect(newPredicate).toNot(beNil())
                                expect(newPredicate).toNot(beIdenticalTo(previousPredicate))
                            }
                            it("evaluates positively for any object") {
                                expect(resultForNil).to(beFalse())
                                expect(resultForString).to(beFalse())
                                expect(resultForBindingContext).to(beFalse())
                            }
                        }
                    }
                    
                    binding.stopObservingChanges()
                }
            }

            context("when set up with constant expression true") {
                let bindingContext = PredicateTestBindingContext()

                let targetProperty = AKAProperty(
                    ofWeakKeyValueTarget: bindingContext,
                    keyPath: "predicate",
                    changeObserver: nil)

                let expressionText = "$true"
                let expression = try! AKABindingExpression(
                    string: expressionText,
                    bindingType: AKAPredicatePropertyBinding.self)

                let binding = try! AKAPredicatePropertyBinding(
                    target: targetProperty,
                    expression: expression,
                    context: bindingContext,
                    delegate: nil);

                context("when observing changes") {
                    binding.startObservingChanges()

                    bindingContext.predicateSource = true
                    let predicate = bindingContext.predicate

                    describe("predicate") {
                        let resultForNil = predicate!.evaluateWithObject(nil)
                        let resultForString = predicate!.evaluateWithObject("string")
                        let resultForBindingContext = predicate!.evaluateWithObject(bindingContext)

                        it("is defined") {
                            expect(predicate).toNot(beNil())
                        }
                        it("evaluates positively for any object") {
                            expect(resultForNil).to(beTrue())
                            expect(resultForString).to(beTrue())
                            expect(resultForBindingContext).to(beTrue())
                        }
                    }
                    
                    binding.stopObservingChanges()
                }
            }

            context("when set up with constant expression false") {
                let bindingContext = PredicateTestBindingContext()

                let targetProperty = AKAProperty(
                    ofWeakKeyValueTarget: bindingContext,
                    keyPath: "predicate",
                    changeObserver: nil)

                let expressionText = "$false"
                let expression = try! AKABindingExpression(
                    string: expressionText,
                    bindingType: AKAPredicatePropertyBinding.self)

                let binding = try! AKAPredicatePropertyBinding(
                    target: targetProperty,
                    expression: expression,
                    context: bindingContext,
                    delegate: nil);

                context("when observing changes") {
                    binding.startObservingChanges()

                    bindingContext.predicateSource = true
                    let predicate = bindingContext.predicate

                    describe("predicate") {
                        let resultForNil = predicate!.evaluateWithObject(nil)
                        let resultForString = predicate!.evaluateWithObject("string")
                        let resultForBindingContext = predicate!.evaluateWithObject(bindingContext)

                        it("is defined") {
                            expect(predicate).toNot(beNil())
                        }
                        it("evaluates positively for any object") {
                            expect(resultForNil).to(beFalse())
                            expect(resultForString).to(beFalse())
                            expect(resultForBindingContext).to(beFalse())
                        }
                    }
                    
                    binding.stopObservingChanges()
                }
            }
        }
    }
}
