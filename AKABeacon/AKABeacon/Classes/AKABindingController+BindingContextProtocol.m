//
//  AKABindingController+BindingContextProtocol.m
//  AKABeacon
//
//  Created by Michael Utech on 25.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingController+BindingContextProtocol.h"


#pragma mark - AKABindingController(BindingContextProtocol) - Implementation
#pragma mark -

@implementation AKABindingController(BindingContextProtocol)

@dynamic dataContextProperty;

- (id)                    dataContextValueForKeyPath:(NSString *)keyPath
{
    return keyPath.length ? [self.dataContextProperty targetValueForKeyPath:keyPath] : self.dataContextProperty.value;
}

- (AKAProperty *)      dataContextPropertyForKeyPath:(NSString *)keyPath
                                  withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    return [self.dataContextProperty propertyAtKeyPath:keyPath withChangeObserver:valueDidChange];
}

- (id)                rootDataContextValueForKeyPath:(NSString *)keyPath
{
    AKABindingController* parent = self.parent;
    return (parent
            ? [parent rootDataContextValueForKeyPath:keyPath]
            : [self dataContextValueForKeyPath:keyPath]);
}

- (AKAProperty *)  rootDataContextPropertyForKeyPath:(NSString *)keyPath
                                  withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    AKABindingController* parent = self.parent;
    return (parent
            ? [parent rootDataContextPropertyForKeyPath:keyPath withChangeObserver:valueDidChange]
            : [self dataContextPropertyForKeyPath:keyPath withChangeObserver:valueDidChange]);
}

- (id)                        controlValueForKeyPath:(NSString *)keyPath
{
    return [self.parent controlValueForKeyPath:keyPath];
}

- (AKAProperty *)          controlPropertyForKeyPath:(NSString *)keyPath
                                  withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    return [self.parent controlPropertyForKeyPath:keyPath withChangeObserver:valueDidChange];
}

@end


