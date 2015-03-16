//
//  AKAProperty.m
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAProperty.h"

@interface AKAKVOProperty: AKAProperty

- (instancetype)initWithTarget:(NSObject*)target
                       keyPath:(NSString*)keyPath
                changeObserver:(void(^)(id oldValue, id newValue))valueDidChange;

@property(nonatomic, readonly) NSObject* target;
@property(nonatomic, readonly) NSString* keyPath;

@end


@interface AKACustomProperty: AKAProperty

- (instancetype)initWithGetter:(id(^)())getter
                        setter:(void(^)(id value))setter
            observationStarter:(BOOL(^)())observationStarter
            observationStopper:(BOOL(^)())observationStopper;

@end


@interface AKAProperty()

@property(nonatomic, strong) NSHashTable* dependentPropertiesStorage;
@property(nonatomic, strong) NSHashTable* dependencyPropertiesStorage;

@end

@interface  AKAProperty(Protected)

- (void)addDependentProperty:(AKAProperty* __weak)derived;

- (void)addDependencyProperty:(AKAProperty* __weak)baseProperty;

- (void)dependencyDidChangeValueFrom:(id)oldValue to:(id)newValue;

- (void)propertyValueDidChangeFrom:(id)oldValue to:(id)newValue;

@end

@implementation AKAProperty

#pragma mark - Initialization

+ (AKAProperty*)propertyOfKeyValueTarget:(NSObject*)target
                                   keyPath:(NSString*)keyPath
                            changeObserver:(void(^)(id oldValue, id newValue))valueDidChange
{
    return [[AKAKVOProperty alloc] initWithTarget:target keyPath:keyPath changeObserver:valueDidChange];
}

+ (AKAProperty*)propertyWithGetter:(id(^)())getter
                            setter:(void(^)(id value))setter
                observationStarter:(BOOL(^)())observationStarter
                         observationStopper:(BOOL(^)())observationStopper
{
    return [[AKACustomProperty alloc] initWithGetter:getter
                                             setter:setter
                                 observationStarter:observationStarter
                                 observationStopper:observationStopper];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (void)dealloc
{
    if (self.isObservingChanges)
    {
        [self stopObservingChanges];
    }
}

- (AKAProperty *)propertyAtKeyPath:(NSString *)keyPath withChangeObserver:(void (^)(id, id))valueDidChange
{
    AKAProperty* result = [AKAProperty propertyOfKeyValueTarget:self.value
                                                        keyPath:keyPath
                                                 changeObserver:valueDidChange];
    [self addDependentProperty:result];
    [result addDependencyProperty:self];

    return result;
}

- (AKAProperty *)propertyComputedBy:(id (^)(id))computation
{
    // TODO: implement computed property
    (void)computation;
    return nil;
}

#pragma mark - Value Access

- (id)value
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Class %@ failed to implement method %s", NSStringFromClass(self.class), __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

- (void)setValue:(id)value
{
    (void)value; // not used, throwing exception
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Class %@ failed to implement method %s", NSStringFromClass(self.class), __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

#pragma mark - Validation

- (BOOL)    validateValue:(inout __autoreleasing id *)ioValue
                    error:(out NSError *__autoreleasing *)outError
{
    (void)ioValue; // not used
    (void)outError; // not used
    return YES;
}

#pragma mark - Notifications

- (BOOL)isObservingChanges
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Class %@ failed to implement method %s", NSStringFromClass(self.class), __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

- (BOOL)startObservingChanges
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Class %@ failed to implement method %s", NSStringFromClass(self.class), __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

- (BOOL)stopObservingChanges
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Class %@ failed to implement method %s", NSStringFromClass(self.class), __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

- (void)notifyPropertyValueDidChangeFrom:(id)oldValue to:(id)newValue
{
    (void)oldValue; // not used.
    (void)newValue; // not used.
    // Nothing to do, subclasses which do not manage notifications will need this to notify dependant properties.
}

- (void)notifyDependenciesValueDidChangeFrom:(id)oldValue to:(id)newValue
{
    for (AKAProperty* property in self.dependentProperties)
    {
        [property dependencyDidChangeValueFrom:oldValue to:newValue];
    }
}

#pragma mark - Dependent Properties

- (NSSet*)dependentProperties
{
    NSSet* result = nil;
    if (self.dependentPropertiesStorage)
    {
        result = self.dependentPropertiesStorage.setRepresentation;
    }
    else
    {
        result = [[NSSet alloc] init];
    }
    return result;
}

- (NSSet*)dependencyProperties
{
    NSSet* result = nil;
    if (self.dependencyPropertiesStorage)
    {
        result = self.dependencyPropertiesStorage.setRepresentation;
    }
    else
    {
        result = [[NSSet alloc] init];
    }
    return result;
}

- (void)addDependencyProperty:(AKAProperty*)derived
{
    if (self.dependencyPropertiesStorage == nil)
    {
        self.dependencyPropertiesStorage = [[NSHashTable alloc] initWithOptions:NSHashTableWeakMemory
                                                                      capacity:1];
    }
    [self.dependencyPropertiesStorage addObject:derived];
}

- (void)addDependentProperty:(AKAProperty*)derived
{
    if (self.dependentPropertiesStorage == nil)
    {
        self.dependentPropertiesStorage = [[NSHashTable alloc] initWithOptions:NSHashTableWeakMemory
                                                                      capacity:1];
    }
    [self.dependentPropertiesStorage addObject:derived];
}

- (void)propertyValueDidChangeFrom:(id)oldValue to:(id)newValue
{
    for (id dependant in self.dependentPropertiesStorage)
    {
        if (dependant && dependant != [NSNull null])
        {
            [((AKAProperty*)dependant) dependencyDidChangeValueFrom:oldValue to:newValue];
        }
    }
}

- (void)dependencyDidChangeValueFrom:(id)oldValue to:(id)newValue
{
    (void)oldValue; // not used, throwing exception
    (void)newValue; // not used, throwing exception

    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Class %@ failed to implement method %s", NSStringFromClass(self.class), __PRETTY_FUNCTION__]
                                 userInfo:nil];
}

@end


@interface AKAKVOProperty()

@property(nonatomic, readonly) void(^changeObserver)();

@end

@implementation AKAKVOProperty

@synthesize target = _target;
@synthesize keyPath = _keyPath;
@synthesize isObservingChanges = _isObservingChanges;
@synthesize changeObserver = _changeObserver;

#pragma mark - Initialization

- (instancetype)initWithTarget:(NSObject*)target
                       keyPath:(NSString *)keyPath
                changeObserver:(void(^)(id oldValue, id newValue))valueDidChange
{
    self = [super init];
    if (self)
    {
        _target = target;
        _keyPath = keyPath;
        _isObservingChanges = NO;
        _changeObserver = valueDidChange;
    }
    return self;
}

#pragma mark - Value Access

- (id)value
{
    return self.keyPath.length > 0 ? [self.target valueForKeyPath:self.keyPath] : self.target;
}

- (void)setValue:(id)value
{
    if (self.keyPath.length > 0)
    {
        [self.target setValue:value forKeyPath:self.keyPath];
    }
    else
    {
        id oldValue = self.target;
        _target = value;
        self.changeObserver(oldValue, value);
    }
}

#pragma mark - Validation

- (BOOL)    validateValue:(inout __autoreleasing id *)ioValue
                    error:(out NSError *__autoreleasing *)outError
{
    BOOL result = YES;
    if (self.keyPath.length > 0)
    {
        result = [self.target validateValue:ioValue
                                 forKeyPath:self.keyPath
                                      error:outError];
    }
    return result;
}

#pragma mark - Notifications

- (BOOL)isObservingChanges
{
    return _isObservingChanges;
}

- (BOOL)startObservingChanges
{
    if (!self.isObservingChanges)
    {
        if (self.keyPath.length == 0)
        {
            // target without keypath, in this case value wraps the target and
            // changing value <-> changing target, setter will send notification
            _isObservingChanges = YES;
        }
        else if (self.changeObserver)
        {
            [self.target addObserver:self
                          forKeyPath:self.keyPath
                             options:(NSKeyValueObservingOptions)
                                     (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                             context:(__bridge void *)(self)];
            _isObservingChanges = YES;
        }
    }
    return self.isObservingChanges;
}

- (BOOL)stopObservingChanges
{
    if (self.isObservingChanges)
    {
        [self.target removeObserver:self
                         forKeyPath:self.keyPath
                            context:(__bridge void *)(self)];
        _isObservingChanges = NO;
    }
    return !self.isObservingChanges;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ((self.changeObserver || self.dependentProperties.count > 0) &&
        context == (__bridge void *)(self) &&
        object == self.target &&
        [keyPath isEqualToString:self.keyPath])
    {
        id oldValue = change[NSKeyValueChangeOldKey];
        id newValue = change[NSKeyValueChangeNewKey];
        if (self.changeObserver)
        {
            self.changeObserver(oldValue, newValue);
        }
    }
}

#pragma mark - Dependent Properties

- (void)dependencyDidChangeValueFrom:(id)oldValue to:(id)newValue
{
    BOOL wasObservingChanges = self.isObservingChanges;
    if (_target == oldValue)
    {
        [self stopObservingChanges];
        id myOldValue = self.value;
        _target = newValue;
        id myNewValue = self.value;
        if (wasObservingChanges)
        {
            [self startObservingChanges];
        }
        if (myOldValue != myNewValue)
        {
            [self propertyValueDidChangeFrom:myOldValue to:myNewValue];
        }
    }
}

@end


@interface AKACustomProperty()

@property (nonatomic, strong) id(^getter)();
@property (nonatomic, strong) void(^setter)(id value);
@property (nonatomic, strong) BOOL(^observationStarter)(void(^notifyPropertyOfChange)(id oldValue, id newValue));
@property (nonatomic, strong) BOOL(^observationStopper)();

@end

@implementation AKACustomProperty

@synthesize isObservingChanges = _isObservingChanges;

#pragma mark - Initialization

- (instancetype)initWithGetter:(id (^)())getter
                        setter:(void (^)(id))setter
            observationStarter:(BOOL(^)())observationStarter
            observationStopper:(BOOL (^)())observationStopper
{
    self = [super init];
    if (self)
    {
        self.getter = getter;
        self.setter = setter;
        self.observationStarter = observationStarter;
        self.observationStopper = observationStopper;
        _isObservingChanges = NO;
    }
    return self;
}

#pragma mark - Value Access

- (id)value
{
    return self.getter();
}

- (void)setValue:(id)value
{
    self.setter(value);
}

#pragma mark - Notifications

- (BOOL)startObservingChanges
{
    BOOL result = self.isObservingChanges;
    if (!result && self.observationStarter)
    {
        result = self.observationStarter(^(id oldValue, id newValue) {
            [self propertyValueDidChangeFrom:oldValue to:newValue];
        });
    }
    return result;
}

- (BOOL)stopObservingChanges
{
    BOOL result = !self.isObservingChanges;
    if (!result)
    {
        result = self.observationStopper();
    }
    return result;
}

- (void)notifyPropertyValueDidChangeFrom:(id)oldValue to:(id)newValue
{
    [self notifyDependenciesValueDidChangeFrom:(id)oldValue to:(id)newValue];
}


@end