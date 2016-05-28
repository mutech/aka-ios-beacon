//
//  AKABindingController+KeyboardActivationSequence.m
//  AKABeacon
//
//  Created by Michael Utech on 25.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingController+KeyboardActivationSequence.h"
#import "AKABindingController_KeyboardActivationSequenceProperties.h"


#pragma mark - AKABindingController(KeyboardActivationSequence) - Implementation
#pragma mark -

@implementation AKABindingController(KeyboardActivationSequence)

- (void)initializeKeyboardActivationSequence
{
    if (!self.keyboardActivationSequenceStorage)
    {
        // NOTE: we might want to support local sequences for child controllers. If so, just remove if(self.parent) path.
        if (self.parent)
        {
            [self.parent initializeKeyboardActivationSequence];
        }
        else
        {
            self.keyboardActivationSequenceStorage = [AKAKeyboardActivationSequence new];
            self.keyboardActivationSequenceStorage.delegate = self;
            [self.keyboardActivationSequence update];
        }
    }
    else
    {
        [self.keyboardActivationSequence update];
    }
}

- (AKAKeyboardActivationSequence *)keyboardActivationSequence
{
    AKAKeyboardActivationSequence* result = self.keyboardActivationSequenceStorage;

    if (result == nil)
    {
        if (self.parent)
        {
            result = self.parent.keyboardActivationSequence;
        }
    }

    return result;
}

- (void)enumerateItemsInKeyboardActivationSequenceUsingBlock:(void (^)(req_AKAKeyboardActivationSequenceItem, NSUInteger, outreq_BOOL))block
{
    NSMutableArray<id<AKAKeyboardActivationSequenceItemProtocol>>* items = [NSMutableArray new];

    [self enumerateBindingsUsingBlock:^(AKABinding * _Nonnull binding, BOOL * _Nonnull stop) {
        if ([binding conformsToProtocol:@protocol(AKAKeyboardActivationSequenceItemProtocol)])
        {
            id<AKAKeyboardActivationSequenceItemProtocol> item = (id)binding;
            if ([item shouldParticipateInKeyboardActivationSequence])
            {
                [items addObject:item];
            }
        }
    }];

    [self enumerateBindingControllersUsingBlock:
     ^(AKABindingController *controller, BOOL * _Nonnull outerStop)
     {
         [controller enumerateBindingsUsingBlock:^(AKABinding * _Nonnull binding, BOOL * _Nonnull stop) {
             if ([binding conformsToProtocol:@protocol(AKAKeyboardActivationSequenceItemProtocol)])
             {
                 id<AKAKeyboardActivationSequenceItemProtocol> item = (id)binding;
                 if ([item shouldParticipateInKeyboardActivationSequence])
                 {
                     [items addObject:item];
                 }
             }
         }];
     }];

    [items sortUsingComparator:
     ^NSComparisonResult(id<AKAKeyboardActivationSequenceItemProtocol> _Nonnull obj1,
                         id<AKAKeyboardActivationSequenceItemProtocol> _Nonnull obj2)
     {
         NSComparisonResult result = NSOrderedSame;

         UIResponder* r1 = [obj1 responderForKeyboardActivationSequence];
         UIResponder* r2 = [obj2 responderForKeyboardActivationSequence];

         if (![r1 isKindOfClass:[UIView class]])
         {
             result = NSOrderedAscending;
         }
         else if (![r2 isKindOfClass:[UIView class]])
         {
             result = NSOrderedDescending;
         }
         else
         {
             UIView* v1 = (id)r1;
             UIView* v2 = (id)r2;

             CGRect r1 = [v1 convertRect:v1.frame toView:self.view];
             CGRect r2 = [v2 convertRect:v2.frame toView:self.view];

             if (r1.origin.y < r2.origin.y)
             {
                 result = NSOrderedAscending;
             }
             else if (r1.origin.y > r2.origin.y)
             {
                 result = NSOrderedDescending;
             }

             if (result == NSOrderedSame)
             {
                 if (r1.origin.x < r2.origin.x)
                 {
                     result = NSOrderedAscending;
                 }
                 else if (r1.origin.x > r2.origin.x)
                 {
                     result = NSOrderedDescending;
                 }
             }
         }

         return result;
     }];

    for (NSUInteger i=0; i < items.count; ++i)
    {
        BOOL stop = NO;
        block(items[i], i, &stop);
        if (stop)
        {
            break;
        }
    }
}

@end
