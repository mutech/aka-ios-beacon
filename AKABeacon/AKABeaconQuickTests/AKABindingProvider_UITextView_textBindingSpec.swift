import Quick
import Nimble
import AKABeacon

class AKABindingSpecificationSharedExamples: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        sharedExamples("conforms to its base binding specification") { (sharedContext: SharedExampleContext!) -> Void in

            describe("a binding specification") {
                let specification: AKABindingSpecification = sharedContext()["specification"] as! AKABindingSpecification;

                context("which is based on another specification") {
                    let baseSpecification: AKABindingSpecification = sharedContext()["baseSpecification"] as! AKABindingSpecification;

                    describe("its binding provider type") {
                        let bindingProviderType = specification.bindingProvider.dynamicType;
                        let baseBindingProviderType = baseSpecification.bindingProvider.dynamicType;

                        it("is a sub class of the base specification's binding provider type") {
                            expect(bindingProviderType).to(beASubclassOf(baseBindingProviderType));
                        }
                    }

                    describe("its ") {

                    }
                }
            }
        }
    }
}

class AKABindingProviderSpec: QuickSpec {
    override func spec() {
        describe("a binding provider") {
            beforeEach() {
            }

            it("provides a specification") {

            }
        }
    }
}

class AKABindingProvider_UITextView_textBindingSpec: QuickSpec {
    override func spec() {

        let provider = AKABindingProvider_UITextView_textBinding.sharedInstance();

        describe("specification") {
            let specification = provider.specification;
            let baseProviderType = Mirror(reflecting: provider).superclassMirror()?.subjectType as! AKABindingProvider.Type;
            let baseSpecification = baseProviderType.sharedInstance().specification;

            it("is defined") {
                expect(specification).toNot(beNil());
            }

            itBehavesLike("conforms to its base binding specification") {
                [   "specification":     specification,
                    "baseSpecification": baseSpecification ]
            }
        }
    }
}
