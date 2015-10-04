//
//  AKABindingProvider_UILabel_textBinding.m
//  AKAControls
//
//  Created by Michael Utech on 29.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.NSObject_AKAAssociatedValues;

#import "AKABindingProvider_UILabel_textBinding.h"


#pragma mark - AKABindingProvider_UILabel_textBinding - Implementation
#pragma mark -

@implementation AKABindingProvider_UILabel_textBinding

#pragma mark - Initialization

+ (instancetype)    sharedInstance
{
    static AKABindingProvider_UILabel_textBinding* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AKABindingProvider_UILabel_textBinding new];
    });
    return instance;
}

#pragma mark - Binding Expression Validation

- (AKABindingSpecification *)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"binding":
               @{ @"type":              [AKABinding_UILabel_textBinding class],
                  @"bindingProvider":   [AKABindingProvider_UILabel_textBinding class]
                  },
           @"target":
               @{ @"type":              [UILabel class]
                  },
           @"source":
               @{
                   @"primaryExpression":
                       @{ @"expressionType": @(AKABindingExpressionTypeAny ^ AKABindingExpressionTypeArray)
                          },
                   @"attributes":
                       @{ @"typeMap":
                              @{ @"required":        @NO,
                                 @"expressionType":  @(AKABindingExpressionTypeArray),
                                 @"attributes":      @{},
                                 @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                                 @"bindingProperty": @"typeMap"
                                 },
                          @"textForUndefinedValue":
                              @{ @"required":        @NO,
                                 @"expressionType":  @(AKABindingExpressionTypeString),
                                 @"attributes":      @{},
                                 @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                                 @"bindingProperty": @"textForUndefinedValue"
                                 },
                          },
                   @"allowUnspecifiedAttributes": @NO
                   }
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec];
    });
    return result;
}

@end


#pragma mark - AKABinding_UILabel_textBinding - Private Interface
#pragma mark -

@interface AKABinding_UILabel_textBinding() <UITextFieldDelegate> {
    AKAProperty* __strong _bindingTarget;
}

#pragma mark - Saved UILabel State

@property(nonatomic, nullable) NSString*                  originalText;
@property(nonatomic) UIView*                              originalInputAccessoryView;

#pragma mark - Convenience

@property(nonatomic, readonly) UILabel*               label;

@end

#pragma mark - AKABinding_UILabel_textBinding - Implementation
#pragma mark -

@implementation AKABinding_UILabel_textBinding

#pragma mark - Initialization

- (instancetype _Nullable)                  initWithTarget:(id)target
                                                expression:(req_AKABindingExpression)bindingExpression
                                                   context:(req_AKABindingContext)bindingContext
                                                  delegate:(opt_AKABindingDelegate)delegate
{
    NSParameterAssert([target isKindOfClass:[UILabel class]]);
    return [self     initWithLabel:(UILabel*)target
                        expression:bindingExpression
                           context:bindingContext
                          delegate:delegate];
}

- (instancetype)                             initWithLabel:(req_UILabel)label
                                                expression:(req_AKABindingExpression)bindingExpression
                                                   context:(req_AKABindingContext)bindingContext
                                                  delegate:(opt_AKABindingDelegate)delegate
{
    if (self = [super initWithTarget:label
                          expression:bindingExpression
                             context:bindingContext
                            delegate:delegate])
    {
        _label = label;

        _bindingTarget = [AKAProperty propertyOfWeakTarget:self
                                                    getter:
                          ^id (id target)
                          {
                              AKABinding_UILabel_textBinding* binding = target;
                              return binding.label.text;
                          }
                                                    setter:
                          ^(id target, id value)
                          {
                              AKABinding_UILabel_textBinding* binding = target;
                              NSString* text;
                              if ([value isKindOfClass:[NSString class]])
                              {
                                  text = value;
                              }
                              else if (value != nil && value != [NSNull null])
                              {
                                  text = [NSString stringWithFormat:@"%@", value];
                              }
                              else
                              {
                                  text = self.textForUndefinedValue;
                              }

                              binding.label.text = text;
                          }
                                        observationStarter:
                          ^BOOL (id target)
                          {
                              return YES;
                          }
                                        observationStopper:
                          ^BOOL (id target)
                          {
                              return YES;
                          }];
    }
    return self;
}

#pragma mark - Properties

- (AKAProperty *)                            bindingTarget
{
    return _bindingTarget;
}

@end
