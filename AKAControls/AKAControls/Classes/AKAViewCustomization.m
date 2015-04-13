//
// Created by Michael Utech on 25.03.15.
// Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <AKACommons/AKAProperty.h>
#import "AKATheme.h"
#import "AKAViewCustomization.h"
#import "AKAThemeViewApplicability.h"
#import "AKAControlsErrors.h"

@interface AKAViewCustomization ()

@property(nonatomic)NSArray* validTypes;
@property(nonatomic)NSArray* invalidTypes;
@property(nonatomic)NSMutableDictionary* propertyValuesByName;
@property(nonatomic)AKAThemeViewApplicability* applicability;

@end

@implementation AKAViewCustomization

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.propertyValuesByName = NSMutableDictionary.new;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self)
    {
        [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            (void)stop; // not needed
            if ([@"view" isEqualToString:key])
            {
                self.viewKey = obj;
            }
            else if ([@"requirements" isEqualToString:key])
            {
                self.applicability = [[AKAThemeViewApplicability alloc] initWithSpecification:obj];
            }
            else if ([@"properties" isEqualToString:key])
            {
                NSDictionary* properties = obj;
                [properties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    [self addCustomizationSetValue:obj forPropertyName:key];
                }];
            }
            else
            {
                // TODO: error handling
            }
        }];
    }
    return self;
}

#pragma mark - Application

- (BOOL)isApplicableToView:(id)view
{
    return self.applicability ? [self.applicability isApplicableToView:view] : YES;
}

- (BOOL)applyToViews:(NSDictionary *)views
        withContext:(id)context
            delegate:(id<AKAViewCustomizationDelegate>)delegate
{
    id view = views[self.viewKey];
    return [self applyToView:view withContext:context delegate:delegate];
}

- (BOOL)applyToView:(id)view
        withContext:(id)context
           delegate:(id<AKAViewCustomizationDelegate>)delegate
{
    BOOL result = [self isApplicableToView:view];
    if (result)
    {
        [self willApplyToView:view delegate:delegate];
        [self.propertyValuesByName enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             id oldValue = [view valueForKey:key];
             id newValue = [self resolvePropertyValue:obj withContext:context];

             if ([self shouldSetProperty:key value:oldValue to:newValue delegate:delegate])
             {
                 [view setValue:newValue forKey:key];
                 [self didSetProperty:key value:oldValue to:obj delegate:delegate];
             }
         }];
        [self didApplyToView:view delegate:delegate];
    }
    return result;
}

- (id)resolvePropertyValue:(id)obj withContext:(id)context
{
    id result = obj;
    if ([result isKindOfClass:[AKAProperty class]])
    {
        AKAProperty* p = result;
        result = [p valueWithDefaultTarget:context];
    }
    if (result == [NSNull null])
    {
        result = nil;
    }
    return result;
}

#pragma mark - AKAViewCustomizationDelegate support

- (void)willApplyToView:(UIView*)view
               delegate:(NSObject<AKAViewCustomizationDelegate>*)delegate
{
    if ([delegate respondsToSelector:@selector(viewCustomizations:willBeAppliedToView:)])
    {
        [delegate viewCustomizations:self willBeAppliedToView:view];
    }
    if ([self.delegate respondsToSelector:@selector(viewCustomizations:willBeAppliedToView:)])
    {
        [self.delegate viewCustomizations:self willBeAppliedToView:view];
    }
}

-(BOOL)shouldSetProperty:(NSString*)name
                   value:(id)oldValue
                      to:(id)newValue
                delegate:(NSObject<AKAViewCustomizationDelegate>*)delegate
{
    BOOL result = YES;
    if (result && [delegate respondsToSelector:@selector(viewCustomizations:shouldSetProperty:value:to:)])
    {
        result &= [delegate viewCustomizations:self
                             shouldSetProperty:name
                                         value:oldValue
                                            to:newValue];
    }
    if (result && [self.delegate respondsToSelector:@selector(viewCustomizations:shouldSetProperty:value:to:)])
    {
        result &= [self.delegate viewCustomizations:self
                             shouldSetProperty:name
                                         value:oldValue
                                            to:newValue];
    }
    return result;
}

-(void)didSetProperty:(NSString*)name
                value:(id)oldValue
                   to:(id)newValue
             delegate:(NSObject<AKAViewCustomizationDelegate>*)delegate
{
    if ([delegate respondsToSelector:@selector(viewCustomizations:didSetProperty:value:to:)])
    {
        [delegate viewCustomizations:self didSetProperty:name value:oldValue to:newValue];
    }
    if ([self.delegate respondsToSelector:@selector(viewCustomizations:didSetProperty:value:to:)])
    {
        [self.delegate viewCustomizations:self didSetProperty:name value:oldValue to:newValue];
    }
}

- (void)didApplyToView:(UIView*)view
              delegate:(NSObject<AKAViewCustomizationDelegate>*)delegate
{
    if ([delegate respondsToSelector:@selector(viewCustomizations:haveBeenAppliedToView:)])
    {
        [delegate viewCustomizations:self haveBeenAppliedToView:view];
    }
    if ([self.delegate respondsToSelector:@selector(viewCustomizations:haveBeenAppliedToView:)])
    {
        [self.delegate viewCustomizations:self haveBeenAppliedToView:view];
    }
}

#pragma mark - Configuration

#pragma mark Property customizations

- (void)addCustomizationSetValue:(id)value forPropertyName:(NSString *)name
{
    self.propertyValuesByName[name] = (value == nil ? [NSNull null] : value);
}

- (void)removeCustomizationSetValueForPropertyName:(NSString *)name
{
    [self.propertyValuesByName removeObjectForKey:name];
}

#pragma mark Implementation

- (UIView *)viewInTarget:(NSObject*)target
{
    id result = nil;
    if (target != nil && self.viewKey.length > 0)
    {
        result = [target valueForKey:self.viewKey];
    }
    return result;
}

@end

@interface AKAViewCustomizationContainer() <AKAViewCustomizationDelegate> {
    NSMutableArray* _viewCustomizations;
}
@end

@implementation AKAViewCustomizationContainer

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _viewCustomizations = NSMutableArray.new;
    }
    return self;
}

#pragma mark - Configuration

- (NSObject<AKAViewCustomizationDelegate> *)viewCustomizationDelegate
{
    AKAErrorAbstractMethodImplementationMissing();
}

#pragma mark - Application

- (void)applyViewCustomizationsToTarget:(UIView*)target
                              withViews:(NSDictionary*)views
                               delegate:(NSObject<AKAThemeDelegate>*)delegate
{
    for (AKAViewCustomization * customization in self.viewCustomizations)
    {
        [customization applyToViews:views withContext:target delegate:delegate];
    }
}


#pragma mark - Adding View Customizations

- (NSArray *)viewCustomizations
{
    return [NSArray arrayWithArray:_viewCustomizations];
}

- (NSUInteger)addViewCustomizationsWithArrayOfDictionaries:(NSArray*)specifications
{
    NSUInteger count = 0;
    for (id spec in specifications)
    {
        if ([spec isKindOfClass:[NSDictionary class]])
        {
            id vc = [self addViewCustomizationWithDictionary:spec];
            if (vc != nil)
            {
                ++count;
            }
            else
            {
                // TODO: error handling
            }
        }
        else
        {
            // TODO: error handling
        }
    }
    return count;
}

- (AKAViewCustomization *)addViewCustomizationWithDictionary:(NSDictionary*)specification
{
    AKAViewCustomization * result = [[AKAViewCustomization alloc] initWithDictionary:specification];
    if (result != nil)
    {
        [self addViewCustomization:result];
    }
    return result;
}

- (void)addViewCustomization:(AKAViewCustomization *)viewCustomization
{
    [_viewCustomizations addObject:viewCustomization];
    viewCustomization.delegate = self;
}

#pragma mark - AKAViewCustomizationDelegate methods

- (void)viewCustomizations:(AKAViewCustomization *)customization
       willBeAppliedToView:(id)view
{
    if ([self.viewCustomizationDelegate respondsToSelector:@selector(viewCustomizations:willBeAppliedToView:)])
    {
        [self.viewCustomizationDelegate viewCustomizations:customization
                      willBeAppliedToView:view];
    }
}

- (BOOL)viewCustomizations:(AKAViewCustomization *)customization
         shouldSetProperty:(NSString*)name
                     value:(id)oldValue
                        to:(id)newValue
{
    BOOL result = YES;
    if ([self.viewCustomizationDelegate respondsToSelector:@selector(viewCustomizations:shouldSetProperty:value:to:)])
    {
        result = [self.viewCustomizationDelegate viewCustomizations:customization
                                                  shouldSetProperty:name
                                                                value:oldValue
                                                to:newValue];
    }
    return result;
}

- (void)viewCustomizations:(AKAViewCustomization *)customization
            didSetProperty:(NSString *)name
                     value:(id)oldValue
                        to:(id)newValue
{
    if ([self.viewCustomizationDelegate respondsToSelector:@selector(viewCustomizations:didSetProperty:value:to:)])
    {
        [self.viewCustomizationDelegate viewCustomizations:customization
                           didSetProperty:name
                                    value:oldValue
                                       to:newValue];
    }
}

- (void)viewCustomizations:(AKAViewCustomization *)customizations
     haveBeenAppliedToView:(id)view
{
    if ([self.viewCustomizationDelegate respondsToSelector:@selector(viewCustomizations:haveBeenAppliedToView:)])
    {
        [self.viewCustomizationDelegate viewCustomizations:customizations
                    haveBeenAppliedToView:view];
    }
}

@end