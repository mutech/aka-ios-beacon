//
//  AKAControl.m
//  AKAControls
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAControl_Internal.h"
#import "AKACompositeControl.h"

#import "AKAControlsErrors_Internal.h"

// New bindings infrastructure
#import "UIView+AKABindingSupport.h"
#import "AKABinding.h"
#import "AKABindingProvider.h"

@import AKACommons;
//@import AKACommons.NSObject_AKAConcurrencyTools;

#import <objc/runtime.h>

@interface AKAControl(Convenience)

@end

@interface AKAControl() <
    AKABindingDelegate,
    AKAControlConverterDelegate,
    AKAControlValidationDelegate
> {
    AKAProperty* _dataContextProperty;
    AKAProperty* _modelValueProperty;
    AKAObsoleteViewBinding * _viewBinding;
    NSMutableSet* _tags;
}

@property(nonatomic)NSMutableDictionary* themeNameByType;

@end

@implementation AKAControl

@synthesize owner = _owner;
@synthesize isActive = _isActive;
@synthesize converter = _converter;

#pragma mark - Initialization

+ (instancetype)               controlWithDataContext:(id)dataContext
                                        configuration:(id<AKAControlConfigurationProtocol>)configuration
{
    NSParameterAssert(dataContext != nil);

    return [[self alloc] initWithDataContext:dataContext configuration:configuration];
}

+ (instancetype)                     controlWithOwner:(AKACompositeControl *)owner
                                        configuration:(id<AKAControlConfigurationProtocol>)configuration
{
    NSParameterAssert(owner != nil);

    return [[self alloc] initWithOwner:owner configuration:configuration];
}

- (instancetype)init
{
    if (self = [super init])
    {
        _bindings = [NSMutableArray new];
        _tags = [NSMutableSet new];
    }
    return self;
}

- (instancetype)                  initWithDataContext:(id)dataContext
                                        configuration:(id<AKAControlConfigurationProtocol>)configuration
{
    if (self = [self init])
    {
        // Setup data context
        self.dataContextProperty =
        [AKAProperty propertyOfWeakKeyValueTarget:dataContext
                                          keyPath:nil
                                   changeObserver:nil];

        if (![self setupWithConfiguration:configuration])
        {
            self = nil;
        }
    }
    return self;
}

- (instancetype)                        initWithOwner:(AKACompositeControl*)owner
                                        configuration:(id<AKAControlConfigurationProtocol>)configuration
{
    if (self = [self init])
    {
        [self setOwner:owner];

        if (![self setupWithConfiguration:configuration])
        {
            self = nil;
        }
    }
    return self;
}

#pragma mark - New Bindings Support

- (NSUInteger)                     addBindingsForView:(req_UIView)view
{
    NSUInteger result = 0;
    NSArray* bindingPropertyNames = [view aka_definedBindingPropertyNames];
    for (NSString* propertyName in bindingPropertyNames)
    {
        if ([self addBindingForView:view
            bindingPropertyWithName:propertyName])
        {
            ++result;
        }
    }
    return result;
}

- (BOOL)                            addBindingForView:(req_UIView)view
                              bindingPropertyWithName:(req_NSString)propertyName;
{
    NSAssert([[NSThread currentThread] isMainThread], @"Binding manipulation outside of main thread");

    __block BOOL result = NO;
    AKABindingExpression* bindingExpression = [view aka_bindingExpressionForPropertyNamed:propertyName];
    AKABindingProvider* provider = bindingExpression.bindingProvider;
    AKABinding* binding = [provider bindingWithTarget:view
                                           expression:bindingExpression
                                              context:self
                                             delegate:self];
    if (binding)
    {
        // Paranoia: Binding should only be manipulated from main thread, on the other hand
        // if this is called from a different thread, there is a possibility for a dead lock
        // since we are and probably have to wait for completion. So better make sure this
        // is called from main than to rely on this:
        [self aka_performBlockInMainThreadOrQueue:^{
            result = YES;
            [self.bindings addObject:binding];
            if (self.isObservingChanges)
            {
                [binding startObservingChanges];
            }
        } waitForCompletion:YES];
    }
    return result;
}

- (BOOL)                                removeBinding:(AKABinding*)binding
{
    NSAssert([[NSThread currentThread] isMainThread], @"Binding manipulation outside of main thread");

    __block BOOL result = NO;
    // Paranoia: Binding should only be manipulated from main thread, on the other hand
    // if this is called from a different thread, there is a possibility for a dead lock
    // since we are and probably have to wait for completion. So better make sure this
    // is called from main than to rely on this:
    [self aka_performBlockInMainThreadOrQueue:^{
        NSUInteger index = [self.bindings indexOfObjectIdenticalTo:binding];
        BOOL localResult = index != NSNotFound;
        if (localResult)
        {
            [binding stopObservingChanges];
            [self.bindings removeObjectAtIndex:index];
        }
    } waitForCompletion:YES];
    return result;
}

#pragma mark AKABindings

#pragma mark AKABindingContextProtocol

- (AKACompositeControl*)                  rootControl
{
    AKACompositeControl* result = self.owner;
    while (result.owner != nil)
    {
        result = result.owner;
    }
    return result;
}

- (opt_AKAProperty)     dataContextPropertyForKeyPath:(opt_NSString)keyPath
                                   withChangeObserver:(opt_AKAPropertyChangeObserver)valueDidChange
{
    return [self.dataContextProperty propertyAtKeyPath:keyPath
                                    withChangeObserver:valueDidChange];
}

- (id)                     dataContextValueForKeyPath:(NSString *)keyPath
{
    return [self dataContextPropertyForKeyPath:keyPath withChangeObserver:nil].value;
}

- (opt_AKAProperty) rootDataContextPropertyForKeyPath:(opt_NSString)keyPath
                                   withChangeObserver:(opt_AKAPropertyChangeObserver)valueDidChange
{
    return [[self rootControl] dataContextPropertyForKeyPath:keyPath withChangeObserver:valueDidChange];
}

- (opt_id)             rootDataContextValueForKeyPath:(req_NSString)keyPath
{
    return [[self rootControl] dataContextValueForKeyPath:keyPath];
}

- (opt_AKAProperty)         controlPropertyForKeyPath:(req_NSString)keyPath
                                   withChangeObserver:(opt_AKAPropertyChangeObserver)valueDidChange
{
    return [AKAProperty propertyOfWeakKeyValueTarget:self
                                             keyPath:keyPath
                                      changeObserver:valueDidChange];
}

- (opt_id)                     controlValueForKeyPath:(req_NSString)keyPath
{
    return [self valueForKeyPath:keyPath];
}

#pragma mark - Configuration

- (AKAProperty*)basePropertyForModelValue
{
    AKAProperty* result = _dataContextProperty;
    if (!result)
    {
        result = self.owner.modelValueProperty;
    }
    if (!result)
    {
        result = self.owner.basePropertyForModelValue;
    }
    return result;
}

- (BOOL)setupWithConfiguration:(id<AKAControlConfigurationProtocol>)configuration
{
    BOOL result = YES;

    // Setup model value property
    if (configuration.valueKeyPath.length > 0)
    {
        __weak typeof(self) weakSelf = self;
        AKAProperty* base = self.basePropertyForModelValue;
        self.modelValueProperty = [base propertyAtKeyPath:configuration.valueKeyPath
                                       withChangeObserver:^(id oldValue, id newValue)
         {
             [weakSelf modelValueDidChangeFrom:oldValue
                                            to:newValue];
         }];
    }
    else
    {
        self.modelValueProperty = nil;
    }

    if (configuration.controlTags.length > 0)
    {
        NSScanner* scanner = [NSScanner scannerWithString:configuration.controlTags];
        [scanner setCharactersToBeSkipped:nil];
        while (!scanner.isAtEnd)
        {
            [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];

            NSString* tag;
            if ([scanner scanCharactersFromSet:[NSCharacterSet letterCharacterSet]
                                intoString:&tag])
            {
                if (scanner.isAtEnd || [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet]
                                                           intoString:nil])
                {
                    [_tags addObject:tag];
                    tag = nil;
                }
                else
                {
                    // TODO: error handling
                    NSString* reason = [NSString stringWithFormat:@"Invalid character '%@' at position %lu in '%@'",
                                        [configuration.controlTags substringWithRange:NSMakeRange(scanner.scanLocation, 1)],
                                        (unsigned long)scanner.scanLocation,
                                        configuration.controlTags];
                    @throw [NSException exceptionWithName:@"Invalid control tags specification"
                                                   reason:reason
                                                 userInfo:nil];
                }
            }
        }
    }
    return result;
}

#pragma mark - Control Hierarchy

- (void)setOwner:(AKACompositeControl *)owner
{
    AKACompositeControl* currentOwner = _owner;
    if (currentOwner != owner)
    {
        if (currentOwner != nil && owner != nil)
        {
            [AKAControlsErrors invalidAttemptToSetOwnerOfControl:self
                                                        ownedBy:currentOwner
                                                     toNewOwner:owner];
        }
        _owner = owner;
    }
}

#pragma mark - Binding

- (AKAObsoleteViewBinding *)viewBinding
{
    return _viewBinding;
}

- (void)setViewBinding:(AKAObsoleteViewBinding *)viewBinding
{
    if (viewBinding != _viewBinding)
    {
        if (_viewBinding != nil && viewBinding != nil)
        {
            // TODO: error handling
            AKALogError(@"Attempt to bind a control %@ which is already bound to view %@ to %@. Rebinding requires the controls viewBinding to be reset to nil first.", self, _viewBinding.view, viewBinding.view);
        }
        else
        {
            _viewBinding = viewBinding;
            if (viewBinding != nil)
            {
                [self initializeBindingProperties];
            }
            else
            {
                [self resetBindingProperties];
            }
        }
    }
}

- (void)initializeBindingProperties
{
    _converterProperty = [self.viewBinding createConverterPropertyWithDataContextProperty:self.dataContextProperty];
    if (_converterProperty == nil)
    {
        _converter = self.viewBinding.defaultConverter;
    }
    _validatorProperty = [self.viewBinding createValidatorPropertyWithDataContextProperty:self.dataContextProperty];
}

- (void)resetBindingProperties
{
    _validatorProperty = nil;
    _converterProperty = nil;
    _converter = nil;
}

#pragma mark - Value Access

- (UIView *)view
{
    return self.viewBinding.view;
}

- (AKAProperty*)viewValueProperty
{
    return self.viewBinding.viewValueProperty;
}

- (id)viewValue
{
    return self.viewValueProperty.value;
}

- (void)setViewValue:(id)viewValue
{
    self.viewValueProperty.value = viewValue;
}

- (AKAProperty *)dataContextProperty
{
    return _dataContextProperty != nil ? _dataContextProperty : self.owner.dataContextProperty;
}

- (void)setDataContextProperty:(AKAProperty *)dataContextProperty
{
    _dataContextProperty = dataContextProperty;
}

- (AKAProperty *)modelValueProperty
{
    return _modelValueProperty;
}

- (void)setModelValueProperty:(AKAProperty *)modelValueProperty
{
    _modelValueProperty = modelValueProperty;
}

- (id)modelValue
{
    return self.modelValueProperty.value;
}

- (void)setModelValue:(id)modelValue
{
    self.modelValueProperty.value = modelValue;
}

- (id<AKAControlValidatorProtocol>)validator
{
    return self.validatorProperty.value;
}

- (id<AKAControlConverterProtocol>)converter
{
    id<AKAControlConverterProtocol> result = _converter;
    if (result == nil)
    {
        result = self.converterProperty.value;
    }
    return result;
}

#pragma mark - Conversion

- (BOOL)convertViewValue:(id)viewValue
            toModelValue:(out __autoreleasing id *)modelValueStorage
                   error:(out NSError *__autoreleasing *)error
{
    BOOL result = NO;
    BOOL needsConversion = YES;
    while (needsConversion)
    {
        needsConversion = NO;
        id effectiveViewValue = viewValue;
        id<AKAControlConverterProtocol> converter = self.converter;
        if (converter != nil)
        {
            result = [converter convertViewValue:effectiveViewValue
                                    toModelValue:modelValueStorage
                                           error:error];
        }
        else
        {
            *modelValueStorage = effectiveViewValue;
            result = YES;
        }

        if (!result && [self.delegate respondsToSelector:@selector(control:viewValue:conversionFailedWithError:)])
        {
            result = [          self control:self
                                   viewValue:&effectiveViewValue
                   conversionFailedWithError:error];
            needsConversion = result;
        }
    }
    return result;
}

- (BOOL)                control:(req_AKAControl)control
                      viewValue:(inout_id)viewValueStorage
      conversionFailedWithError:(NSError *__autoreleasing *)error
{
    BOOL result = NO;
    if ([self.delegate respondsToSelector:@selector(control:viewValue:conversionFailedWithError:)])
    {
        result = [self.delegate control:control
                              viewValue:viewValueStorage
              conversionFailedWithError:error];
        if (!result && self.owner)
        {
            result = [self.owner control:control
                               viewValue:viewValueStorage
               conversionFailedWithError:error];
        }
    }
    return result;
}

#pragma mark - Validation

- (BOOL)isValid
{
    return self.validationError == nil;
}

- (void)setIsValid:(BOOL)isValid error:(NSError*)error
{
    NSError* previousError = _validationError;
    if (!isValid && error == nil)
    {
        // TODO: create error code and message in AKAontrolsErrors
        _validationError = [NSError errorWithDomain:[AKAControlsErrors akaControlsErrorDomain]
                                               code:123
                                           userInfo:@{}];
    }
    else
    {
        _validationError = error;
    }
    if (_validationError != previousError)
    {
        [self validationState:previousError changedTo:_validationError];
    }
}

- (BOOL)            control:(AKAControl *)control
            validationState:(NSError *)oldError
                  changedTo:(NSError *)newError
         updateValidationMessageDisplay:(void(^)())block
{
    // The specified block (if defined) was generated by a member control which is
    // capable of displaying its validation state. Independently, this control might
    // also display the members validation state. In this case we augment the original
    // block.
    void(^localUpdateValidationMessageDisplayBlock)() = nil;
    if (control != self && self.viewBinding != nil)
    {
        __weak typeof(self)weakSelf = self;
        __weak AKAControl* weakControl = control;
        localUpdateValidationMessageDisplayBlock = ^ {
            if (block != nil)
            {
                block();
            }
            [weakSelf.viewBinding validationContext:weakControl
                                            forView:weakControl.view
                         changedValidationStateFrom:oldError
                                                 to:newError];
        };
    }
    void (^blockForDelegates)() = localUpdateValidationMessageDisplayBlock ? localUpdateValidationMessageDisplayBlock : block;

    BOOL result = NO;
    if ([self.delegate respondsToSelector:@selector(control:validationState:changedTo:updateValidationMessageDisplay:)])
    {
        result = [self.delegate     control:control
                            validationState:oldError
                                  changedTo:newError
             updateValidationMessageDisplay:blockForDelegates];
    }
    if ([self.owner             control:control
                        validationState:oldError
                              changedTo:newError
         updateValidationMessageDisplay:(result ? nil : blockForDelegates)])
    {
        result = YES;
    }

    if (!result && localUpdateValidationMessageDisplayBlock)
    {
        localUpdateValidationMessageDisplayBlock();
        result = YES;
    }
    return result;
}

- (void)validationState:(NSError *)oldError
              changedTo:(NSError *)newError
{
    void(^updateValidationMessageDisplayBlock)() = nil;
    if (self.viewBinding != nil)
    {
        __weak typeof(self)weakSelf = self;
        updateValidationMessageDisplayBlock = ^ {
            [weakSelf.viewBinding validationContext:weakSelf
                                            forView:weakSelf.view
                         changedValidationStateFrom:oldError
                                                 to:newError];
        };
    }
    BOOL blockCalled = [self control:self
                     validationState:oldError
                           changedTo:newError
      updateValidationMessageDisplay:updateValidationMessageDisplayBlock];
    if (!blockCalled && updateValidationMessageDisplayBlock != NULL)
    {
        updateValidationMessageDisplayBlock();
    }
}

- (UIView *)viewForValidationContext:(id)validationContext
                     validationError:(NSError *)validationError
{
    UIView* result = nil;
    if ([validationContext isKindOfClass:[AKAControl class]])
    {
        AKAControl* control = validationContext;
        result = control.view;
    }
    return result;
}

#pragma mark Model Value Validation

- (BOOL)validateModelValue:(inout id*)valueStorage
                     error:(out NSError *__autoreleasing *)error
{
    return [self validateModelValue:valueStorage error:error callDelegate:YES];
}

- (BOOL)validateModelValue:(inout id*)valueStorage
                     error:(out NSError *__autoreleasing *)error
              callDelegate:(BOOL)callDelegate
{
    NSParameterAssert(valueStorage != nil);

    BOOL result = YES;

    BOOL needsValidation = YES;
    while (needsValidation)
    {
        needsValidation = NO;
        id validatedValue = *valueStorage;

        id<AKAControlValidatorProtocol> validator = self.validator;
        if (validator != nil)
        {
            result = [validator validateModelValue:validatedValue error:error];
        }

        // Perform additional validation provided by KVC after custom validation,
        // assuming that custom validation will provide better error messages.
        if (result && self.modelValueProperty != nil)
        {
            result = [self.modelValueProperty validateValue:&validatedValue error:error];
            if (validatedValue != *valueStorage)
            {
                if (callDelegate)
                {
                    // Assuming that callDelegate indicates we are validating the real model
                    // value.
                    AKALogWarn(@"Model value KVC validation for property %@ replaced model value %@ with %@, this might indicate that the model data is invalid.",
                               self.modelValueProperty, *valueStorage, validatedValue);
                }
                *valueStorage = validatedValue;
            }
        }

        if (!result && callDelegate)
        {
            id previousValue = validatedValue;
            result = ![self         control:self
                                 modelValue:&validatedValue
                  validationFailedWithError:error];
            if (previousValue == validatedValue)
            {
                result = NO;
            }
            else
            {
                needsValidation = YES;
            }
        }
    }
    
    return result;
}

- (BOOL)                control:(AKAControl *)control
                     modelValue:(inout_id)modelValueStorage
      validationFailedWithError:(inout_NSError)error
{
    BOOL result = NO;
    if (!result && [self.delegate respondsToSelector:@selector(control:modelValue:validationFailedWithError:)])
    {
        result = ![self.delegate control:control
                              modelValue:modelValueStorage
               validationFailedWithError:error];
    }
    if (!result)
    {
        result = [self.owner control:control
                          modelValue:modelValueStorage
           validationFailedWithError:error];
    }
    return result;
}

#pragma mark View Value Validation

- (BOOL)validateViewValue:(inout id*)viewValueStorage
                    error:(out NSError *__autoreleasing *)error
{
    return [self validateViewValue:viewValueStorage
                             error:error
                   storeModelValue:nil];
}

- (BOOL)validateViewValue:(inout id*)viewValueStorage
                    error:(out NSError *__autoreleasing *)error
          storeModelValue:(out id*)modelValueStorage
{
    BOOL result = YES;

    id modelValue = nil;
    result = [self convertViewValue:*viewValueStorage
                       toModelValue:&modelValue
                              error:error];
    if (result)
    {
        BOOL needsValidation = YES;
        while (needsValidation)
        {
            needsValidation = NO;
            result = [self validateModelValue:&modelValue
                                        error:error
                                 callDelegate:NO];
            if (!result)
            {
                id previousValue = modelValue;
                result = ![self         control:self
                                      viewValue:*viewValueStorage
                          convertedToModelValue:&modelValue
                      validationFailedWithError:error];
                // Reject request to accept invalid value:
                if (previousValue == modelValue)
                {
                    result = NO;
                }
                needsValidation = result;
            }
        }
    }

    if (result && modelValueStorage != nil)
    {
        *modelValueStorage = modelValue;
    }

    return result;
}

- (BOOL)                control:(AKAControl *)control
                      viewValue:(id)viewValue
          convertedToModelValue:(inout_id)modelValueStorage
      validationFailedWithError:(inout_NSError)error
{
    BOOL result = NO;
    if (!result && [self.delegate respondsToSelector:@selector(control:viewValue:convertedToModelValue:validationFailedWithError:)])
    {
        result = ![self.delegate control:control
                               viewValue:viewValue
                   convertedToModelValue:modelValueStorage
               validationFailedWithError:error];
    }
    if (!result && self.owner != nil)
    {
        result = [self.owner control:control
                           viewValue:viewValue
               convertedToModelValue:modelValueStorage
           validationFailedWithError:error];
    }
    return result;
}

#pragma mark - Change Tracking

#pragma mark Handling Changes

- (void)viewValueDidChangeFrom:(id)oldValue to:(id)newValue
{
    [self updateModelValueForViewValueChangeTo:newValue];
}

- (void)modelValueDidChangeFrom:(id)oldValue to:(id)newValue
{
    (void)oldValue; // not used.

    // Model changes can occur in any thread. Since such changes will most likely
    // result in UI updates, we have to make sure that updates are performed in
    // the main thread.
    __weak typeof(self)weakSelf = self;
    
    [self aka_performBlockInMainThreadOrQueue:
     ^{
         [weakSelf updateViewValueForModelValueChangeTo:newValue];
     }
                            waitForCompletion:NO];

    [self control:self modelValueChangedFrom:oldValue to:newValue];
}

- (void)control:(AKAControl*)control modelValueChangedFrom:(id)oldValue to:(id)newValue
{
    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:modelValueChangedFrom:to:)])
    {
        [delegate control:control modelValueChangedFrom:oldValue to:newValue];
    }
    [self.owner control:control modelValueChangedFrom:oldValue to:newValue];
}

- (void)updateViewValueForModelValueChangeTo:(id)newValue
{
    NSError* error = nil;
    BOOL isValid = [self updateViewValueForModelValueChangeTo:newValue
                                           validateModelValue:YES
                                                        error:&error];
    [self setIsValid:isValid error:error];
}

- (BOOL)updateViewValueForModelValueChangeTo:(id)newValue
                          validateModelValue:(BOOL)validateModelValue
                                       error:(NSError*__autoreleasing*)error
{
    BOOL result = YES;

    id validatedValue = newValue;
    if (validateModelValue)
    {
        result = [self validateModelValue:&validatedValue error:error];
    }

    if (result)
    {
        id viewValue = validatedValue;
        id<AKAControlConverterProtocol> converter = self.converter;
        if (converter != nil)
        {
            result = [converter convertModelValue:validatedValue toViewValue:&viewValue error:error];
        }
        if (result)
        {
            self.viewValue = viewValue;
        }
    }

    // Invalid model values should either be handled somehow or displayed as good as possible

    return result;
}

- (void)updateModelValueForViewValueChangeTo:(id)newValue
{
    NSError* error = nil;
    BOOL isValid = [self updateModelValueForViewValueChangeTo:newValue error:&error];
    [self setIsValid:isValid error:error];
}

- (BOOL)updateModelValueForViewValueChangeTo:(id)newValue error:(NSError*__autoreleasing*)error
{
    BOOL result = YES;

    id modelValue = newValue;
    id<AKAControlConverterProtocol> converter = self.converter;
    if (converter != nil)
    {
        result = [converter convertViewValue:newValue toModelValue:&modelValue error:error];
    }

    if (result)
    {
        result = [self validateModelValue:&modelValue error:error];
        if (result)
        {
            self.modelValue = modelValue;
        }
    }

    return result;
}

#pragma mark Controlling Observation

- (void)startObservingChanges
{
    if (!self.isObservingChanges)
    {
        [self startObservingModelValueChanges];
        [self startObservingViewValueChanges];
        [self startObservingOtherChanges];

        for (AKABinding* binding in self.bindings)
        {
            [binding startObservingChanges];
        }

        _isObservingChanges = YES;
    }
}

- (void)stopObservingChanges
{
    if (self.isObservingChanges)
    {
        [self stopObservingModelValueChanges];
        [self stopObservingViewValueChanges];
        [self stopObservingOtherChanges];

        for (AKABinding* binding in self.bindings)
        {
            [binding stopObservingChanges];
        }

        _isObservingChanges = NO;
    }
}

- (BOOL)startObservingModelValueChanges
{
    BOOL result = self.modelValueProperty.isObservingChanges;
    if (!result)
    {
        if (self.modelValueProperty)
        {
            // We don't get prior change events, so here is where we set the initial view value.
            [self updateViewValueForModelValueChangeTo:self.modelValueProperty.value];
        }
        result = [self.modelValueProperty startObservingChanges];
    }

    return result;
}

- (BOOL)startObservingViewValueChanges
{
    BOOL result = [self.viewValueProperty startObservingChanges];
    return result;
}

- (void)startObservingOtherChanges
{
    [self.converterProperty startObservingChanges];
    [self.validatorProperty startObservingChanges];
}

- (BOOL)stopObservingModelValueChanges
{
    return [self.modelValueProperty stopObservingChanges];
}

- (BOOL)stopObservingViewValueChanges
{
    return [self.viewValueProperty stopObservingChanges];
}

- (void)stopObservingOtherChanges
{
    [self.converterProperty stopObservingChanges];
    [self.validatorProperty stopObservingChanges];
}

- (BOOL)isObservingViewValueChanges
{
    return self.viewBinding.isObservingViewValueChanges;
}

- (BOOL)isObservingModelValueChanges
{
    return self.modelValueProperty.isObservingChanges;
}

#pragma mark - Activation

- (void)setIsActive:(BOOL)isActive
{
    // TODO: error handling
    _isActive = isActive;
}

- (BOOL)canActivate
{
    return self.viewBinding.supportsActivation;
}

- (BOOL)shouldActivate
{
    BOOL result = self.canActivate;
    if (result && [self.delegate respondsToSelector:@selector(shouldControlActivate:)])
    {
        result = [self.delegate shouldControlActivate:self];
    }
    if (result && self.owner)
    {
        result = [self.owner shouldControlActivate:self];
    }
    return result;
}

- (BOOL)activate
{
    BOOL result = self.canActivate;
    if (result)
    {
        result = [self.viewBinding activate];
    }
    return result;
}

- (void)willActivate
{
    if ([self.delegate respondsToSelector:@selector(controlWillActivate:)])
    {
        [self.delegate controlWillActivate:self];
    }
    [self.owner controlWillActivate:self];
}

- (void)didActivate
{
    [self setIsActive:YES];
    [self.owner controlDidActivate:self];
    if ([self.delegate respondsToSelector:@selector(controlDidActivate:)])
    {
        [self.delegate controlDidActivate:self];
    }
}

- (BOOL)shouldDeactivate
{
    BOOL result = YES;
    if (result && [self.delegate respondsToSelector:@selector(shouldControlDeactivate:)])
    {
        result = [self.delegate shouldControlDeactivate:self];
    }
    if (result && self.owner)
    {
        result = [self.owner shouldControlDeactivate:self];
    }
    return result;
}

- (BOOL)deactivate
{
    BOOL result = self.canActivate;
    if (result)
    {
        result = [self.viewBinding deactivate];
    }
    return result;
}

- (void)willDeactivate
{
    if ([self.delegate respondsToSelector:@selector(controlWillDeactivate:)])
    {
        [self.delegate controlWillDeactivate:self];
    }
    [self.owner controlWillDeactivate:self];
}

- (void)didDeactivate
{
    [self setIsActive:NO];

    [self.owner controlDidDeactivate:self];
    if ([self.delegate respondsToSelector:@selector(controlDidDeactivate:)])
    {
        [self.delegate controlDidDeactivate:self];
    }
}

- (BOOL)shouldActivateNextControl
{
    return [self.owner shouldActivateNextControl];
}

- (BOOL)activateNextControl
{
    return [self.owner activateNextControl];
}

- (BOOL)shouldAutoActivate
{
    return [self.viewBinding shouldAutoActivate];
}

- (BOOL)participatesInKeyboardActivationSequence
{
    BOOL result = [self.viewBinding participatesInKeyboardActivationSequence];

    if (!result)
    {
        result = [self shouldParticipateInKeyboardActivationSequence];
    }

    return result;
}

- (AKAKeyboardActivationSequence*)keyboardActivationSequence
{
    return self.owner.keyboardActivationSequence;
}

#pragma mark - AKABindingDelegate

- (void)                                              control:(req_AKAControl)control
                                                      binding:(req_AKABinding)binding
                                        responderWillActivate:(req_UIResponder)responder
{
    id<AKAControlActivationDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:responderWillActivate:)])
    {
        [delegate control:control binding:binding responderWillActivate:responder];
    }
    if ([self.owner respondsToSelector:@selector(control:binding:responderWillActivate:)])
    {
        [self.owner control:control binding:binding responderWillActivate:responder];
    }
}

- (void)                                              binding:(req_AKABinding)binding
                                        responderWillActivate:(req_UIResponder)responder
{
    [self control:self binding:binding responderWillActivate:responder];
    if ([binding conformsToProtocol:@protocol(AKAKeyboardActivationSequenceItemProtocol)])
    {
        id<AKAKeyboardActivationSequenceItemProtocol> item = (id<AKAKeyboardActivationSequenceItemProtocol>)binding;
        [self.keyboardActivationSequence prepareToActivateItem:item];
    }
}

- (void)binding:(req_AKABinding)binding responderDidActivate:(req_UIResponder)responder
{
    if ([binding conformsToProtocol:@protocol(AKAKeyboardActivationSequenceItemProtocol)])
    {
        id<AKAKeyboardActivationSequenceItemProtocol> item = (id<AKAKeyboardActivationSequenceItemProtocol>)binding;
        [self.keyboardActivationSequence activateItem:item];
    }
    [self didActivate];
}

- (void)binding:(req_AKABinding)binding responderWillDeactivate:(req_UIResponder)responder
{
    [self willDeactivate];
}

- (void)binding:(req_AKABinding)binding responderDidDeactivate:(req_UIResponder)responder
{
    if ([binding conformsToProtocol:@protocol(AKAKeyboardActivationSequenceItemProtocol)])
    {
        if (binding == self.keyboardActivationSequence.activeItem)
        {
            [self.keyboardActivationSequence deactivate];
        }
    }
    [self didDeactivate];
}

#pragma mark - AKAKeyboardActivationSequenceItemProtocol

- (BOOL)shouldParticipateInKeyboardActivationSequence
{
    BOOL result = NO;
    for (AKABinding* binding in self.bindings)
    {
        if ([binding conformsToProtocol:@protocol(AKAKeyboardActivationSequenceItemProtocol)])
        {
            id<AKAKeyboardActivationSequenceItemProtocol> item = (id<AKAKeyboardActivationSequenceItemProtocol>)binding;
            result |= [item shouldParticipateInKeyboardActivationSequence];
            if (result)
            {
                break;
            }
        }
    }
    return result;
}

- (BOOL)isResponderActive
{
    return self.isActive;
}

- (BOOL)activateResponder
{
    return [self activate];
}

- (BOOL)deactivateResponder
{
    return [self deactivate];
}

- (opt_UIResponder)responderForKeyboardActivationSequence
{
    return self.viewBinding.view;
}

- (BOOL)installInputAccessoryView:(req_UIView)inputAccessoryView
{
    // TODO: refactor this to let view bindings take care
    BOOL result = NO;
    UIResponder* responder = [self responderForKeyboardActivationSequence];
    if ([responder respondsToSelector:@selector(setInputAccessoryView:)])
    {
        /*
        if (oldView)
        {
            *oldView = responder.inputAccessoryView;
        }
         */
        [responder performSelector:@selector(setInputAccessoryView:)
                        withObject:inputAccessoryView];
        result = YES;
    }
    else if ([responder isKindOfClass:[UITextField class]])
    {
        UITextField* textField = (UITextField*)responder;
        textField.inputAccessoryView = inputAccessoryView;
    }
    return result;
}

- (BOOL)restoreInputAccessoryView
{
    BOOL result = NO;

    // TODO: refactor this to let view bindings take care

    UIResponder* responder = [self responderForKeyboardActivationSequence];
    UIView* originalInputAccessoryView = nil;

    if (responder.inputAccessoryView != self.keyboardActivationSequence.inputAccessoryView)
    {
        AKALogWarn(@"Input accessory view in responder %@ is not the expected view %@, found %@ instead. If the responders input accessory view was not changed after activation, this indicates an internal inconsistency of the activation sequence %@ or an unexpected behavior of the responder",
                   responder, self.keyboardActivationSequence.inputAccessoryView, responder.inputAccessoryView, self);
    }

    if ([responder respondsToSelector:@selector(setInputAccessoryView:)])
    {
        [responder performSelector:@selector(setInputAccessoryView:)
                        withObject:originalInputAccessoryView];
        result = YES;
    }
    else if ([responder isKindOfClass:[UITextField class]])
    {
        UITextField* textField = (UITextField*)responder;
        textField.inputAccessoryView = originalInputAccessoryView;
    }

    return result;
}

#pragma mark - View Binding Delegate

- (void)viewBinding:(AKAObsoleteViewBinding *)viewBinding
               view:(UIView *)view
 valueDidChangeFrom:(id)oldValue
                 to:(id)newValue
{
    NSParameterAssert(view == self.view);
    NSParameterAssert(viewBinding == self.viewBinding);

    [self viewValueDidChangeFrom:oldValue to:newValue];
}

- (BOOL)viewBindingShouldActivate:(AKAObsoleteViewBinding *)viewBinding
{
    NSParameterAssert(viewBinding == self.viewBinding);
    return [self shouldActivate];
}

- (void)viewBinding:(AKAObsoleteViewBinding *)viewBinding viewWillActivate:(UIView *)view
{
    NSParameterAssert(viewBinding == self.viewBinding);
    [self willActivate];
    if (self.viewBinding.participatesInKeyboardActivationSequence)
    {
        // Ensure that input accessory view is installed before a control becomes first responder. This is needed in cases where a view overrides becomeFirstResponder and calls willActivate.
        [self.keyboardActivationSequence prepareToActivateItem:self];
    }
}

- (void)viewBinding:(AKAObsoleteViewBinding *)viewBinding viewDidActivate:(UIView *)view
{
    NSParameterAssert(viewBinding == self.viewBinding);
    if (viewBinding.participatesInKeyboardActivationSequence)
    {
        [self.keyboardActivationSequence activateItem:self];
    }
    [self didActivate];
}

- (BOOL)viewBindingShouldDeactivate:(AKAObsoleteViewBinding *)viewBinding
{
    NSParameterAssert(viewBinding == self.viewBinding);
    return [self shouldDeactivate];
}

- (void)viewBinding:(AKAObsoleteViewBinding *)viewBinding viewWillDeactivate:(UIView *)view
{
    NSParameterAssert(viewBinding == self.viewBinding);
    [self willDeactivate];
}

- (void)viewBinding:(AKAObsoleteViewBinding *)viewBinding viewDidDeactivate:(UIView *)view
{
    NSParameterAssert(viewBinding == self.viewBinding);

    if (self.viewBinding.participatesInKeyboardActivationSequence)
    {
        if (self == self.keyboardActivationSequence.activeItem)
        {
            [self.keyboardActivationSequence deactivate];
        }
    }
    [self didDeactivate];
}

#pragma mark - Theme Selection

- (AKAProperty*)themeNamePropertyForView:(UIView*)view
                  changeObserver:(void(^)(id oldValue, id newValue))themeNameChanged
{
    AKAProperty* result = nil;
    NSString* themeName;
    if (self.themeNameByType != nil)
    {
        for (Class type = view.class; [type isSubclassOfClass:[UIView class]]; type = [type superclass])
        {
            NSString* typeName = NSStringFromClass(type);
            themeName = self.themeNameByType[typeName];
            if (themeName)
            {
                result = [AKAProperty propertyOfWeakKeyValueTarget:self.themeNameByType
                                                           keyPath:typeName
                                                    changeObserver:themeNameChanged];
                break;
            }
        }
    }
    if (!result)
    {
        result = [self.owner themeNamePropertyForView:view
                                       changeObserver:themeNameChanged];
    }
    return result;
}

- (void)setThemeName:(NSString*)themeName forClass:(Class)type
{
    if (!self.themeNameByType)
    {
        self.themeNameByType = NSMutableDictionary.new;
    }
    self.themeNameByType[NSStringFromClass(type)] = themeName;
}

#pragma mark - Diagnostics

- (NSString *)debugDescription
{
    NSString* details = self.debugDescriptionDetails;
    NSString* result = nil;

    if (details.length > 0)
    {
        return [NSString stringWithFormat:@"<%@ %p; %@>", self.class, self, details];
    }
    else
    {
        return [NSString stringWithFormat:@"<%@ %p>", self.class, self];
    }
    return result;
}

- (NSString *)debugDescriptionDetails
{
    NSString* result = [NSString stringWithFormat:@"view: %@, configuration: { %@ }",
                        self.view.description,
                        self.viewBinding.configuration.description];
    return result;
}

@end


@implementation AKAControl(Convenience)

#pragma mark - Properties


@end