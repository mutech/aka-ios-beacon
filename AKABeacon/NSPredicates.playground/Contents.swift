//: Playground - noun: a place where people can play

import UIKit

var vars = [ "myClass": UIView.self ]

var predicateClass = NSPredicate(format: "function(self, 'class') == $myClass");
predicateClass.evaluateWithObject(UIView(), substitutionVariables: vars)
predicateClass.evaluateWithObject(UILabel(), substitutionVariables: vars)

var predicateKindOf = NSPredicate(format: "SELF isKindOfClass:$myClass AND NOT class = $myClass")
predicateKindOf.evaluateWithObject(UIView(), substitutionVariables: vars)
predicateKindOf.evaluateWithObject(UILabel(), substitutionVariables: vars)

var predicateSubclassOf = NSPredicate(format: "class isSubclassOfClass: $myClass AND NOT class = $myClass")
predicateSubclassOf.evaluateWithObject(UIView(), substitutionVariables: vars)
predicateSubclassOf.evaluateWithObject(UILabel(), substitutionVariables: vars)

//var predicateX = NSPredicate(format: "FUNCTION(SELF, 'actionForLayer:forKey:', $myClass, $myClass) == YES");


var x = NSObject()