//
//  AKABinding.m
//  AKABeacon
//
//  Created by Michael Utech on 17.09.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <objc/runtime.h>

@import AKACommons;

#import "AKABinding_Protected.h"
#import "AKAPropertyBinding.h"
#import "AKABindingErrors.h"
#import "AKABindingDelegateDispatcher.h"
#import "NSObject+AKAConcurrencyTools.h"

#pragma mark - AKABinding Private Interface
#pragma mark -

@interface AKABinding () {
    // Fields shared with private category implementations:

    BOOL                            _isUpdatingTargetValueForSourceValueChange;
    NSMutableArray<AKABinding*>*    _bindingPropertyBindings;
    NSMutableArray<AKABinding*>*    _arrayItemBindings;
    NSMutableArray<AKABinding*>*    _targetPropertyBindings;
    id                              _syntheticTargetValue;
    AKABindingDelegateDispatcher*   _delegateDispatcher;
}

@end


#pragma mark - AKABinding Implementation
#pragma mark -

@implementation AKABinding

#pragma mark - Initialization

- (instancetype)                                       init
{
    if (self = [super init])
    {
        _isUpdatingTargetValueForSourceValueChange = NO;
    }

    return self;
}

- (opt_instancetype)                         initWithTarget:(req_AKAProperty)target
                                                 expression:(req_AKABindingExpression)bindingExpression
                                                    context:(req_AKABindingContext)bindingContext
                                                   delegate:(opt_AKABindingDelegate)delegate
                                                      error:(out_NSError)error
{
    NSError* localError = nil;

    if (self = [self init])
    {
        AKABindingSpecification *specification = [self.class specification];

        Class specifiedBindingType = bindingExpression.specification.bindingType;
        NSAssert(specifiedBindingType == nil || [[self class] isSubclassOfClass:specifiedBindingType],
            @"Binding %@ of type %@ is not an instance of specified binding type %@",
            self, NSStringFromClass(self.class), NSStringFromClass(specifiedBindingType));

        // TODO: check if relaxing attribute checks is still needed anyway
        // Perform validation; relax attribute checks if binding type is a sub class of
        // the binding type defined in the specification:
        BOOL relaxAttributeChecks = self.class != specifiedBindingType;
        if (specification.bindingSourceSpecification) {
            if (![bindingExpression validateOverrideAllowUnknownAttributes:relaxAttributeChecks
                                                                     error:&localError]) {
                self = nil;
            }
            /* TODO: check if we (still?) need alternative validation for extended binding specifications:
             if (![bindingExpression validateWithSpecification:specification.bindingSourceSpecification
             overrideAllowUnknownAttributes:relaxAttributeChecks
             error:&localError])
             {
             self = nil;
             }*/
        }


        NSAssert(target == nil || [target isKindOfClass:[AKAProperty class]],
            @"Invalid target %@, expected instance of AKAProperty", target);
        _bindingTarget = target;
        _bindingContext = bindingContext;
        _delegateDispatcher = [[AKABindingDelegateDispatcher alloc] initWithDelegate:delegate
                                                                  delegateOverwrites:self];

        __weak AKABinding *weakSelf = self;
        req_AKAPropertyChangeObserver changeObserver = ^(opt_id oldValue, opt_id newValue) {
            [weakSelf sourceValueDidChangeFromOldValue:oldValue
                                            toNewValue:newValue];
        };
        AKAProperty *bindingSource = [self bindingSourceForExpression:bindingExpression
                                                              context:bindingContext
                                                       changeObserver:changeObserver
                                                                error:&localError];
        if (bindingSource)
        {
            _bindingSource = (req_AKAProperty)bindingSource;
        }
        else
        {
            self = nil;
        }

        if (![self initializeAttributesWithExpression:bindingExpression
                                       bindingContext:bindingContext
                                                error:&localError])
        {
            self = nil;
        }
    }

    if (self == nil)
    {
        if (error)
        {
            *error = localError;
        }
        else
        {
            // If the caller does not provide an error storage, we assume that it's not taking
            // care of error handling and consider the missing binding error a fatal condition.
            @throw [NSException exceptionWithName:@"Failed to create binding"
                                           reason:localError.localizedDescription
                                         userInfo:nil];
        }
    }

    return self;
}

#pragma mark - Properties

- (BOOL)          isUpdatingTargetValueForSourceValueChange
{
    return _isUpdatingTargetValueForSourceValueChange;
}

- (id<AKABindingDelegate>)delegate
{
    return _delegateDispatcher.delegate;
}

#pragma mark - Conversion

- (BOOL)                                 convertSourceValue:(opt_id)sourceValue
                                              toTargetValue:(out_id)targetValueStore
                                                      error:(out_NSError)error
{
    (void)error; // passthrough, never fails

    BOOL result = YES;

    if (targetValueStore)
    {
        *targetValueStore = sourceValue;
    }

    return result;
}

#pragma mark - Validation

- (BOOL)                                validateSourceValue:(inout_id)sourceValueStore
                                                      error:(out_NSError)error
{
    NSParameterAssert(sourceValueStore != nil);

    BOOL result = YES;

    id validatedValue = sourceValueStore == nil ? nil : *sourceValueStore;

    if (result && self.bindingSource != nil)
    {
        result = [self.bindingSource validateValue:&validatedValue error:error];

        if (validatedValue != *sourceValueStore)
        {
            *sourceValueStore = validatedValue;
        }
    }

    return result;
}

- (BOOL)                                validateTargetValue:(inout_id)targetValueStore
                                                      error:(out_NSError)error
{
    NSParameterAssert(targetValueStore != nil);

    BOOL result = YES;

    id validatedValue = targetValueStore == nil ? nil : *targetValueStore;

    if (self.bindingTarget != nil)
    {
        result = [self.bindingTarget validateValue:&validatedValue error:error];

        if (validatedValue != *targetValueStore)
        {
            *targetValueStore = validatedValue;
        }
    }

    return result;
}

#pragma mark - Delegation

- (id)                          forwardingTargetForSelector:(SEL)aSelector
{
    id<AKABindingDelegate> delegate = self.delegate;
    if ([super respondsToSelector:aSelector])
    {
        return self;
    }
    else if ([delegate respondsToSelector:aSelector])
    {
        return delegate;
    }
    else
    {
        return [super forwardingTargetForSelector:aSelector];
    }
}


static inline BOOL               selector_belongsToProtocol(SEL selector, Protocol * protocol)
{
    // Reference: https://gist.github.com/numist/3838169
    for (int optionBits = 0; optionBits < (1 << 2); optionBits++) {
        BOOL required = (BOOL) (optionBits & 1);
        BOOL instance = !(optionBits & (1 << 1));

        struct objc_method_description hasMethod = protocol_getMethodDescription(protocol, selector, required, instance);
        if (hasMethod.name || hasMethod.types) {
            return YES;
        }
    }

    return NO;
}

- (BOOL)                                 respondsToSelector:(SEL)aSelector
{
    BOOL result = [super respondsToSelector:aSelector];
    if (!result)
    {
        result = (selector_belongsToProtocol(aSelector, @protocol(AKABindingDelegate)) &&
                  [self.delegate respondsToSelector:aSelector]);
    }

    return result;
}

#pragma mark - Delegate Support

- (void)             targetUpdateFailedToConvertSourceValue:(opt_id)sourceValue
                                     toTargetValueWithError:(opt_NSError)error
{
    id<AKABindingDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(binding:targetUpdateFailedToConvertSourceValue:toTargetValueWithError:)])
    {
        [delegate                       binding:self
         targetUpdateFailedToConvertSourceValue:sourceValue
                         toTargetValueWithError:error];
    }
}

- (void)            targetUpdateFailedToValidateTargetValue:(opt_id)targetValue
                                   convertedFromSourceValue:(opt_id)sourceValue
                                                  withError:(opt_NSError)error
{
    id<AKABindingDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(binding:targetUpdateFailedToValidateTargetValue:convertedFromSourceValue:withError:)])
    {
        [delegate                        binding:self
         targetUpdateFailedToValidateTargetValue:targetValue
                        convertedFromSourceValue:sourceValue
                                       withError:error];
    }
}

- (void)                   sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                                             toInvalidValue:(opt_id)newSourceValue
                                                  withError:(opt_NSError)error
{
    id<AKABindingDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(binding:sourceValueDidChangeFromOldValue:toInvalidValue:withError:)])
    {
        [delegate
                                  binding:self
         sourceValueDidChangeFromOldValue:oldSourceValue
                           toInvalidValue:newSourceValue
                                withError:error];
    }
}

// This is not a delegate method, it serves as a shortcut to prevent updates in subclasses before
// the source value is converted to the target value.
- (BOOL)              shouldUpdateTargetValueForSourceValue:(opt_id)oldSourceValue
                                                   changeTo:(opt_id)newSourceValue
                                                validatedTo:(opt_id)sourceValue
{
    // Implemented by subclasses to prevent update cycles:
    (void)oldSourceValue;
    (void)newSourceValue;
    (void)sourceValue;

    return YES;
}

- (BOOL)                            shouldUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue
                                             forSourceValue:(opt_id)oldSourceValue
                                                   changeTo:(opt_id)newSourceValue
{
    BOOL result = YES;

    id<AKABindingDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(shouldBinding:updateTargetValue:to:forSourceValue:changeTo:)])
    {
        result = [delegate
                      shouldBinding:self
                  updateTargetValue:oldTargetValue
                                 to:newTargetValue
                     forSourceValue:oldSourceValue
                           changeTo:newSourceValue];
    }

    return result;
}

- (void)                              willUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue
{
    _isUpdatingTargetValueForSourceValueChange = YES;

    id<AKABindingDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(binding:willUpdateTargetValue:to:)])
    {
        [delegate binding:self willUpdateTargetValue:oldTargetValue to:newTargetValue];
    }
}

- (void)                               didUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue
{
    id<AKABindingDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(binding:didUpdateTargetValue:to:)])
    {
        [delegate binding:self didUpdateTargetValue:oldTargetValue to:newTargetValue];
    }
    _isUpdatingTargetValueForSourceValueChange = NO;
}


- (void)                             targetArrayItemAtIndex:(NSUInteger)index
                                         valueDidChangeFrom:(opt_id)oldValue
                                                         to:(opt_id)newValue
{
    id<AKABindingDelegate> delegate = (id)self.delegate;
    if ([delegate respondsToSelector:@selector(binding:targetArrayItemAtIndex:value:didChangeTo:)])
    {
        [delegate           binding:self
             targetArrayItemAtIndex:index
                              value:oldValue
                        didChangeTo:newValue];
    }
}

- (void)                             sourceArrayItemAtIndex:(NSUInteger)index
                                         valueDidChangeFrom:(opt_id)oldValue
                                                         to:(opt_id)newValue
{
    id<AKABindingDelegate> delegate = (id)self.delegate;
    if ([delegate respondsToSelector:@selector(binding:sourceArrayItemAtIndex:value:didChangeTo:)])
    {
        [delegate           binding:self
             sourceArrayItemAtIndex:index
                              value:oldValue
                        didChangeTo:newValue];
    }
}

- (void)                                            binding:(AKABinding*)binding
                           sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                                                         to:(opt_id)newSourceValue
{
    id<AKABindingDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(binding:sourceValueDidChangeFromOldValue:to:)])
    {
        [delegate binding:binding sourceValueDidChangeFromOldValue:oldSourceValue to:newSourceValue];
    }

    if (self.arrayItemBindings.count > 0)
    {
        NSUInteger arrayItemIndex = [self.arrayItemBindings indexOfObject:binding];
        if (arrayItemIndex != NSNotFound)
        {
            [self sourceArrayItemAtIndex:arrayItemIndex
                      valueDidChangeFrom:oldSourceValue
                                      to:newSourceValue];
        }
    }
}

#pragma mark - Target Value Updates

- (void)                                  updateTargetValue
{
    id sourceValue = self.bindingSource.value;

    [self updateTargetValueForSourceValue:sourceValue changeTo:sourceValue];
}

- (void)                    updateTargetValueForSourceValue:(opt_id)oldSourceValue
                                                   changeTo:(opt_id)newSourceValue
{
    [self aka_performBlockInMainThreadOrQueue:
     ^{
         id targetValue = nil;
         NSError* error;

         id oldTargetValue = self.bindingTarget.value;
         
         if ([self convertSourceValue:newSourceValue
                        toTargetValue:&targetValue
                                error:&error])
         {
             if ([self validateTargetValue:&targetValue
                                     error:&error])
             {
                 if ([self shouldUpdateTargetValue:oldTargetValue
                                                to:targetValue
                                    forSourceValue:oldSourceValue
                                          changeTo:newSourceValue])
                 {
                     [self willUpdateTargetValue:oldTargetValue
                                              to:targetValue];

                     // Some bindings wrap the source value in an object that may not change when the
                     // source value changes or perform other transformations that would not either.
                     if (oldTargetValue != targetValue || oldSourceValue != newSourceValue)
                     {
                         self.bindingTarget.value = targetValue;
                     }

                     if (oldTargetValue != targetValue || oldSourceValue != newSourceValue)
                     {
                         for (AKABinding* tpBinding in self.targetPropertyBindings)
                         {
                             [tpBinding updateTargetValue];
                         }
                     }


                     [self didUpdateTargetValue:oldTargetValue
                                             to:targetValue];
                 }
             }
             else
             {
                 [self targetUpdateFailedToValidateTargetValue:targetValue
                                      convertedFromSourceValue:newSourceValue
                                                     withError:error];
             }
         }
         else
         {
             [self targetUpdateFailedToConvertSourceValue:newSourceValue
                                   toTargetValueWithError:error];
         }
     }
                            waitForCompletion:NO];
}

#pragma mark - Change Tracking

- (BOOL)                              startObservingChanges
{
    __block BOOL result = YES;

    for (AKABinding* bpBinding in self.bindingPropertyBindings)
    {
        result = [bpBinding startObservingChanges] && result;
    }
    result = [self.bindingTarget startObservingChanges] && result;
    result = [self.bindingSource startObservingChanges] && result;
    [self updateTargetValue];
    for (AKABinding* tpBinding in self.targetPropertyBindings)
    {
        result = [tpBinding startObservingChanges];
    }

    return result;
}

- (BOOL)                               stopObservingChanges
{
    __block BOOL result = YES;

    for (AKABinding* tpBinding in self.targetPropertyBindings)
    {
        result = [tpBinding stopObservingChanges];
    }
    result = [self.bindingTarget stopObservingChanges] && result;
    result = [self.bindingSource stopObservingChanges] && result;
    for (AKABinding* bpBinding in self.bindingPropertyBindings)
    {
        result = [bpBinding stopObservingChanges] && result;
    }

    return result;
}

- (void)                   sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                                                 toNewValue:(opt_id)newSourceValue
{
    NSError* error;
    id sourceValue = newSourceValue;

    if ([self validateSourceValue:&sourceValue error:&error])
    {
        id<AKABindingDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(binding:sourceValueDidChangeFromOldValue:to:)])
        {
            [delegate                       binding:self
                   sourceValueDidChangeFromOldValue:oldSourceValue
                                                 to:newSourceValue];
        }
        if ([self shouldUpdateTargetValueForSourceValue:oldSourceValue
                                               changeTo:newSourceValue
                                            validatedTo:sourceValue])
        {
            [self updateTargetValueForSourceValue:oldSourceValue
                                         changeTo:sourceValue];
        }
    }
    else
    {
        [self sourceValueDidChangeFromOldValue:oldSourceValue
                                toInvalidValue:newSourceValue
                                     withError:error];
    }
}

- (void)                                    bindingProperty:(req_NSString)bindingPropertyName
                                                      value:(opt_id)oldValue
                                        didChangeToNewValue:(opt_id)newValue
{
    AKALogDebug(@"Binding %@ property %@ value %@ changed to %@", self, bindingPropertyName, oldValue, newValue);
}

#pragma mark - Diagnostics

- (NSString*)                                   description
{
    return [NSString stringWithFormat:@"<%@: %p; source=%@, target=%@>",
            self.class, self,
            self.bindingSource, self.bindingTarget];
}

@end


@implementation AKABinding(Protected)

#pragma mark - Properties

- (id)syntheticTargetValue
{
    return _syntheticTargetValue;
}

- (void)setSyntheticTargetValue:(id)syntheticTargetValue
{
    _syntheticTargetValue = syntheticTargetValue;
}

- (NSArray<AKABinding *> *)arrayItemBindings
{
    return _arrayItemBindings;
}

- (NSArray<AKABinding *> *)          targetPropertyBindings
{
    return _targetPropertyBindings;
}

- (NSArray<AKABinding *> *)         bindingPropertyBindings
{
    return _bindingPropertyBindings;
}

#pragma mark - Sub Bindings

- (void)                                addArrayItemBinding:(AKABinding*)binding
{
    if (_arrayItemBindings == nil)
    {
        _arrayItemBindings = [NSMutableArray new];
    }
    [_arrayItemBindings addObject:binding];

    if (binding != (id)[NSNull null])
    {
        [self addTargetPropertyBinding:binding];
    }
}

- (void)                          addBindingPropertyBinding:(AKABinding*)bpBinding
{
    // TODO: check conflicting bindingProperty/attributeName declarations (only one attribute allowed for bindingProperty)
    if (_bindingPropertyBindings == nil)
    {
        _bindingPropertyBindings = [NSMutableArray new];
    }
    [_bindingPropertyBindings addObject:bpBinding];
}

- (void)                           addTargetPropertyBinding:(AKABinding*)bpBinding
{
    // TODO: check conflicting bindingProperty/attributeName declarations (only one attribute allowed for bindingProperty)
    if (_targetPropertyBindings == nil)
    {
        _targetPropertyBindings = [NSMutableArray new];
    }
    [_targetPropertyBindings addObject:bpBinding];
}

#pragma mark - Binding Source Initialization

- (opt_AKAProperty)              bindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                                    context:(req_AKABindingContext)bindingContext
                                             changeObserver:(opt_AKAPropertyChangeObserver)changeObserver
                                                      error:(out_NSError)error
{
    opt_AKAProperty bindingSource = nil;

    if (bindingExpression.class == [AKABindingExpression class] ||
        bindingExpression.expressionType == AKABindingExpressionTypeNone)
    {
        // The binding expression does not have a primary value. Consequently, the concrete binding
        // type may provide a default binding source:
        bindingSource = [self defaultBindingSourceForExpression:bindingExpression
                                                        context:bindingContext
                                                 changeObserver:changeObserver
                                                          error:error];
    }
    else if (bindingExpression.expressionType == AKABindingExpressionTypeArray)
    {
        bindingSource = [self bindingSourceForArrayExpression:bindingExpression
                                                      context:bindingContext
                                               changeObserver:changeObserver
                                                        error:error];
    }
    else
    {
        bindingSource = [bindingExpression bindingSourcePropertyInContext:bindingContext
                                                            changeObserer:changeObserver];
        if (!bindingSource && error)
        {
            *error = [AKABindingErrors bindingErrorUndefinedBindingSourceForExpression:bindingExpression
                                                                               context:bindingContext];
        }
    }

    return bindingSource;
}

- (AKAProperty*)          defaultBindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                                    context:(req_AKABindingContext)bindingContext
                                             changeObserver:(opt_AKAPropertyChangeObserver)changeObserver
                                                      error:(out_NSError)error
{
    (void)bindingExpression;
    (void)bindingContext;
    (void)changeObserver;
    (void)error;

    // Note: Bindings that do not need a primary expression should return a property with an undefined target and keypath. This is not done by default to ensure that undefined source properties trigger an error unless this is intentional.
    AKAErrorAbstractMethodImplementationMissing();
}


- (AKAProperty*)            bindingSourceForArrayExpression:(req_AKABindingExpression)bindingExpression
                                                    context:(req_AKABindingContext)bindingContext
                                             changeObserver:(opt_AKAPropertyChangeObserver)changeObserver
                                                      error:(out_NSError)error
{
    // Binding source will not be updated (for target changes), so the change observer will not
    // be used; however, changes in array items will trigger source array item events:
    (void)changeObserver;

    BOOL result = YES;
    AKAProperty* bindingSource = nil;

    id sourceValue = [bindingExpression bindingSourceValueInContext:bindingContext];

    if ([sourceValue isKindOfClass:[NSArray class]])
    {
        BOOL isConstant = YES;
        NSArray* sourceArray = sourceValue;
        NSMutableArray* targetArray = [NSMutableArray new];

        for (id sourceItem in sourceArray)
        {
            // If an array item does not have a binding, null is stored to preserve index integrity.
            id arrayItemBinding = [NSNull null];

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
                    [AKAProperty propertyOfWeakIndexedTarget:targetArray
                                                       index:(NSInteger)index
                                              changeObserver:
                     ^(id  _Nullable oldValue, id  _Nullable newValue)
                     {
                         [weakSelf targetArrayItemAtIndex:index
                                       valueDidChangeFrom:oldValue == [NSNull null] ? nil : oldValue
                                                       to:newValue == [NSNull null] ? nil : newValue];
                     }];
                    Class bindingType = sourceExpression.specification.bindingType;
                    if (bindingType == nil)
                    {
                        bindingType = [AKAPropertyBinding class];
                    }

                    AKABinding* binding = (AKABinding*)[bindingType alloc];
                    binding = [binding initWithTarget:arrayItemTargetProperty expression:sourceExpression context:bindingContext delegate:weakSelf error:error];
                    if (binding)
                    {
                        arrayItemBinding = binding;
                    }
                    else
                    {
                        result = NO;
                        break;
                    }
                }
            }
            if (result)
            {
                [self addArrayItemBinding:arrayItemBinding];
            }
        }

        if (result)
        {
            if (isConstant)
            {
                // Create a non-mutable copy
                _syntheticTargetValue = [NSArray arrayWithArray:targetArray];
            }
            else
            {
                // Preserve the mutable array, because bindings may update array items
                _syntheticTargetValue = targetArray;
            }

            bindingSource = [AKAProperty propertyOfWeakTarget:self
                                                       getter:
                             ^id _Nullable(req_id target)
                             {
                                 AKABinding* binding = target;
                                 return binding->_syntheticTargetValue;
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
                                 AKABinding* binding = target;

                                 for (AKABinding* itemBinding in binding.arrayItemBindings)
                                 {
                                     sresult = [itemBinding startObservingChanges] && sresult;
                                 }

                                 return sresult;
                             }
                                           observationStopper:
                             ^BOOL(req_id target)
                             {
                                 BOOL sresult = YES;
                                 AKABinding* binding = target;

                                 for (AKABinding* itemBinding in binding.arrayItemBindings)
                                 {
                                     sresult = [itemBinding stopObservingChanges] && sresult;
                                 }

                                 return sresult;
                             }];
        }
    }
    else
    {
        NSError* e = [AKABindingErrors invalidBinding:self
                                          sourceValue:sourceValue
                                   expectedSubclassOf:[NSArray class]];
        if (error)
        {
            *error = e;
        }
        else
        {
            @throw [NSException exceptionWithName:@"InvalidOperation"
                                           reason:e.localizedDescription
                                         userInfo:@{ @"error": e }];
        }
        result = NO;
    }

    return bindingSource;
}

#pragma mark - Attribute Initialization

- (BOOL)                 initializeAttributesWithExpression:(req_AKABindingExpression)bindingExpression
                                             bindingContext:(req_AKABindingContext)bindingContext
                                                      error:(out_NSError)error
{
    __block BOOL result = YES;

    (void)error;

    AKABindingSpecification* specification = [self.class specification];

    [((opt_AKABindingExpressionAttributes)(bindingExpression.attributes)) enumerateKeysAndObjectsUsingBlock:
     ^(req_NSString attributeName,
       req_AKABindingExpression attribute,
       outreq_BOOL stop)
     {
         (void)stop;

         AKABindingAttributeSpecification* attributeSpec =
         specification.bindingSourceSpecification.attributes[attributeName];

         if (attributeSpec)
         {
             NSString* bindingPropertyName = attributeSpec.bindingPropertyName;

             if (bindingPropertyName == nil)
             {
                 bindingPropertyName = attributeName;
             }

             switch (attributeSpec.attributeUse)
             {
                 case AKABindingAttributeUseManually:
                 {
                     result = [self initializeManualAttributeWithName:attributeName
                                                        specification:attributeSpec
                                                  attributeExpression:attribute
                                                       bindingContext:bindingContext
                                                                error:error];
                     break;
                 }

                 case AKABindingAttributeUseAssignValueToBindingProperty:
                 {
                     result = [self initializeBindingPropertyValueAssignmentAttribute:bindingPropertyName
                                                                    withSpecification:attributeSpec
                                                                  attributeExpression:attribute
                                                                       bindingContext:bindingContext error:error];
                     break;
                 }

                 case AKABindingAttributeUseAssignExpressionToBindingProperty:
                 {
                     result = [self initializeBindingPropertyExpressionAssignmentAttribute:bindingPropertyName
                                                                         withSpecification:attributeSpec
                                                                       attributeExpression:attribute
                                                                            bindingContext:bindingContext
                                                                                     error:error];
                     break;
                 }

                 case AKABindingAttributeUseAssignValueToTargetProperty:
                 {
                     result = [self initializeTargetPropertyValueAssignmentAttribute:bindingPropertyName
                                                                   withSpecification:attributeSpec
                                                                 attributeExpression:attribute
                                                                      bindingContext:bindingContext
                                                                               error:error];
                     break;
                 }

                 case AKABindingAttributeUseBindToBindingProperty:
                 {
                     result = [self initializeBindingPropertyBindingAttribute:bindingPropertyName
                                                            withSpecification:attributeSpec
                                                          attributeExpression:attribute
                                                               bindingContext:bindingContext
                                                                        error:error];

                     break;
                 }

                 case AKABindingAttributeUseBindToTargetProperty:
                 {
                     result = [self initializeTargetPropertyBindingAttribute:bindingPropertyName withSpecification:attributeSpec attributeExpression:attribute bindingContext:bindingContext error:error];
                     break;
                 }

                 default:
                     break;
             }
         }
         else
         {
             result = [self initializeUnspecifiedAttribute:attributeName
                                       attributeExpression:attribute
                                            bindingContext:bindingContext
                                                     error:error];
         }
         *stop = !result;
     }];

    return result;
}

- (BOOL)                  initializeManualAttributeWithName:(NSString *)attributeName
                                              specification:(req_AKABindingAttributeSpecification)specification
                                        attributeExpression:(req_AKABindingExpression)attributeExpression
                                             bindingContext:(req_AKABindingContext)bindingContext
                                                      error:(out_NSError)error
{
    (void)attributeName;
    (void)specification;
    (void)attributeExpression;
    (void)bindingContext;
    (void)error;

    return YES;
}

- (BOOL)  initializeBindingPropertyValueAssignmentAttribute:(NSString *)bindingProperty
                                          withSpecification:(AKABindingAttributeSpecification *)specification
                                        attributeExpression:(req_AKABindingExpression)attributeExpression
                                             bindingContext:(req_AKABindingContext)bindingContext
                                                      error:(out_NSError)error
{
    (void)specification;
    (void)error;

    id value = [attributeExpression bindingSourceValueInContext:bindingContext];
    [self setValue:value forKey:bindingProperty];
    return YES;
}

- (BOOL)initializeBindingPropertyExpressionAssignmentAttribute:(NSString *)bindingProperty
                                             withSpecification:(AKABindingAttributeSpecification *)specification
                                           attributeExpression:(req_AKABindingExpression)attributeExpression
                                                bindingContext:(req_AKABindingContext)bindingContext
                                                         error:(out_NSError)error
{
    (void)specification;
    (void)bindingContext;
    (void)error;

    [self setValue:attributeExpression forKey:bindingProperty];
    return YES;
}


- (BOOL)   initializeTargetPropertyValueAssignmentAttribute:(req_NSString)bindingProperty
                                          withSpecification:(req_AKABindingAttributeSpecification)specification
                                        attributeExpression:(req_AKABindingExpression)attributeExpression
                                             bindingContext:(req_AKABindingContext)bindingContext
                                                      error:(out_NSError)error;
{
    BOOL result = YES;

    (void)specification;
    (void)error;

    id target = self.bindingTarget.value;
    if (target == nil)
    {
        // If the target does not yet have a defined value, a binding will be created to ensure that the value is not lost.
        AKALogWarn(@"Cannot assign binding %@ attribute value %@ to target property %@ because the target is undefined. To support defered target assignment, a property binding will be created instead", self, attributeExpression, bindingProperty);

        result = [self initializeTargetPropertyBindingAttribute:bindingProperty withSpecification:specification attributeExpression:attributeExpression bindingContext:bindingContext error:error];
    }
    else
    {
        id value = [attributeExpression bindingSourceValueInContext:bindingContext];
        [target setValue:value forKey:bindingProperty];
    }

    return result;
}

- (BOOL)          initializeBindingPropertyBindingAttribute:(NSString *)bindingProperty
                                          withSpecification:(AKABindingAttributeSpecification *)specification
                                        attributeExpression:(req_AKABindingExpression)attributeExpression
                                             bindingContext:(req_AKABindingContext)bindingContext
                                                      error:(out_NSError)error
{
    BOOL result = YES;
    Class bindingType = specification.bindingType;

    if (bindingType == nil)
    {
        bindingType = [AKAPropertyBinding class];
    }

    if (bindingType != nil)
    {
        __weak typeof(self) weakSelf = self;
        AKAProperty* targetProperty =
        [AKAProperty propertyOfWeakKeyValueTarget:self
                                          keyPath:bindingProperty
                                   changeObserver:^(opt_id oldValue, opt_id newValue) {
                                       [weakSelf bindingProperty:bindingProperty
                                                           value:oldValue
                                             didChangeToNewValue:newValue];
                                   }];
        AKABinding* propertyBinding =
        [(AKABinding *) [bindingType alloc] initWithTarget:targetProperty expression:attributeExpression context:bindingContext delegate:weakSelf error:error];
        result = propertyBinding != nil;
        if (result)
        {
            [self addBindingPropertyBinding:propertyBinding];
        }
    }
    return result;
}

- (BOOL)           initializeTargetPropertyBindingAttribute:(NSString *)bindingProperty
                                          withSpecification:(AKABindingAttributeSpecification *)specification
                                        attributeExpression:(req_AKABindingExpression)attributeExpression
                                             bindingContext:(req_AKABindingContext)bindingContext
                                                      error:(out_NSError)error
{
    BOOL result = YES;
    Class bindingType = specification.bindingType;

    if (bindingType == nil)
    {
        bindingType = [AKAPropertyBinding class];
    }

    if (bindingType != nil)
    {
        __weak typeof(self) weakSelf = self;
        AKAProperty* targetProperty =
        [self.bindingTarget propertyAtKeyPath:bindingProperty
                           withChangeObserver:
         ^(opt_id oldValue, opt_id newValue)
         {
             [weakSelf bindingProperty:bindingProperty
                                 value:oldValue
                   didChangeToNewValue:newValue];
         }];
        AKABinding* propertyBinding =
        [(AKABinding *) [bindingType alloc] initWithTarget:targetProperty expression:attributeExpression context:bindingContext delegate:weakSelf error:error];
        result = propertyBinding != nil;
        if (result)
        {
            [self addTargetPropertyBinding:propertyBinding];
        }
    }
    return result;
}

- (BOOL)                     initializeUnspecifiedAttribute:(NSString *)attributeName
                                        attributeExpression:(req_AKABindingExpression)attributeExpression
                                             bindingContext:(req_AKABindingContext)bindingContext
                                                      error:(out_NSError)error
{
    (void)attributeName;
    (void)attributeExpression;
    (void)bindingContext;
    (void)error;

    return YES;
}

@end


@implementation AKABinding (BindingSpecification)

+ (req_AKABindingSpecification)specification
{
    return nil;
}

+ (Class)bindingTypeForBindingExpressionInPrimaryExpressionArray
{
    AKABindingSpecification* specification = [self specification];
    return specification.bindingSourceSpecification.arrayItemBindingType;
}

+ (Class)bindingTypeForAttributeNamed:(NSString *)attributeName
{
    return [self specificationForAttributeNamed:attributeName].bindingType;
}

+ (opt_AKABindingAttributeSpecification)specificationForAttributeNamed:(NSString*)attributeName
{
    AKABindingSpecification* specification = [self specification];

    return specification.bindingSourceSpecification.attributes[attributeName];
}

@end
