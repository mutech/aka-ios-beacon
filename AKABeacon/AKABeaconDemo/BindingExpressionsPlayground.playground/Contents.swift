//: # Binding Expressions Playground

import UIKit
import XCPlayground
import AKABeacon

extension AKABindingExpressionType {
    func debugQuickLookObject() -> AnyObject? {
        return AKABindingExpressionSpecification.expressionTypeDescription(self);
    }
}

let baseProvider = AKAKeyboardControlViewBindingProvider.sharedInstance();
let baseBindingSourceSpec = baseProvider.specification.bindingSourceSpecification

// Sadly, the above extension doesn't work:
baseBindingSourceSpec?.expressionType
baseBindingSourceSpec?.expressionType.debugQuickLookObject()

if let expressionType = baseBindingSourceSpec?.expressionType {
    AKABindingExpressionSpecification.expressionTypeDescription(baseBindingSourceSpec!.expressionType)
}

let attributes = baseBindingSourceSpec?.attributes


let textViewProvider = AKABindingProvider_UITextView_textBinding.sharedInstance()
let mirror = Mirror(reflecting: textViewProvider);
let superClassMirror = mirror.superclassMirror();
textViewProvider.specification.bindingType
textViewProvider.specification.bindingProvider
textViewProvider.specification.bindingTargetSpecification?.typePattern?.description


textViewProvider.specification.bindingSourceSpecification?.attributes

