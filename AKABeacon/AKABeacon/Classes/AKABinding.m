//
//  AKABinding.m
//  AKABeacon
//
//  Created by Michael Utech on 17.09.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <objc/runtime.h>

@import AKACommons.AKANullability;
@import AKACommons.AKAErrors;
@import AKACommons.AKALog;
@import AKACommons.NSObject_AKAConcurrencyTools;

#import "AKABinding.h"
#import "AKAPropertyBinding.h"
#import "AKABindingErrors.h"


static inline BOOL selector_belongsToProtocol(SEL selector, Protocol * protocol)
{
    // Reference: https://gist.github.com/numist/3838169
    for (int optionbits = 0; optionbits < (1 << 2); optionbits++) {
        BOOL required = optionbits & 1;
        BOOL instance = !(optionbits & (1 << 1));

        struct objc_method_description hasMethod = protocol_getMethodDescription(protocol, selector, required, instance);
        if (hasMethod.name || hasMethod.types) {
            return YES;
        }
    }

    return NO;
}

#pragma mark - AKABinding Private Interface
#pragma mark -

@interface AKABinding () {
    BOOL _isUpdatingTargetValueForSourceValueChange;
#if 0
    NSMutableDictionary<NSString*, AKABinding*>* _attributeBindings;
    NSMutableDictionary<NSString*, AKABindingAttributeSpecification*>* _attributeBindingSpecifications;
#else
    NSMutableArray<AKABinding*>* _bindingPropertyBindings;
    NSMutableArray<AKABinding*>* _targetPropertyBindings;
#endif
}

@end

#pragma mark - AKABinding Implementation
#pragma mark -

@implementation AKABinding

#pragma mark - Initialization

- (instancetype)init
{
    if (self = [super init])
    {
        _isUpdatingTargetValueForSourceValueChange = NO;
    }

    return self;
}

- (instancetype _Nullable)                   initWithTarget:(id)target
                                                   property:(opt_SEL)property
                                                 expression:(req_AKABindingExpression)bindingExpression
                                                    context:(req_AKABindingContext)bindingContext
                                                   delegate:(opt_AKABindingDelegate)delegate
                                                      error:(out_NSError)error
{
    NSError* localError = nil;

    if (self = [self init])
    {
        AKABindingSpecification* specification = [self.class specification];

        // TODO: should check that self.class is sub class of bindingType:
        // TODO: check if relaxing attribute checks is still needed anyway
        // Perform validation; relax attribute checks if binding type is a sub class of
        // the binding type defined in the specification:
        BOOL relaxAttributeChecks = self.class != bindingExpression.specification.bindingType;
        if (specification.bindingSourceSpecification)
        {
            if (![bindingExpression validateOverrideAllowUnknownAttributes:relaxAttributeChecks
                                                                     error:&localError])
            {
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


        NSAssert(target == nil || [target isKindOfClass:[AKAProperty class]], @"Invalid target %@, expected instance of AKAProperty", target);
        _bindingTarget = target;

        _bindingProperty = property; // TODO: rename to bindingExpressionProperty or remove it
        _bindingContext = bindingContext;
        _delegate = delegate;

        __weak AKABinding* weakSelf = self;
        req_AKAPropertyChangeObserver changeObserver = ^(opt_id oldValue, opt_id newValue) {
            [weakSelf sourceValueDidChangeFromOldValue:oldValue
                                            toNewValue:newValue];
        };

        AKAProperty* bindingSource = [self bindingSourceForExpression:bindingExpression
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

        if (![self setupAttributeBindingsWithExpression:bindingExpression
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

- (opt_AKAProperty)    bindingSourceForExpression:(req_AKABindingExpression)bindingExpression
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

- (AKAProperty*)defaultBindingSourceForExpression:(req_AKABindingExpression)bindingExpression
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

#if 0
- (void)addAttributeBinding:(AKABinding*)binding
          withSpecification:(AKABindingAttributeSpecification*)specification
                     forKey:(NSString*)key
{
    NSAssert(self->_attributeBindings[key] == nil,
             @"Attribute binding %@ already defined in binding %@ as %@",
             key,
             self,
             self->_attributeBindings[key]);

    if (self->_attributeBindings == nil)
    {
        self->_attributeBindings = [NSMutableDictionary new];
        self->_attributeBindingSpecifications = [NSMutableDictionary new];
    }

    self->_attributeBindings[key] = binding;
    if (specification)
    {
        self->_attributeBindingSpecifications[key] = specification;
    }
}
#else
- (void)addBindingPropertyBinding:(AKABinding*)bpBinding
{
    // TODO: check conflicting bindingProperty/attributeName declarations (only one attribute allowed for bindingProperty)
    if (_bindingPropertyBindings == nil)
    {
        _bindingPropertyBindings = [NSMutableArray new];
    }
    [_bindingPropertyBindings addObject:bpBinding];
}

- (void)addTargetPropertyBinding:(AKABinding*)bpBinding
{
    // TODO: check conflicting bindingProperty/attributeName declarations (only one attribute allowed for bindingProperty)
    if (_targetPropertyBindings == nil)
    {
        _targetPropertyBindings = [NSMutableArray new];
    }
    [_targetPropertyBindings addObject:bpBinding];
}
#endif

- (BOOL)               setupAttributeBindingsWithExpression:(req_AKABindingExpression)bindingExpression
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
                         result = [self setupAttributeBindingManuallyWithName:attributeName
                                                                specification:attributeSpec
                                                          attributeExpression:attribute
                                                               bindingContext:bindingContext
                                                                        error:error];
                         break;
                     }

                 case AKABindingAttributeUseAssignValueToBindingProperty:
                     {
                         result = [self setupAttributeBindingByAssigningValueToBindingProperty:bindingPropertyName
                                                                             withSpecification:attributeSpec
                                                                           attributeExpression:attribute
                                                                                bindingContext:bindingContext error:error];
                         break;
                     }

                 case AKABindingAttributeUseAssignExpressionToBindingProperty:
                     {
                         result = [self setupAttributeBindingByAssigningExpressionToBindingProperty:bindingPropertyName
                                                                                  withSpecification:attributeSpec
                                                                                attributeExpression:attribute
                                                                                     bindingContext:bindingContext
                                                                                              error:error];
                         break;
                     }

                 case AKABindingAttributeUseAssignValueToTargetProperty:
                 {
                     result = [self setupAttributeBindingByAssigningValueToTargetProperty:bindingPropertyName
                                                                        withSpecification:attributeSpec
                                                                      attributeExpression:attribute
                                                                           bindingContext:bindingContext
                                                                                    error:error];
                     break;
                 }

                 case AKABindingAttributeUseBindToBindingProperty:
                     {
                         result = [self setupAttributeBindingByBindingToBindingProperty:bindingPropertyName
                                                                      withSpecification:attributeSpec
                                                                    attributeExpression:attribute
                                                                         bindingContext:bindingContext
                                                                                  error:error];

                         break;
                     }

                 case AKABindingAttributeUseBindToTargetProperty:
                 {
                     result = [self setupAttributeBindingWithSpecification:attributeSpec
                                                       attributeExpression:attribute
                                                            bindingContext:bindingContext
                                                 byBindingToTargetProperty:bindingPropertyName
                                                                     error:error];
                     break;
                 }

                 default:
                     break;
             }
         }
         else
         {
             result = [self setupUnspecifiedAttributeBindingWithName:attributeName
                                                 attributeExpression:attribute
                                                      bindingContext:bindingContext
                                                               error:error];
         }
         *stop = !result;
     }];

    return result;
}

- (BOOL)setupAttributeBindingManuallyWithName:(NSString*)attributeName
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

- (BOOL)setupAttributeBindingByAssigningValueToBindingProperty:(NSString *)bindingProperty
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

- (BOOL)setupAttributeBindingByAssigningExpressionToBindingProperty:(NSString *)bindingProperty
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


- (BOOL)setupAttributeBindingByAssigningValueToTargetProperty:(req_NSString)bindingProperty
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

        result = [self setupAttributeBindingWithSpecification:specification
                                          attributeExpression:attributeExpression
                                               bindingContext:bindingContext
                                    byBindingToTargetProperty:bindingProperty
                                                        error:error];
    }
    else
    {
        id value = [attributeExpression bindingSourceValueInContext:bindingContext];
        [target setValue:value forKey:bindingProperty];
    }

    return result;
}

- (BOOL)setupAttributeBindingByBindingToBindingProperty:(NSString *)bindingProperty
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
            [(AKABinding*)[bindingType alloc] initWithTarget:targetProperty
                                       property:NSSelectorFromString(bindingProperty)
                                     expression:attributeExpression
                                        context:bindingContext
                                       delegate:weakSelf
                                          error:error];
        result = propertyBinding != nil;
        if (result)
        {
#if 0
            [self addAttributeBinding:propertyBinding
                    withSpecification:specification
                               forKey:bindingProperty];
#else
            [self addBindingPropertyBinding:propertyBinding];
#endif
        }
    }
    return result;
}

- (BOOL)             setupAttributeBindingWithSpecification:(AKABindingAttributeSpecification*)specification
                                        attributeExpression:(req_AKABindingExpression)attributeExpression
                                             bindingContext:(req_AKABindingContext)bindingContext
                                  byBindingToTargetProperty:(NSString*)bindingProperty
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
            [(AKABinding*)[bindingType alloc] initWithTarget:targetProperty
                                       property:NSSelectorFromString(bindingProperty)
                                     expression:attributeExpression
                                        context:bindingContext
                                       delegate:weakSelf
                                          error:error];
        result = propertyBinding != nil;
        if (result)
        {
#if 0
            [self addAttributeBinding:propertyBinding
                    withSpecification:specification
                               forKey:bindingProperty];
#else
            [self addTargetPropertyBinding:propertyBinding];
#endif
        }
    }
    return result;
}

- (BOOL)           setupUnspecifiedAttributeBindingWithName:(NSString*)attributeName
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

#pragma mark - Delegation

- (id)forwardingTargetForSelector:(SEL)aSelector
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

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL result = [super respondsToSelector:aSelector];
    if (!result)
    {
        result = (selector_belongsToProtocol(aSelector, @protocol(AKABindingDelegate)) &&
                  [self.delegate respondsToSelector:aSelector]);
    }

    return result;
}

#pragma mark - Ad hoc binding application

+ (BOOL)                             applyBindingExpression:(req_AKABindingExpression)expression
                                                   toTarget:(id)target
                                                  inContext:(req_AKABindingContext)context
                                                      error:(out_NSError)error
{
    BOOL result = NO;

    // Create the binding
    Class bindingType = expression.specification.bindingType;
    AKABinding* binding = [(AKABinding*)[bindingType alloc] initWithTarget:target
                                                     property:nil
                                                   expression:expression
                                                      context:context
                                                     delegate:nil
                                                        error:error];
    result = binding != nil;

    if (result)
    {
        [binding startObservingChanges];
        [binding updateTargetValue];
        [binding stopObservingChanges];
        
        //result = [binding applyToTargetOnce:error];
    }

    return result;
}

- (BOOL)applyToTargetOnce:(out_NSError)error
{
    BOOL result = YES;

#if 0
    for (AKABinding* attributeBinding in self.attributeBindings.allValues)
    {
        result = [attributeBinding applyToTargetOnce:error];
        if (!result)
        {
            break;
        }
    }
    if (result)
    {
        [self updateTargetValue];
    }
#else
    for (AKABinding* bpBinding in self.bindingPropertyBindings)
    {
        result = [bpBinding applyToTargetOnce:error] && result;
    }
    [self updateTargetValue];
    for (AKABinding* tpBinding in self.targetPropertyBindings)
    {
        result = [tpBinding applyToTargetOnce:error] && result;
    }
#endif

    return result;
}

#pragma mark - Properties

- (BOOL)isUpdatingTargetValueForSourceValueChange
{
    return _isUpdatingTargetValueForSourceValueChange;
}

#if 0
- (NSDictionary<NSString *,AKABinding *> *)attributeBindings
{
    return _attributeBindings;
}

- (NSDictionary<NSString *,AKABindingAttributeSpecification *> *)attributeBindingSpecifications
{
    return _attributeBindingSpecifications;
}
#else
- (NSArray<AKABinding *> *)targetPropertyBindings
{
    return _targetPropertyBindings;
}

- (NSArray<AKABinding *> *)bindingPropertyBindings
{
    return _bindingPropertyBindings;
}
#endif

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

    if (result && self.bindingTarget != nil)
    {
        result = [self.bindingTarget validateValue:&validatedValue error:error];

        if (validatedValue != *targetValueStore)
        {
            *targetValueStore = validatedValue;
        }
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

         if ([self convertSourceValue:newSourceValue
                        toTargetValue:&targetValue
                                error:&error])
         {
             if ([self validateTargetValue:&targetValue
                                     error:&error])
             {
                 id oldTargetValue = self.bindingTarget.value;

                 if ([self shouldUpdateTargetValue:oldTargetValue
                                                to:targetValue
                                    forSourceValue:oldSourceValue
                                          changeTo:newSourceValue])
                 {
                     [self willUpdateTargetValue:oldTargetValue
                                              to:targetValue];

                     if (self.bindingTarget.value != targetValue)
                     {
                         self.bindingTarget.value = targetValue;
                     }

                     if (oldTargetValue != targetValue)
                     {
#if 0
                         for (NSString* key in self.attributeBindings.allKeys)
                         {
                             AKABindingAttributeSpecification* spec = self.attributeBindingSpecifications[key];
                             if (spec.attributeUse == AKABindingAttributeUseBindToTargetProperty)
                             {
                                 [self.attributeBindings[key] updateTargetValue];
                             }
                         }
#else
                         for (AKABinding* tpBinding in self.targetPropertyBindings)
                         {
                             [tpBinding updateTargetValue];
                         }
#endif
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

#if 0
    [self.attributeBindings enumerateKeysAndObjectsUsingBlock:
     ^(req_NSString propertyName,
       req_AKABinding propertyBinding,
       outreq_BOOL stop)
     {
         (void)propertyName;
         (void)stop;

         result = [propertyBinding startObservingChanges] && result;
     }];

    result = [self.bindingTarget startObservingChanges] && result;
    result = [self.bindingSource startObservingChanges] && result;

    [self updateTargetValue];
#else
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
#endif
    return result;
}

- (BOOL)                               stopObservingChanges
{
    __block BOOL result = YES;

#if 0
    result = [self.bindingTarget stopObservingChanges] && result;
    result = [self.bindingSource stopObservingChanges] && result;

    [self.attributeBindings enumerateKeysAndObjectsUsingBlock:
     ^(req_NSString propertyName,
       req_AKABinding propertyBinding,
       outreq_BOOL stop)
     {
         (void)propertyName;
         (void)stop;

         result = [propertyBinding stopObservingChanges] && result;
     }];
#else
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
#endif

    return result;
}

- (void)                   sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                                                 toNewValue:(opt_id)newSourceValue
{
    NSError* error;
    id sourceValue = newSourceValue;

    if ([self validateSourceValue:&sourceValue error:&error])
    {
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

@end


@implementation AKABinding (BindingSpecification)

+ (req_AKABindingSpecification)specification
{
    // TODO: create default specification
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
