//
//  AKABinding.m
//  AKABeacon
//
//  Created by Michael Utech on 17.09.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.AKANullability;
@import AKACommons.AKAErrors;
@import AKACommons.AKALog;
@import AKACommons.NSObject_AKAConcurrencyTools;

#import "AKABinding.h"
#import "AKABindingDelegate.h"
#import "AKABindingExpression.h"
#import "AKABindingErrors.h"

#pragma mark - AKABinding Private Interface
#pragma mark -

@interface AKABinding () {
    BOOL _isUpdatingTargetValueForSourceValueChange;
}

@property(nonatomic, readonly, nullable) NSMutableDictionary<NSString*, AKABinding*>* attributeBindings;

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

    AKABindingSpecification* specification = [self.class specification];

    BOOL relaxAttributeChecks = self.class != bindingExpression.bindingType;
    if (![bindingExpression validateWithSpecification:specification.bindingSourceSpecification
                       overrideAllowUnknownAttributes:relaxAttributeChecks
                                                error:&localError])
    {
        self = nil;
    }

    if (self = [self init])
    {
        _bindingTarget = target;
        _bindingProperty = property; // TODO: rename to bindingExpressionProperty or remove it
        _bindingContext = bindingContext;
        _delegate = delegate;

        __weak AKABinding* weakSelf = self;
        req_AKAPropertyChangeObserver changeObserver = ^(opt_id oldValue, opt_id newValue) {
            [weakSelf sourceValueDidChangeFromOldValue:oldValue
                                            toNewValue:newValue];
        };

        if (![self setupBindingSourceWithExpression:bindingExpression
                                            context:bindingContext
                                     changeObserver:changeObserver
                                              error:&localError])
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

- (BOOL)                   setupBindingSourceWithExpression:(req_AKABindingExpression)bindingExpression
                                                    context:(req_AKABindingContext)bindingContext
                                             changeObserver:(opt_AKAPropertyChangeObserver)changeObserver
                                                      error:(out_NSError)error
{
    BOOL result = YES;

    opt_AKAProperty bindingSource = [bindingExpression bindingSourcePropertyInContext:bindingContext
                                                                        changeObserer:changeObserver];

    if (bindingSource)
    {
        _bindingSource = (req_AKAProperty)bindingSource;
    }
    else if (bindingExpression.class == [AKABindingExpression class])
    {
        // If bindingExpression is AKABindingExpression (not a subclass), then delivering no bindingSource
        // is expected and not an error.
        _bindingSource = [AKAProperty propertyOfWeakKeyValueTarget:nil
                                                           keyPath:nil
                                                    changeObserver:changeObserver];
    }
    else
    {
        result = NO;
        *error = [AKABindingErrors bindingErrorUndefinedBindingSourceForExpression:bindingExpression
                                                                           context:bindingContext];
    }

    return result;
}

- (BOOL)               setupAttributeBindingsWithExpression:(req_AKABindingExpression)bindingExpression
                                             bindingContext:(req_AKABindingContext)bindingContext
                                                      error:(out_NSError)error
{
    BOOL result = YES;

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
                 case AKABindingAttributeUseAssignValueToBindingProperty:
                     {
                         id value = [attribute bindingSourceValueInContext:bindingContext];
                         [self setValue:value forKey:bindingPropertyName];

                         break;
                     }

                 case AKABindingAttributeUseAssignExpressionToBindingProperty:
                     {
                         [self setValue:attribute forKey:bindingPropertyName];

                         break;
                     }

                 case AKABindingAttributeUseBindToBindingProperty:
                     {
                         // We could assign constant attributes instead of binding them, but their
                         // nested attributes might need binding, so this is getting to complex for
                         // now.

                         if (self->_attributeBindings == nil)
                         {
                             self->_attributeBindings = [NSMutableDictionary new];
                         }

                         Class bindingType = attributeSpec.bindingType;

                         if (bindingType != nil)
                         {
                             __weak typeof(self) weakSelf = self;
                             AKAProperty* targetProperty =
                                 [AKAProperty propertyOfWeakKeyValueTarget:self
                                                                   keyPath:bindingPropertyName
                                                            changeObserver:^(opt_id oldValue, opt_id newValue) {
                                                                [weakSelf bindingProperty:bindingPropertyName
                                                                                    value:oldValue
                                                                      didChangeToNewValue:newValue];
                                                            }];
                             AKABinding* propertyBinding =
                                 [[bindingType alloc] initWithTarget:targetProperty
                                                            property:NSSelectorFromString(bindingPropertyName)
                                                          expression:attribute
                                                             context:bindingContext
                                                            delegate:nil
                                                               error:error];
                             self->_attributeBindings[bindingPropertyName] = propertyBinding;
                         }

                         break;
                     }

                 default:
                     break;
             }
         }
     }];

    return result;
}

#pragma mark - Properties

- (BOOL)isUpdatingTargetValueForSourceValueChange
{
    return _isUpdatingTargetValueForSourceValueChange;
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

                     self.bindingTarget.value = targetValue;

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

    [self.attributeBindings enumerateKeysAndObjectsUsingBlock:
     ^(req_NSString propertyName,
       req_AKABinding propertyBinding,
       outreq_BOOL stop)
     {
         (void)propertyName;
         (void)stop;

         result = [propertyBinding startObservingChanges] && result;
     }];

    result = [self.bindingSource startObservingChanges] && result;
    result = [self.bindingTarget startObservingChanges] && result;

    [self updateTargetValue];

    return result;
}

- (BOOL)                               stopObservingChanges
{
    __block BOOL result = YES;

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
    // TODO: remove debug output
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
    AKABindingSpecification* specification = [self specification];
    return specification.bindingSourceSpecification.attributes[attributeName].bindingType;
}

@end
