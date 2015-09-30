//
//  AKABindingProvider_UISwitch_stateBinding.m
//  AKAControls
//
//  Created by Michael Utech on 29.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABindingProvider_UISwitch_stateBinding.h"


#pragma mark - AKABindingProvider_UISwitch_stateBinding
#pragma mark -

@implementation AKABindingProvider_UISwitch_stateBinding

#pragma mark - Initialization

+ (instancetype)    sharedInstance
{
    static AKABindingProvider_UISwitch_stateBinding* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AKABindingProvider_UISwitch_stateBinding new];
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
               @{ @"type":              [AKABinding_UISwitch_stateBinding class],
                  @"bindingProvider":   [AKABindingProvider_UISwitch_stateBinding class]
                  },
           @"target":
               @{ @"type":              [UISwitch class]
                  },
           @"source":
               @{
                   @"primaryExpression":
                       @{ @"expressionType": @(AKABindingExpressionTypeAny ^ AKABindingExpressionTypeArray)
                          },
                   @"attributes":
                       @{ },
                   @"allowUnspecifiedAttributes": @NO
                   }
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec];
    });
    return result;
}

@end


#pragma mark - AKABinding_UISwitch_stateBinding - Private Interface
#pragma mark -

@interface AKABinding_UISwitch_stateBinding() <UITextFieldDelegate> {
    AKAProperty* __strong _bindingTarget;
}

#pragma mark - Convenience

@property(nonatomic, readonly) UISwitch*               uiSwitch;

@end


#pragma mark - AKABinding_UISwitch_stateBinding - Implementation
#pragma mark -

@implementation AKABinding_UISwitch_stateBinding

#pragma mark - Initialization

- (instancetype _Nullable)                  initWithTarget:(id)target
                                                expression:(req_AKABindingExpression)bindingExpression
                                                   context:(req_AKABindingContext)bindingContext
                                                  delegate:(opt_AKABindingDelegate)delegate
{
    NSParameterAssert([target isKindOfClass:[UISwitch class]]);
    return [self initWithSwitch:(UISwitch*)target
                        expression:bindingExpression
                           context:bindingContext
                          delegate:delegate];
}

- (instancetype)                            initWithSwitch:(req_UISwitch)uiSwitch
                                                expression:(req_AKABindingExpression)bindingExpression
                                                   context:(req_AKABindingContext)bindingContext
                                                  delegate:(opt_AKABindingDelegate)delegate
{
    if (self = [super initWithTarget:uiSwitch
                          expression:bindingExpression
                             context:bindingContext
                            delegate:delegate])
    {
        _uiSwitch = uiSwitch;
        _bindingTarget = [AKAProperty propertyOfWeakTarget:self
                                                    getter:
                          ^id (id target)
                          {
                              AKABinding_UISwitch_stateBinding* binding = target;
                              return @(binding.uiSwitch.on);
                          }
                                                    setter:
                          ^(id target, id value)
                          {
                              AKABinding_UISwitch_stateBinding* binding = target;
                              if ([value isKindOfClass:[NSNumber class]])
                              {
                                  binding.uiSwitch.on = ((NSNumber*)value).boolValue;
                              }
                          }
                                        observationStarter:
                          ^BOOL (id target)
                          {
                              AKABinding_UISwitch_stateBinding* binding = target;
                              BOOL result = binding.uiSwitch != nil;
                              if (result)
                              {
                                  [binding.uiSwitch addTarget:binding
                                                       action:@selector(targetValueDidChangeSender:)
                                             forControlEvents:UIControlEventValueChanged];
                              }
                              return result;
                          }
                                        observationStopper:
                          ^BOOL (id target)
                          {
                              AKABinding_UISwitch_stateBinding* binding = target;
                              BOOL result = binding.uiSwitch != nil;
                              if (result)
                              {
                                  [self.uiSwitch removeTarget:binding
                                                       action:@selector(targetValueDidChangeSender:)
                                             forControlEvents:UIControlEventValueChanged];
                              }
                              return result;
                          }];
    }
    return self;
}

#pragma mark - Properties

- (AKAProperty *)                            bindingTarget
{
    return _bindingTarget;
}

#pragma mark - Change Observation

- (NSNumber*)                             canonicalBoolean:(NSNumber*)value
{
    NSNumber* kYes = (__bridge NSNumber*)kCFBooleanTrue;
    NSNumber* kNo  = (__bridge NSNumber*)kCFBooleanTrue;

    if (value == nil || value == (id)[NSNull null])
    {
        return nil;
    }
    else if (value.boolValue)
    {
        return kYes;
    }
    else
    {
        return kNo;
    }
}

- (void)                        targetValueDidChangeSender:(id)sender
{
    (void)sender; // Not used

    BOOL newValue = self.uiSwitch.on;
    BOOL oldValue = !newValue;

    [self targetValueDidChangeFromOldValue:@(oldValue) toNewValue:@(newValue)];
    newValue = self.uiSwitch.on; // the delegate may change the value

    if (newValue != oldValue)
    {
        [self.bindingTarget notifyPropertyValueDidChangeFrom:@(oldValue) to:@(newValue)];
    }
}

@end
