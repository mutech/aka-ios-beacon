//
//  NetworkActivityViewController.m
//  AKABeaconDemo
//
//  Created by Michael Utech on 24/09/2016.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKABeacon;

#import <stdlib.h>

#import "NetworkActivityViewController.h"


@interface AKATimerOperation: AKAOperation

@property(nonatomic, readonly) NSTimeInterval delay;
@property(nonatomic, readonly) NSTimeInterval duration;

- (instancetype)    initWithDelay:(NSTimeInterval)delay
                         duration:(NSTimeInterval)duration NS_DESIGNATED_INITIALIZER;

- (instancetype) initWithDuration:(NSTimeInterval)duration;

- (instancetype)    initWithDelay:(NSTimeInterval)delay;

@end

@implementation AKATimerOperation

- (instancetype)initWithDelay:(NSTimeInterval)delay
                     duration:(NSTimeInterval)duration
{
    if (self = [super init])
    {
        _delay = delay;
        _duration = duration;

        if (_delay > 0.0 && !isnan(_delay))
        {
            [AKADelayedOperationCondition delayOperation:self withDuration:delay];
        }
    }
    return self;
}

- (instancetype)init
{
    return [self initWithDelay:0.0 duration:0.0];
}

- (instancetype)initWithDuration:(NSTimeInterval)duration
{
    return [self initWithDelay:0.0 duration:duration];
}

- (instancetype)initWithDelay:(NSTimeInterval)delay
{
    return [self initWithDelay:delay duration:0.0];
}

- (void)execute
{
    if (self.duration > 0 && !isnan(self.duration))
    {
        NSTimer* timer = [NSTimer timerWithTimeInterval:self.duration
                                                repeats:NO
                                                  block:
                          ^(NSTimer * _Nonnull __unused timer)
                          {
                              [self finish];
                          }];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    }
    else
    {
        [self finish];
    }
}

@end

@interface NetworkOperation: AKATimerOperation

@property(nonatomic, readonly) UIColor* statusColor;

@end

@implementation NetworkOperation

- (UIColor *)statusColor
{
    if (self.isFinished)
    {
        return [UIColor greenColor];
    }
    else if (self.isExecuting)
    {
        return [UIColor blueColor];
    }
    else if (self.isReady)
    {
        return [UIColor yellowColor];
    }
    else
    {
        return [UIColor lightGrayColor];
    }
}

+ (NSSet *)keyPathsForValuesAffectingStatusColor
{
    return [NSSet setWithObjects:@"isExecuting", @"isReady", @"isFinished", nil];
}

@end



@interface NetworkActivityViewController () <AKABindingBehaviorDelegate>

@property(nonatomic, readonly) AKAOperationQueue* queue;
@property(nonatomic) NSArray* items;
@property(nonatomic) NSUInteger serial;
@property(nonatomic) BOOL updateOperationsScheduled;

@end

@implementation NetworkActivityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _queue = [AKAOperationQueue new];
    self.queue.maxConcurrentOperationCount = 20;

    [AKABindingBehavior addToViewController:self];

    self.baseDelay = 2.0;
    self.baseDuration = 1.0;
    self.randomFactor = 0.2;
    self.operations = 3;

    self.serial = 0;

    self.updateOperationsScheduled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self scheduleUpdateOperations];
}

- (void)setBaseDelay:(NSTimeInterval)baseDelay
{
    _baseDelay = round(1000 * baseDelay) / 1000;
}

- (void)setBaseDuration:(NSTimeInterval)baseDuration
{
    _baseDuration = round(1000 * baseDuration) / 1000;
}

- (CGFloat)randomNumber
{
    static uint32_t randomRange = 1000000000;

    CGFloat result = ((CGFloat)arc4random_uniform(randomRange)) / randomRange;

    return result;
}

- (void)scheduleUpdateOperations
{
    if (!self.updateOperationsScheduled)
    {
        self.updateOperationsScheduled = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateOperations];
        });
    }
}

- (void)updateOperations
{
    NSMutableArray* items = [NSMutableArray new];

    NSUInteger activeOperations = 0;
    for (id item in self.items)
    {
        if ([item isKindOfClass:[AKAOperation class]])
        {
            AKAOperation* operation = item;
            if (!operation.finished)
            {
                ++activeOperations;
                [items addObject:operation];
            }
        }
        else
        {
            [items addObject:item];
        }
    }

    for (NSUInteger i=activeOperations; i < self.operations; ++i)
    {
        [self addNewOperationToArray:items];
    }

    self.items = items;

    self.updateOperationsScheduled = NO;
}

- (void)addNewOperationToArray:(NSMutableArray*)array
{
    CGFloat randomDelay = self.baseDelay + (([self randomNumber] - 0.5)
                                            * self.baseDelay
                                            * 0.7);
    CGFloat randomDuration = self.baseDuration + ([self randomNumber]
                                                  * self.baseDuration
                                                  * 0.3);

    NetworkOperation* operation = [[NetworkOperation alloc] initWithDelay:randomDelay
                                                                 duration:randomDuration];
    operation.name = [NSString stringWithFormat:@"Operation #%lu", (unsigned long)++self.serial];

    [array addObject:operation];
    __weak NetworkActivityViewController* weakSelf = self;
    [operation addObserver:[[AKABlockOperationObserver alloc] initWithDidStartBlock:nil
                                                           didProduceOperationBlock:nil
                                                                     didFinishBlock:
                            ^(AKAOperation* op __unused, NSArray<NSError*>* errors)
                            {
                                [weakSelf scheduleUpdateOperations];
                            }]];
    [AKANetworkOperationObserver showNetworkActivityIndicatorWhileOperationIsRunning:operation];
    [operation addToOperationQueue:self.queue];
}

- (void)controller:(AKABindingController *)controller binding:(AKABinding *)binding sourceValueDidChangeFromOldValue:(id)oldSourceValue to:(id)newSourceValue
{
    NSLog(@"data context=%@ - target=%@ - value change: %@ -> %@", controller.dataContext, NSStringFromClass([binding.target class]), oldSourceValue, newSourceValue);

}

- (void)_controller:(AKABindingController *)controller binding:(AKABinding *)binding didUpdateTargetValue:(id)oldTargetValue to:(id)newTargetValue forSourceValue:(id)oldSourceValue changeTo:(id)newSourceValue
{
    NSLog(@"data context=%@ - target=%@ - value change: %@ -> %@ (%@ -> %@)", controller.dataContext, NSStringFromClass([binding.target class]), oldTargetValue, newTargetValue, oldSourceValue, newSourceValue);
}

@end
