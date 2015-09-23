//
//  AKAProperty.m
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAProperty.h"
#import "AKALog.h"
#import "NSString+AKATools.h"

#import "AKAErrors.h"


#pragma mark - AKAKVOProperty (Cluster Interface)
#pragma mark -

@interface AKAKVOProperty: AKAProperty

#pragma mark - Initialization

- (instancetype)initWithWeakTarget:(NSObject*)target
                           keyPath:(NSString*)keyPath
                    changeObserver:(void(^)(id oldValue, id newValue))valueDidChange;

- (instancetype)initWithWeakTarget:(NSObject*)target
                    changeObserver:(void(^)(id oldValue, id newValue))valueDidChange;

#pragma mark - Configuration

@property(nonatomic, readonly) NSString* keyPath;

@end


#pragma mark - AKAKVOProperty (Cluster Interface)
#pragma mark -

@interface AKAIndexedProperty: AKAProperty

#pragma mark - Initialization

- (instancetype)initWithWeakTarget:(NSObject*)target
                             index:(NSInteger)index
                    changeObserver:(void(^)(id oldValue, id newValue))valueDidChange;

#pragma mark - Configuration

@property(nonatomic, readonly) NSInteger index;

@end


#pragma mark - AKACustomProperty (Cluster Interface)
#pragma mark -

@interface AKACustomProperty: AKAProperty

#pragma mark - Initialization

- (instancetype)initWithWeakTarget:(id)target
                            getter:(id (^)(id target))getter
                            setter:(void (^)(id target, id value))setter
                observationStarter:(BOOL(^)(id target))observationStarter
                observationStopper:(BOOL (^)(id target))observationStopper;

@end


#pragma mark - AKAUnboundProperty (Implementation)
#pragma mark -

@implementation AKAUnboundProperty

#pragma mark - Initialization

+ (AKAUnboundProperty *)unboundPropertyWithKeyPath:(NSString *)keyPath
{
    return [[AKAKVOProperty alloc] initWithWeakTarget:nil
                                              keyPath:keyPath
                                       changeObserver:nil];
}

+ (AKAUnboundProperty *)unboundPropertyWithGetter:(id (^)(id))getter
                                           setter:(void (^)(id, id))setter
{
    return [[AKACustomProperty alloc] initWithWeakTarget:nil
                                                  getter:getter
                                                  setter:setter
                                      observationStarter:^BOOL(id target) { (void)target; return NO; }
                                      observationStopper:^BOOL(id target) { (void)target; return NO; }];
}

#pragma mark - Value Access

- (id)valueForTarget:(id)target
{
    (void)target;
    AKAErrorAbstractMethodImplementationMissing();
}

- (void)setValue:(id)value forTarget:(id)target
{
    (void)value;
    (void)target;
    AKAErrorAbstractMethodImplementationMissing();
}

@end


#pragma mark - AKAProperty (Private Interface)
#pragma mark -

@interface AKAProperty()

@property(nonatomic, weak) id target;
@property(nonatomic, strong) NSHashTable* dependentPropertiesStorage;
@property(nonatomic, strong) NSHashTable* dependencyPropertiesStorage;

@end


#pragma mark - AKAProperty (Protected Interface)
#pragma mark -

@interface  AKAProperty(Protected)

- (void)addDependentProperty:(AKAProperty* __weak)derived;

- (void)addDependencyProperty:(AKAProperty* __weak)baseProperty;

- (void)dependencyDidChangeValueFrom:(id)oldValue to:(id)newValue;

- (void)propertyValueDidChangeFrom:(id)oldValue to:(id)newValue;

@end


#pragma mark - AKAProperty (Implementation)
#pragma mark -

@implementation AKAProperty

#pragma mark - Initialization

+ (AKAProperty*)propertyOfWeakKeyValueTarget:(NSObject*)target
                                       index:(NSInteger)index
                              changeObserver:(void(^)(id oldValue, id newValue))valueDidChange
{
    return [[AKAIndexedProperty alloc] initWithWeakTarget:target
                                                index:index
                                       changeObserver:valueDidChange];
}

+ (AKAProperty*)propertyOfWeakKeyValueTarget:(NSObject*)target
                                     keyPath:(NSString*)keyPath
                              changeObserver:(void(^)(id oldValue, id newValue))valueDidChange
{
    return [[AKAKVOProperty alloc] initWithWeakTarget:target
                                              keyPath:keyPath
                                       changeObserver:valueDidChange];
}

+ (AKAProperty*)propertyOfWeakTarget:(id)target
                              getter:(id(^)(id target))getter
                              setter:(void(^)(id target, id value))setter
                  observationStarter:(BOOL(^)(id target))observationStarter
                  observationStopper:(BOOL(^)(id target))observationStopper
{
    return [[AKACustomProperty alloc] initWithWeakTarget:target
                                                  getter:getter
                                                  setter:setter
                                      observationStarter:observationStarter
                                      observationStopper:observationStopper];
}

- (instancetype)initWithWeakTarget:(id)target
{
    self = [super init];
    if (self)
    {
        self.target = target;
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

- (BOOL)resolveProperty:(out AKAProperty*__autoreleasing*)propertyStorage
             andKeyPath:(out NSString*__autoreleasing*)keyPathStorage
     forExtendedKeyPath:(out NSString*)keyPath
{
    BOOL result = YES;
    if ([keyPath hasPrefix:@"$"])
    {
        if ([keyPath hasPrefix:@"$root"])
        {
            AKAProperty* root;
            for (root=self;
                 root.dependencyPropertiesStorage.count > 0;
                 root=[root.dependencyPropertiesStorage.objectEnumerator nextObject])
            {
                if (root.dependencyPropertiesStorage.count > 1)
                {
                    // TODO: error handling
                    AKALogError(@"Invalid attempt to resolve key path extension $root from a property %@ that has multiple dependencies %@, starting from property %@", root, root.dependencyPropertiesStorage, self);
                }
            }
            result = root != nil;
            if (result)
            {
                *propertyStorage = root;
            }
            if (result)
            {
                if (keyPath.length == 5)
                {
                    *keyPathStorage = nil;
                }
                else if (keyPath.length > 6 && [keyPath characterAtIndex:5] == (unichar)'.')
                {
                    *keyPathStorage = [keyPath substringFromIndex:6];
                }
            }
        }
        else if ([@"$self" isEqualToString:keyPath])
        {
            *propertyStorage = self;
            *keyPathStorage = nil;
        }
        else
        {
            *propertyStorage = self;
            *keyPathStorage = keyPath;
        }
    }
    else
    {
        *propertyStorage = self;
        *keyPathStorage = keyPath;
    }
    return result;
}

- (AKAProperty *)propertyAtKeyPath:(NSString *)keyPath
                withChangeObserver:(void (^)(id, id))valueDidChange
{
    AKAProperty* result = nil;

    // TODO: do something more robust for indexed property key paths. This only works in simplest cases:
    if ([keyPath hasPrefix:@"#"])
    {
        // Only supports keypaths of the form #<digits>, without leading or trailing segments.
        // Observation doesn't work either
        NSInteger index = [keyPath substringFromIndex:1].integerValue;
        result = [self propertyAtIndex:index withChangeObserver:valueDidChange];
    }
    else
    {
        AKAProperty* source = nil;
        NSString* effectiveKeyPath = nil;
        if ([self resolveProperty:&source
                       andKeyPath:&effectiveKeyPath
               forExtendedKeyPath:keyPath])
        {
            if (source != nil)
            {
                result = [AKAProperty propertyOfWeakKeyValueTarget:source.value
                                                           keyPath:effectiveKeyPath
                                                    changeObserver:valueDidChange];
                [source addDependentProperty:result];
                [result addDependencyProperty:source];
            }
        }
    }
    return result;
}

- (AKAProperty *)propertyAtIndex:(NSInteger)index
                withChangeObserver:(void (^)(id, id))valueDidChange
{
    AKAProperty* result = nil;

    result = [AKAProperty propertyOfWeakKeyValueTarget:self.value
                                                 index:index
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

- (id)valueWithDefaultTarget:(id)defaultTarget
{
    if (self.target != nil)
    {
        return self.value;
    }
    else
    {
        return [self valueForTarget:defaultTarget];
    }
}

- (id)value
{
    return [self valueForTarget:self.target];
}

- (void)setValue:(id)value
{
    [self setValue:value forTarget:self.target];
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
    AKAErrorAbstractMethodImplementationMissing();
}

- (BOOL)startObservingChanges
{
    AKAErrorAbstractMethodImplementationMissing();
}

- (BOOL)stopObservingChanges
{
    AKAErrorAbstractMethodImplementationMissing();
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
        self.dependencyPropertiesStorage = [NSHashTable weakObjectsHashTable];
    }
    [self.dependencyPropertiesStorage addObject:derived];
}

- (void)addDependentProperty:(AKAProperty*)derived
{
    if (self.dependentPropertiesStorage == nil)
    {
        self.dependentPropertiesStorage = [NSHashTable weakObjectsHashTable];
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

    AKAErrorAbstractMethodImplementationMissing();
}

@end


#pragma mark - AKAKVOProperty (Implementation)
#pragma mark -

@interface AKAKVOProperty()

@property(nonatomic, readonly) void(^changeObserver)();

@end

@implementation AKAKVOProperty

@synthesize keyPath = _keyPath;
@synthesize isObservingChanges = _isObservingChanges;
@synthesize changeObserver = _changeObserver;

#pragma mark - Initialization

- (instancetype)initWithWeakTarget:(NSObject*)target
                changeObserver:(void(^)(id oldValue, id newValue))valueDidChange
{
    return [self initWithWeakTarget:target keyPath:nil changeObserver:valueDidChange];
}

- (instancetype)initWithWeakTarget:(NSObject*)target
                       keyPath:(NSString *)keyPath
                changeObserver:(void(^)(id oldValue, id newValue))valueDidChange
{
    self = [super initWithWeakTarget:target];
    if (self)
    {
        _keyPath = keyPath;
        _isObservingChanges = NO;
        _changeObserver = valueDidChange;
    }
    return self;
}

#pragma mark - Value Access

- (void)setValue:(id)value
{
    if (self.keyPath.length > 0)
    {
        [super setValue:value];
    }
    else
    {
        id oldValue = self.target;
        self.target = value;
        if (self.isObservingChanges && self.changeObserver)
        {
            self.changeObserver(oldValue, value);
        }
    }
}

- (id)valueForTarget:(id)target
{
    return self.keyPath.length > 0 ? [target valueForKeyPath:self.keyPath] : target;
}

- (void)setValue:(id)value forTarget:(id)target
{
    [target setValue:value forKeyPath:self.keyPath];
}

#pragma mark - Validation

- (BOOL)    validateValue:(inout __autoreleasing id *)ioValue
                    error:(out NSError *__autoreleasing *)outError
{
    BOOL result = YES;
    id target = self.target;
    if (self.keyPath.length > 0)
    {
        result = [target validateValue:ioValue
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
    id target = self.target;

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
            [target addObserver:self
                     forKeyPath:self.keyPath
                        options:(NSKeyValueObservingOptions)(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
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
        if (self.keyPath.length == 0)
        {
            _isObservingChanges = NO;
        }
        else
        {
            // make sure self.target is not deallocated while we
            // remove the observer
            __strong id target = self.target;
            if (target != nil)
            {
                [target removeObserver:self
                            forKeyPath:self.keyPath
                               context:(__bridge void *)(self)];
            }
            _isObservingChanges = NO;
        }
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
    __strong id target = self.target;
    BOOL wasObservingChanges = self.isObservingChanges;
    if (target == oldValue || target == nil)
    {
        [self stopObservingChanges];
        id myOldValue = self.value;
        self.target = newValue;
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

/////
#pragma mark - AKAIndexedProperty (Implementation)
#pragma mark -

@interface AKAIndexedProperty()

@property(nonatomic, readonly) void(^changeObserver)();

@end

@implementation AKAIndexedProperty

@synthesize index = _index;
@synthesize isObservingChanges = _isObservingChanges;
@synthesize changeObserver = _changeObserver;

#pragma mark - Initialization

- (instancetype)initWithWeakTarget:(NSObject*)target
                             index:(NSInteger)index
                    changeObserver:(void(^)(id oldValue, id newValue))valueDidChange
{
    self = [super initWithWeakTarget:target];
    if (self)
    {
        _index = index;
        _isObservingChanges = NO;
        _changeObserver = valueDidChange;
    }
    return self;
}

#pragma mark - Value Access

- (NSArray*)targetAsArray:(id)target
{
    NSArray* array = nil;
    if ([target isKindOfClass:[NSSet class]])
    {
        array = [((NSSet*)target) allObjects];
    }
    else if ([target isKindOfClass:[NSArray class]])
    {
        array = target;
    }
    return array;
}

- (NSMutableArray*)targetAsMutableArray:(id)target
{
    NSMutableArray* array = nil;
    if ([target isKindOfClass:[NSMutableArray class]])
    {
        array = target;
    }
    return array;
}

- (void)setValue:(id)value
{
    [self setValue:value forTarget:self.target];
}

- (id)valueForTarget:(id)target
{
    NSAssert(self.index >= 0, @"Invalid index %ld", (long)self.index);
    return [self targetAsArray:target][(NSUInteger)self.index];
}

- (void)setValue:(id)value forTarget:(id)target
{
    [self targetAsMutableArray:target][self.index] = value;
}

#pragma mark - Validation

#pragma mark - Notifications

- (BOOL)isObservingChanges
{
    return _isObservingChanges;
}

- (BOOL)startObservingChanges
{
    return NO;
}

- (BOOL)stopObservingChanges
{
    return !self.isObservingChanges;
}

#pragma mark - Dependent Properties

- (void)dependencyDidChangeValueFrom:(id)oldValue to:(id)newValue
{
    __strong id target = self.target;
    BOOL wasObservingChanges = self.isObservingChanges;
    if (target == oldValue || target == nil)
    {
        [self stopObservingChanges];
        id myOldValue = self.value;
        self.target = newValue;
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

#pragma mark - AKACustomProperty (Implementation)
#pragma mark -

@interface AKACustomProperty()

@property (nonatomic, strong) id(^getter)(id target);
@property (nonatomic, strong) void(^setter)(id target, id value);
@property (nonatomic, strong) BOOL(^observationStarter)(id target);
@property (nonatomic, strong) BOOL(^observationStopper)(id target);

@end

@implementation AKACustomProperty

@synthesize isObservingChanges = _isObservingChanges;

#pragma mark - Initialization

- (instancetype)initWithWeakTarget:(id)target
                            getter:(id (^)(id target))getter
                            setter:(void (^)(id target, id value))setter
                observationStarter:(BOOL(^)(id target))observationStarter
                observationStopper:(BOOL (^)(id target))observationStopper
{
    self = [super initWithWeakTarget:target];
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
    return self.getter(self.target);
}

- (void)setValue:(id)value
{
    self.setter(self.target, value);
}

#pragma mark - Notifications

- (BOOL)startObservingChanges
{
    BOOL result = self.isObservingChanges;
    if (!result && self.observationStarter)
    {
        result = self.observationStarter(self.target);
    }
    return result;
}

- (BOOL)stopObservingChanges
{
    BOOL result = !self.isObservingChanges;
    if (!result)
    {
        result = self.observationStopper(self.target);
    }
    return result;
}

- (void)notifyPropertyValueDidChangeFrom:(id)oldValue to:(id)newValue
{
    [self notifyDependenciesValueDidChangeFrom:(id)oldValue to:(id)newValue];
}


@end