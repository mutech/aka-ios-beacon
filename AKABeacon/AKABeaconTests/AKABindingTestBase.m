//
//  AKABindingTestBase.m
//  AKABeacon
//
//  Created by Michael Utech on 12.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingTestBase.h"
#import "AKAChildBindingContext.h"

@implementation AKABindingTestBase

#pragma mark - Configuration

- (void)setUp
{
    [super setUp];
    _dataContext = [NSMutableDictionary new];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - View Model Configuration and Access

- (id<AKABindingContextProtocol>)bindingContextForDataContextAtKeyPath:(req_NSString)keyPath
{
    return [AKAChildBindingContext bindingContextWithParent:self keyPath:keyPath];
}

- (id<AKABindingContextProtocol>)bindingContextForNewDataContext:(id)dataContext
                                                       atKeyPath:(NSString*)keyPath
{
    id<AKABindingContextProtocol> result = nil;

    NSObject* target = self.dataContext;
    NSArray<NSString*>* keys = [keyPath componentsSeparatedByString:@"."];
    if (keys.count > 0)
    {
        for (NSUInteger i=0; i + 1 < keys.count; ++i)
        {
            NSString* key = keys[i];
            id v = [target valueForKey:key];
            if (!v)
            {
                v = [NSMutableDictionary new];
                [target setValue:v forKey:key];
            }
            target = v;
        }

        if (target)
        {
            [target setValue:dataContext forKey:(req_NSString)keys.lastObject];
        }

        result = [self bindingContextForDataContextAtKeyPath:keyPath];
    }
    return result;
}

#pragma mark - Binding Context Protocol

- (id)                  dataContextValueForKeyPath:(NSString *)keyPath
{
    return [self.dataContext valueForKeyPath:keyPath];
}

- (AKAProperty *)    dataContextPropertyForKeyPath:(NSString *)keyPath
                                withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    return [AKAProperty propertyOfWeakKeyValueTarget:self.dataContext keyPath:keyPath changeObserver:valueDidChange];
}

- (id)              rootDataContextValueForKeyPath:(NSString *)keyPath
{
    return [self dataContextValueForKeyPath:keyPath];
}

- (AKAProperty *)rootDataContextPropertyForKeyPath:(NSString *)keyPath
                                withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    return [self dataContextPropertyForKeyPath:keyPath withChangeObserver:valueDidChange];
}

- (id)                      controlValueForKeyPath:(NSString *__unused)keyPath
{
    return nil;
}

- (AKAProperty *)        controlPropertyForKeyPath:(NSString *__unused)keyPath
                                withChangeObserver:(AKAPropertyChangeObserver __unused)valueDidChange
{
    return nil;
}

@end
