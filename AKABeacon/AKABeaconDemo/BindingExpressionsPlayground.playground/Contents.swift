//: # Binding Expressions Playground

import UIKit
import XCPlayground
import AKABeacon

extension AKABindingExpressionType {
    func debugQuickLookObject() -> AnyObject? {
        return AKABindingExpressionSpecification.expressionTypeDescription(self);
    }
}

let baseProvider = AKAKeyboardControlViewBinding.self;
baseProvider.specification()
let baseBindingSourceSpec = baseProvider.specification().bindingSourceSpecification;

// Sadly, the above extension doesn't work:
baseBindingSourceSpec?.expressionType
baseBindingSourceSpec?.expressionType.debugQuickLookObject()

if let expressionType = baseBindingSourceSpec?.expressionType {
    AKABindingExpressionSpecification.expressionTypeDescription(baseBindingSourceSpec!.expressionType)
}

let attributes = baseBindingSourceSpec?.attributes


let textViewProvider = AKABinding_UITextView_textBinding.self;
let mirror = Mirror(reflecting: textViewProvider);
let superClassMirror = mirror.superclassMirror();
textViewProvider.specification().bindingType
textViewProvider.specification().bindingTargetSpecification?.typePattern?.description


textViewProvider.specification().bindingSourceSpecification?.attributes

