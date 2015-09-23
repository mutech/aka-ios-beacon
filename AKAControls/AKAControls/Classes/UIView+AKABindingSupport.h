//
//  UIView+AKABindingSupport.h
//  AKAControls
//
//  Created by Michael Utech on 20.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit.UIView;
@import AKACommons.AKANullability;

#import "AKABindingExpression.h"

@interface UIView(AKABindingSupport)

@property(nonatomic, readonly, nullable) NSArray<NSString*>* aka_definedBindingPropertyNames;

- (opt_AKABindingExpression)aka_bindingExpressionForProperty:(req_SEL)selector;

- (opt_AKABindingExpression)aka_bindingExpressionForPropertyNamed:(req_NSString)key;

- (void)aka_setBindingExpression:(opt_AKABindingExpression)bindingExpression
                     forProperty:(req_SEL)selector;

- (void)aka_setBindingExpression:(opt_AKABindingExpression)bindingExpression
                forPropertyNamed:(req_NSString)key;

@end
