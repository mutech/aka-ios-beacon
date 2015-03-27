//
// Created by Michael Utech on 25.03.15.
// Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATheme.h"
#import "AKAThemeViewCustomization.h"
#import "AKAThemeViewCustomization.h"
#import "AKAThemeViewApplicability.h"

@interface AKAThemeViewCustomization()

@property(nonatomic)NSArray* validTypes;
@property(nonatomic)NSArray* invalidTypes;
@property(nonatomic)NSMutableDictionary* propertyValuesByName;
@property(nonatomic)AKAThemeViewApplicability* applicability;

@end

@implementation AKAThemeViewCustomization

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
            delegate:(id<AKAThemeViewCustomizationDelegate>)delegate
{
    id view = views[self.viewKey];
    return [self applyToView:view delegate:delegate];
}

- (BOOL)applyToView:(id)view
           delegate:(id<AKAThemeViewCustomizationDelegate>)delegate
{
    BOOL result = [self isApplicableToView:view];
    if (result)
    {
        [self willApplyToView:view delegate:delegate];
        [self.propertyValuesByName enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             id oldValue = [view valueForKey:key];
             id newValue = obj == [NSNull null] ? nil : obj;
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

#pragma mark - AKAThemeViewCustomizationDelegate support

- (void)willApplyToView:(UIView*)view
               delegate:(NSObject<AKAThemeViewCustomizationDelegate>*)delegate
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
                delegate:(NSObject<AKAThemeViewCustomizationDelegate>*)delegate
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
             delegate:(NSObject<AKAThemeViewCustomizationDelegate>*)delegate
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
              delegate:(NSObject<AKAThemeViewCustomizationDelegate>*)delegate
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

#pragma mark Requirements

- (void)setRequiresViewsOfTypeIn:(NSArray *)validTypes
{
    if (!self.applicability)
    {
        self.applicability = [[AKAThemeViewApplicability alloc] initRequirePresent];
    }
    [self.applicability setRequiresViewsOfTypeIn:validTypes];
}

- (void)setRequiresViewsOfTypeNotIn:(NSArray *)invalidTypes
{
    if (!self.applicability)
    {
        self.applicability = [[AKAThemeViewApplicability alloc] initRequirePresent];
    }
    [self.applicability setRequiresViewsOfTypeNotIn:invalidTypes];
}

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