//
//  AKAChildBindingContext.m
//  AKABeacon
//
//  Created by Michael Utech on 11.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAChildBindingContext.h"

@interface AKAChildBindingContext()

@property(nonatomic) AKAProperty* dataContextProperty;

@end


@implementation AKAChildBindingContext

+ (instancetype)          bindingContextWithParent:(id<AKABindingContextProtocol>)bindingContext
                               dataContextProperty:(req_AKAProperty)dataContextProperty
{
    return [[self alloc] initWithParent:bindingContext dataContextProperty:dataContextProperty];
}

- (instancetype)                    initWithParent:(id<AKABindingContextProtocol>)bindingContext
                               dataContextProperty:(req_AKAProperty)dataContextProperty
{
    if (self = [self init])
    {
        _dataContextProperty = dataContextProperty;
        _parent = bindingContext;
    }
    return self;
}

+ (instancetype)          bindingContextWithParent:(id<AKABindingContextProtocol>)bindingContext
                                       dataContext:(id)dataContext
{
    return [[self alloc] initWithParent:bindingContext dataContext:dataContext];
}

- (instancetype)                    initWithParent:(id<AKABindingContextProtocol>)bindingContext
                                       dataContext:(id)dataContext
{
    return [self initWithParent:bindingContext
            dataContextProperty:[AKAProperty propertyOfWeakKeyValueTarget:dataContext
                                                                  keyPath:nil
                                                           changeObserver:nil]];
}


+ (instancetype)          bindingContextWithParent:(id<AKABindingContextProtocol>)bindingContext
                                           keyPath:(NSString*)keyPath
{
    return [[self alloc] initWithParent:bindingContext keyPath:keyPath];
}

- (instancetype)                    initWithParent:(id<AKABindingContextProtocol>)bindingContext
                                           keyPath:(NSString*)keyPath
{
    return [self initWithParent:bindingContext
            dataContextProperty:[bindingContext dataContextPropertyForKeyPath:keyPath
                                                           withChangeObserver:nil]];
}

#pragma mark - Binding Context Protocol implementation

- (id)dataContext
{
    return self.dataContextProperty.value;
}

- (id)                  dataContextValueForKeyPath:(NSString *)keyPath
{
    return [self.dataContextProperty targetValueForKeyPath:keyPath];
}

- (AKAProperty *)    dataContextPropertyForKeyPath:(NSString *)keyPath
                                withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    return [self.dataContextProperty propertyAtKeyPath:keyPath withChangeObserver:valueDidChange];
}

- (id)              rootDataContextValueForKeyPath:(NSString *)keyPath
{
    return [self.parent rootDataContextValueForKeyPath:keyPath];
}

- (AKAProperty *)rootDataContextPropertyForKeyPath:(NSString *)keyPath
                                withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    return [self.parent rootDataContextPropertyForKeyPath:keyPath withChangeObserver:valueDidChange];
}

- (id)                      controlValueForKeyPath:(NSString *)keyPath
{
    return [self.parent controlValueForKeyPath:keyPath];
}

- (AKAProperty *)        controlPropertyForKeyPath:(NSString *)keyPath
                                withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    return [self.parent controlPropertyForKeyPath:keyPath withChangeObserver:valueDidChange];
}

@end

