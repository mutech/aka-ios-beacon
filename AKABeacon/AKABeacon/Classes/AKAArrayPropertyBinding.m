//
//  AKAArrayPropertyBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 06.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAArrayPropertyBinding.h"
#import "AKABinding_Protected.h"

@interface AKAArrayPropertyBinding()

@property(nonatomic, readonly) NSArray* targetArray;
@property(nonatomic, readonly) NSArray<AKABinding*>* targetArrayItemBindings;

@end

@implementation AKAArrayPropertyBinding

+ (AKABindingSpecification*)                         specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{

        NSDictionary* spec =
        @{ @"bindingType":                  [AKAArrayPropertyBinding class],
           @"targetType":                   [AKAProperty class],
           @"expressionType":               @(AKABindingExpressionTypeArray)
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

- (void)sourceArrayItemAtIndex:(NSUInteger)index
            valueDidChangeFrom:(id)oldValue
                            to:(id)newValue
{
    if ([self.delegate conformsToProtocol:@protocol(AKAArrayPropertyBindingDelegate)])
    {
        id<AKAArrayPropertyBindingDelegate> delegate = (id)self.delegate;
        if ([delegate respondsToSelector:@selector(binding:sourceArrayItemAtIndex:value:didChangeTo:)])
        {
            [delegate binding:self
       sourceArrayItemAtIndex:index
                        value:oldValue
                  didChangeTo:newValue];
        }
    }
}

- (opt_AKAProperty)bindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                      context:(req_AKABindingContext)bindingContext
                               changeObserver:(opt_AKAPropertyChangeObserver)changeObserver
                                        error:(out_NSError)error
{
    // Binding source will not be updated (for target changes), so the change observer will not
    // be used:
    (void)changeObserver;
    
    BOOL result = YES;
    AKAProperty* bindingSource = nil;

    id sourceValue = [bindingExpression bindingSourceValueInContext:bindingContext];

    if ([sourceValue isKindOfClass:[NSArray class]])
    {
        BOOL isConstant = YES;
        NSArray* sourceArray = sourceValue;
        NSMutableArray* targetArray = [NSMutableArray new];
        NSMutableArray* targetArrayItemBindings = nil;

        for (id sourceItem in sourceArray)
        {
            if ([sourceItem isKindOfClass:[AKABindingExpression class]])
            {
                AKABindingExpression* sourceExpression = sourceItem;
                if (sourceExpression.isConstant)
                {
                    // Constant expressions will be evaluated immediately and no binding is created.
                    id targetValue = [sourceExpression bindingSourceValueInContext:bindingContext];
                    if (targetValue == nil)
                    {
                        [targetArray addObject:[NSNull null]];
                    }
                    else
                    {
                        [targetArray addObject:targetValue];
                    }
                }
                else
                {
                    // All other binding expressions require the creation of a binding for the array
                    // item, the target array is thus not constant.
                    isConstant = NO;

                    // The target value will be initialized as undefined value, as soon as the binding
                    // will start observing changes, the value will be updated by the binding.
                    [targetArray addObject:[NSNull null]];
                    NSUInteger index = targetArray.count - 1;

                    __weak typeof(self) weakSelf = self;
                    AKAProperty* arrayItemTargetProperty =
                    [AKAIndexedProperty propertyOfWeakIndexedTarget:targetArray
                                                       index:(NSInteger)index
                                              changeObserver:
                         ^(id  _Nullable oldValue, id  _Nullable newValue)
                         {
                             [weakSelf sourceArrayItemAtIndex:index
                                           valueDidChangeFrom:oldValue
                                                           to:newValue];
                         }];
                    Class bindingType = sourceExpression.specification.bindingType;
                    if (bindingType == nil)
                    {
                        bindingType = [AKAPropertyBinding class];
                    }


                    AKABinding* binding = [bindingType bindingToTargetProperty:arrayItemTargetProperty
                                                                withExpression:sourceExpression
                                                                       context:bindingContext
                                                                      delegate:weakSelf.delegateForSubBindings
                                                                         error:error];
                    if (binding)
                    {
                        if (targetArrayItemBindings == nil)
                        {
                            targetArrayItemBindings = [NSMutableArray new];
                        }
                        [targetArrayItemBindings addObject:binding];
                    }
                    else
                    {
                        result = NO;
                        break;
                    }
                }
            }
        }

        if (result)
        {
            if (isConstant)
            {
                _targetArray = [NSArray arrayWithArray:targetArray];
            }
            else
            {
                _targetArray = targetArray;
            }
            _targetArrayItemBindings = targetArrayItemBindings;

            bindingSource = [AKAProperty propertyOfWeakTarget:self
                                                       getter:
                             ^id _Nullable(req_id target)
                             {
                                 AKAArrayPropertyBinding* binding = target;
                                 return binding.targetArray;
                             }
                                                       setter:
                             ^(req_id target, opt_id value)
                             {
                                 (void)target;
                                 (void)value;
                                 NSAssert(NO, @"Updating binding source is not supported by array property bindings (yet)");
                             }
                                           observationStarter:
                             ^BOOL(req_id target)
                             {
                                 BOOL sresult = YES;
                                 AKAArrayPropertyBinding* binding = target;

                                 for (AKABinding* itemBinding in binding.targetArrayItemBindings)
                                 {
                                     [itemBinding startObservingChanges];
                                 }

                                 return sresult;
                             }
                                           observationStopper:
                             ^BOOL(req_id target)
                             {
                                 BOOL sresult = YES;
                                 AKAArrayPropertyBinding* binding = target;

                                 for (AKABinding* itemBinding in binding.targetArrayItemBindings)
                                 {
                                     sresult = [itemBinding stopObservingChanges] && sresult;
                                 }
                                 
                                 return sresult;
                             }];
        }
    }
    else
    {
        // TODO: error handling
        result = NO;
    }

    return bindingSource;
}

@end
