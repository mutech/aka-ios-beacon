//
//  AKABindingProviderBase.m
//  AKAControls
//
//  Created by Michael Utech on 20.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.NSString_AKATools;
@import AKACommons.AKAErrors;

#import "AKABindingProvider.h"
#import "AKABindingExpression_Internal.h"
#import "NSDictionary+AKABindingExpressionSpecification.h"

#import "UIView+AKABindingSupport.h"


@interface AKABindingAttributeBindingProvider: AKABindingProvider

@property(nonatomic, readonly, weak) AKABindingProvider* owner;
@property(nonatomic, readonly, weak) AKABindingProvider* targetBindingProvider;

@property(nonatomic, readonly, nonnull) NSString* attributeName;

- (instancetype)                 initWithOwner:(req_AKABindingProvider)owner
                                 attributeName:(req_NSString)attributeName
                bindingExpressionSpecification:(opt_NSDictionary)specification;

- (instancetype)                 initWithOwner:(req_AKABindingProvider)owner
                                 attributeName:(req_NSString)attributeName
                         targetBindingProvider:(req_AKABindingProvider)targetBindingProvider
                bindingExpressionSpecification:(opt_NSDictionary)specification;

@end

@implementation AKABindingProvider

#pragma mark - Interface Builder Property Support

- (NSString *)       bindingExpressionTextForSelector:(SEL)selector
                                               inView:(UIView *)view
{
    AKABindingExpression* expression = [view aka_bindingExpressionForProperty:selector];

    NSAssert(expression.bindingProvider == self,
             @"Binding expression %@.%@ was created by a different provider %@", view, NSStringFromSelector(selector), expression.bindingProvider);

    return expression.text;
}

- (void)                     setBindingExpressionText:(req_NSString)bindingExpressionText
                                          forSelector:(req_SEL)selector
                                               inView:(req_UIView)view
{
    NSParameterAssert(bindingExpressionText != nil);
    NSParameterAssert(selector != nil);
    NSParameterAssert(view != nil);

    NSString* text = [bindingExpressionText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (text.length > 0)
    {
        NSError* error = nil;
        AKABindingExpression* bindingExpression;

        bindingExpression = [AKABindingExpression bindingExpressionWithString:bindingExpressionText
                                                              bindingProvider:self
                                                                        error:&error];
        if (bindingExpression == nil)
        {
            NSString* message = [NSString stringWithFormat:@"Attempt to set invalid binding expression for property %@ in view %@", NSStringFromSelector(selector), view];

#if TARGET_INTEFACE_BUILDER
            AKALogError(@"%@: %@", message, error.localizedDescription);
#else
            @throw ([NSException exceptionWithName:message reason:error.localizedDescription userInfo:nil]);
#endif
        }

        [view aka_setBindingExpression:bindingExpression forProperty:selector];
    }
}

#pragma mark - Creating Bindings

- (req_AKABinding)  bindingWithView:(req_UIView)view
                         expression:(req_AKABindingExpression)bindingExpression
                            context:(req_AKABindingContext)bindingContext
                           delegate:(opt_AKABindingDelegate)delegate
{
    AKAErrorAbstractMethodImplementationMissing();
}

#pragma mark - Binding Expression Validation

- (BOOL)                    validateBindingExpression:(req_AKABindingExpression)bindingExpression
                                                error:(out_NSError)error
{
    BOOL result = [self validatePrimaryBindingExpression:bindingExpression
                                                           error:error];
    if (result)
    {
        result = [self validateAttributesInBindingExpression:bindingExpression
                                                       error:error];
    }
    return result;
}

- (BOOL)             validatePrimaryBindingExpression:(req_AKABindingExpression)bindingExpression
                                                error:(out_NSError)error
{
    return [self validatePrimaryBindingExpression:bindingExpression
                               usingSpecification:[self bindingExpressionSpecification]
                                            error:error];
}

- (BOOL)             validatePrimaryBindingExpression:(req_AKABindingExpression)bindingExpression
                                   usingSpecification:(opt_NSDictionary)specification
                                                error:(out_NSError)error
{
    BOOL result = YES;

    return result;
}

- (BOOL)        validateAttributesInBindingExpression:(req_AKABindingExpression)bindingExpression
                                                error:(out_NSError)error
{
    __block BOOL result = YES;
    __block NSError* e;

    [bindingExpression.attributes enumerateKeysAndObjectsUsingBlock:
                   ^(NSString* _Nonnull key, AKABindingExpression * _Nonnull obj, BOOL * _Nonnull stop)
                   {
                       AKABindingProvider* attributeBindingProvider = obj.bindingProvider;
                       result = [attributeBindingProvider validateBindingExpression:obj error:error?&e:nil];

                       *stop = !result;
                   }];
    if (!result && error)
    {
        *error = e;
    }
    return result;
}

- (BOOL)                    validateBindingExpression:(req_AKABindingExpression)bindingExpression
                                forAttributeAtKeyPath:(req_NSString)attributeKeyPath
                                          validatedBy:(opt_AKABindingProvider)targetBindingProvider
                                   atAttributeKeyPath:(opt_NSString)targetBindingProviderKeyPath
                                           withResult:(BOOL)result
                                                error:(out_NSError)error
{
    return result;
}

- (BOOL) validateBindingExpression:(req_AKABindingExpression)bindingExpression
                 forAttributeNamed:(req_NSString)attributeName
                usingSpecification:(opt_NSDictionary)specification
               supportedByProvider:(BOOL)providerSupportsAttribute
                             error:(out_NSError)error
{
    BOOL result = YES;

    NSDictionary* attributeSpec = [specification aka_specificationForAttributeWithName:attributeName];

    if (attributeSpec == nil && !providerSupportsAttribute && !specification.aka_acceptsUnspecifiedAttributes)
    {
        result = NO;
        if (error)
        {
            NSString* description = [NSString stringWithFormat:@"Binding attribute %@ not supported by binding provider %@", attributeName, self];
            *error = [NSError errorWithDomain:NSStringFromClass(self.class) code:AKABindingExpressionErrorCodeUnspecifiedAttributeNotAllowed userInfo:@{ NSLocalizedDescriptionKey: description}];
        }
    }
    if (result)
    {
        // TODO: validate attribute (not recursively!)
    }
    return result;
}

typedef enum AKABindingExpressionErrorCode {
    AKABindingExpressionErrorCodeArrayPrimaryNotAllowed,
    AKABindingExpressionErrorCodeUnspecifiedAttributeNotAllowed,
} AKABindingExpressionErrorCode;

- (NSDictionary*)bindingExpressionSpecification
{
    return @{ @"allowArrayType": @NO,
              @"allowUnspecifiedAttributes": @NO,
              @"attributes":
                  @{ @"unknownAttribute": @YES,
                     @"unknownAttribute.nestedAttribute": @YES},
              };
}

- (NSDictionary*)bindingExpressionSpecificationForAttributeAtKeyPath:(NSString*)attributeKeyPath
{
    id result = [[self bindingExpressionSpecification] valueForKey:@"attributes"];
    if (![result isKindOfClass:[NSDictionary class]])
    {
        // Ignore things like @NO or YES
        result = nil;
    }
    else
    {
        result = [result valueForKeyPath:attributeKeyPath];
    }
    return result;
}


- (req_AKABindingProvider)  providerForAttributeNamed:(req_NSString)attributeName
{
    AKABindingProvider* targetBindingProvider = [self targetProviderForAttributeAtKeyPath:attributeName];

    return [[AKABindingAttributeBindingProvider alloc] initWithOwner:self
                                                       attributeName:attributeName
                                               targetBindingProvider:targetBindingProvider
            bindingExpressionSpecification:[self bindingExpressionSpecificationForAttributeAtKeyPath:attributeName]];
}

- (req_AKABindingProvider) providerForBindingExpressionInPrimaryExpressionArrayAtIndex:(NSUInteger)index
{
    return nil;
}

- (opt_AKABindingProvider)targetProviderForAttributeAtKeyPath:(req_NSString)attributeKeyPath
{
    return nil;
}

@end

@interface AKABindingAttributeBindingProvider()
@property(nonatomic, readonly) NSDictionary* bindingExpressionSpecification;
@end

@implementation AKABindingAttributeBindingProvider

@synthesize bindingExpressionSpecification = _bindingExpressionSpecification;

#pragma mark - Initialization

- (instancetype)                 initWithOwner:(req_AKABindingProvider)owner
                                 attributeName:(req_NSString)attributeName
                                 specification:(opt_NSDictionary)specification
{
    if (self = [self init])
    {
        _owner = owner;
        _attributeName = attributeName;
        _targetBindingProvider = nil;
        _bindingExpressionSpecification = specification;
    }
    return self;
}

- (instancetype)                 initWithOwner:(req_AKABindingProvider)owner
                                 attributeName:(req_NSString)attributeName
                         targetBindingProvider:(req_AKABindingProvider)targetBindingProvider
                                 specification:(opt_NSDictionary)specification
{
    if (self = [self init])
    {
        _owner = owner;
        _attributeName = attributeName;
        _targetBindingProvider = targetBindingProvider;
        _bindingExpressionSpecification = specification;
    }
    return self;
}

#pragma mark - Binding Expression Validation

- (BOOL)             validateBindingExpression:(req_AKABindingExpression)bindingExpression
                                         error:(out_NSError)error
{
    BOOL result;

    if (self.targetBindingProvider)
    {
        // This binding expression is controlled by the configured self.targetBindingProvider
        // which is also responsible for its validation. We let it validate the expression
        // and delegate final validation (which might change/override the validatation result
        // upward the owner chain of this (self) binding provider:
        result = [self.targetBindingProvider validateBindingExpression:bindingExpression
                                                                 error:error];
        if (result)
        {
            result = [self validatePrimaryBindingExpression:bindingExpression
                                         usingSpecification:self.bindingExpressionSpecification
                                                      error:error];
        }
        result = [self.owner validateBindingExpression:bindingExpression
                                 forAttributeAtKeyPath:self.attributeName
                                           validatedBy:self.targetBindingProvider
                                    atAttributeKeyPath:self.attributeName
                                            withResult:result
                                                 error:error];
    }
    else
    {
        result = [self validatePrimaryBindingExpression:bindingExpression error:error];

        // This binding expression is not controlled by a targetBindingProvider, so we take
        // over responsibility by delegating the validation upward the owner chain for the expression
        // and then descending the expressions attribute tree and continuing the validation process.
        //
        // As a result, the root owner will get to validate all binding expressions in attribute
        // trees which are not controlled by targetBindingControllers.
        result = [self.owner validateBindingExpression:bindingExpression
                                 forAttributeAtKeyPath:self.attributeName
                                           validatedBy:nil
                                    atAttributeKeyPath:nil
                                            withResult:result
                                                 error:error];
        if (result)
        {
            result = [self validateAttributesInBindingExpression:bindingExpression error:error];
        }
    }
    return result;
}

- (BOOL)      validatePrimaryBindingExpression:(req_AKABindingExpression)bindingExpression
                                         error:(out_NSError)error
{
    BOOL result;
    if (self.targetBindingProvider)
    {
        // This is only implemented to provide correct behavior when this method is called directly.
        // This branch is not reached when called from validateBindingExpression:error:, see code there.
        result = [self.targetBindingProvider validatePrimaryBindingExpression:bindingExpression
                                                                        error:error];
    }
    else
    {
        result = [super validatePrimaryBindingExpression:bindingExpression error:error];
    }
    return result;
}

- (BOOL) validateAttributesInBindingExpression:(req_AKABindingExpression)bindingExpression
                                         error:(out_NSError)error
{
    __block BOOL result = YES;
    if (self.targetBindingProvider)
    {
        // This is only implemented to provide correct behavior when this method is called directly.
        // This branch is not reached when called from validateBindingExpression:error:, see code there.
        result = [self.targetBindingProvider validateAttributesInBindingExpression:bindingExpression
                                                                             error:error];
    }
    else
    {
        __block NSError* e;
        [bindingExpression.attributes enumerateKeysAndObjectsUsingBlock:
         ^(NSString* _Nonnull key, AKABindingExpression * _Nonnull obj, BOOL * _Nonnull stop)
         {
             AKABindingProvider* attributeBindingProvider = obj.bindingProvider;
             result = [attributeBindingProvider validateBindingExpression:obj error:error];

             if (![attributeBindingProvider isKindOfClass:[AKABindingAttributeBindingProvider class]])
             {
                 // If the provider is an attribute binding provider (instance of this class),
                 // the previous call to validateBindingExpression:error: will already have called
                 // the owner delegation method. If it is not (which should not happen, but well)
                 // we call the owner delegation method here to give the owner at least some reasonable
                 // notification.
                 // Note: we also reach this point if the attributes binding expression does not
                 // have an associated binding provider at all (another should-not-happen case).
                 NSString* keyPath = [self.attributeName stringByAppendingFormat:@"%@.", key];
                 result = [self.owner validateBindingExpression:obj
                                          forAttributeAtKeyPath:keyPath
                                                    validatedBy:attributeBindingProvider
                                             atAttributeKeyPath:attributeBindingProvider == nil ? nil : key
                                                     withResult:result
                                                          error:error?&e:nil];
             }

             *stop = !result;
         }];
        if (!result && error)
        {
            *error = e;
        }
    }
    return result;
}

- (BOOL)             validateBindingExpression:(req_AKABindingExpression)bindingExpression
                         forAttributeAtKeyPath:(req_NSString)attributeKeyPath
                                   validatedBy:(opt_AKABindingProvider)targetBindingProvider
                            atAttributeKeyPath:(opt_NSString)targetBindingProviderKeyPath
                                    withResult:(BOOL)previousResult
                                         error:(out_NSError)error
{
    BOOL result = previousResult;
    NSString* keyPath = [self.attributeName stringByAppendingFormat:@"%@.", attributeKeyPath];

    AKABindingProvider* responsibleBindingProvider = targetBindingProvider;
    NSString* responsibleKeyPath = targetBindingProviderKeyPath;

    if (self.targetBindingProvider)
    {
        // If we have a target binding provider, it will take over responsibility for previously
        // performed validations. So we set responsible binding provider and key path accordingly
        // and let it perform the attribute validation.
        responsibleBindingProvider = self.targetBindingProvider;
        responsibleKeyPath = self.attributeName;
        result = [self.targetBindingProvider validateBindingExpression:bindingExpression
                                                 forAttributeAtKeyPath:attributeKeyPath
                                                           validatedBy:targetBindingProvider
                                                    atAttributeKeyPath:attributeKeyPath
                                                            withResult:previousResult
                                                                 error:error];
    }
    // Whether or not we have a target binding provider, our owner (chain) will get the last
    // word here:
    result = [self.owner validateBindingExpression:bindingExpression
                             forAttributeAtKeyPath:keyPath
                                       validatedBy:responsibleBindingProvider
                                atAttributeKeyPath:responsibleKeyPath
                                        withResult:result
                                             error:error];
    return result;
}

@end
