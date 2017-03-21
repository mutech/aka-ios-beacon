//
//  AKABinding_UISegmentedControl_valueBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 20.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "NSObject+AKAConcurrencyTools.h"

#import "AKABinding_UISegmentedControl_valueBinding.h"
#import "AKABinding+DelegateSupport.h"

#import "AKACollectionControlViewBinding.h"
#import "AKABindingErrors.h"
#import "AKAConditionalBindingExpression.h"

#import "AKABinding_UILabel_textBinding.h"

@interface AKABinding_UISegmentedControl_valueBinding() <AKACollectionControlViewBindingDelegate>

@property(nonatomic, readonly)       UISegmentedControl*                segmentedControl;

@property(nonatomic)                 NSArray*                           choices;
@property(nonatomic, readonly)       AKAUnboundProperty*                titleProperty;
@property(nonatomic, readonly)       AKAUnboundProperty*                imageProperty;
@property(nonatomic)                 NSInteger                          previouslySelectedRow;
@property(nonatomic)                 BOOL                               isObserving;

@property(nonatomic)                 BOOL                               shouldUpdateSegments;

@end


@implementation AKABinding_UISegmentedControl_valueBinding

+ (AKABindingSpecification *)                   specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        req_AKABindingSpecification labelBindingSpec = [AKABinding_UILabel_textBinding specification];

        NSDictionary* spec =
        @{ @"bindingType":              [AKABinding_UISegmentedControl_valueBinding class],
           @"targetType":               [UISegmentedControl class],
           @"expressionType":           @(AKABindingExpressionTypeAnyNoArray),
           @"attributes":
               @{ @"choices":
                      @{ @"required":        @NO,
                         @"expressionType":  @(AKABindingExpressionTypeAnyKeyPath|AKABindingExpressionTypeArray),
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                         @"bindingProperty": @"choices"
                         },
                  @"updateSegments":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBooleanConstant),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         @"bindingProperty": @"shouldUpdateSegments"
                         },
                  @"title":
                      @{ @"expressionType":  @(AKABindingExpressionTypeUnqualifiedKeyPath|AKABindingExpressionTypeConditional|AKABindingExpressionTypeStringConstant),
                         @"use":             @(AKABindingAttributeUseAssignExpressionToBindingProperty),
                         @"bindingProperty": @"titleBindingExpression",
                         @"attributes":      labelBindingSpec.bindingSourceSpecification.attributes ? labelBindingSpec.bindingSourceSpecification.attributes : @{},
                         },
                  @"titleForUndefinedValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeString),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         },
                  @"titleForOtherValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeString),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         }
                  }
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[AKAControlViewBinding specification]];
    });

    return result;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.shouldUpdateSegments = YES;
    }
    return self;
}

- (req_AKAProperty)        createTargetValuePropertyForTarget:(req_id)view
                                                        error:(out_NSError __unused)error
{
    NSParameterAssert(view == nil || [view isKindOfClass:[UISegmentedControl class]]);

    UISegmentedControl* segmentedControl = (UISegmentedControl*)view;
    segmentedControl.selectedSegmentIndex = NSNotFound;
    if (self.shouldUpdateSegments)
    {
        [segmentedControl removeAllSegments];
    }

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                AKABinding_UISegmentedControl_valueBinding* binding = target;

                id result = @(binding.segmentedControl.selectedSegmentIndex);

                return result;
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_UISegmentedControl_valueBinding* binding = target;

                NSInteger row = value ? [value integerValue] : NSNotFound;

                if (row != NSNotFound)
                {
                    id currentValue = nil;
                    [binding convertTargetValue:@(binding.segmentedControl.selectedSegmentIndex)
                                  toSourceValue:&currentValue
                                          error:nil];

                    if (currentValue == nil && currentValue != value)
                    {
                        currentValue = [NSNull null];
                    }

                    if (currentValue != value)
                    {
                        // Only update segmented control, if the value associated with
                        // the previously selected segment is different from the
                        // new value (selections, especially if undefined,
                        // may have the same associated values and in these
                        // cases we don't want to change the selection).
                        binding.segmentedControl.selectedSegmentIndex = row;
                        binding.previouslySelectedRow = row;
                    }
                }
            }

                          observationStarter:
            ^BOOL (id target)
            {
                AKABinding_UISegmentedControl_valueBinding* binding = target;

                if (!binding.isObserving)
                {
                    [binding.segmentedControl addTarget:binding
                                                 action:@selector(viewValueDidChange:)
                                       forControlEvents:UIControlEventValueChanged];
                }

                return binding.isObserving;
            }

                          observationStopper:
            ^BOOL (id target)
            {
                AKABinding_UISegmentedControl_valueBinding* binding = target;

                if (binding.isObserving)
                {
                    [binding.segmentedControl removeTarget:binding
                                                    action:@selector(viewValueDidChange:)
                                          forControlEvents:UIControlEventValueChanged];
                }

                return YES;
            }];
}

#pragma mark - Conversion

- (BOOL)                                   convertTargetValue:(opt_id)targetValue
                                                toSourceValue:(out_id)sourceValueStore
                                                        error:(out_NSError)error
{
    BOOL result = YES;
    if (targetValue == nil)
    {
        *sourceValueStore = nil;
    }
    else if ([targetValue isKindOfClass:[NSNumber class]])
    {
        NSInteger index = [targetValue integerValue];
        if (index >= 0 && index < self.choices.count)
        {
            *sourceValueStore = self.choices[(NSUInteger)index];
        }
        else if (index == NSNotFound)
        {
            *sourceValueStore = nil;
        }
        else
        {
            *sourceValueStore = nil;
            [AKABindingErrors bindingErrorConversionOfBinding:self targetValue:targetValue failedWithRangeError:NSMakeRange(0, self.choices.count)];
        }
    }
    else
    {
        result = NO;
        if (error)
        {
            *error = [AKABindingErrors bindingErrorConversionOfBinding:self
                                                           targetValue:targetValue
                                         failedWithInvalidTypeExpected:[NSNumber class]];

        }
    }
    return result;
}

- (BOOL)                                   convertSourceValue:(opt_id)sourceValue
                                                toTargetValue:(out_id)targetValueStore
                                                        error:(out_NSError)error
{
    (void)error;

    BOOL result = YES;
    if (sourceValue == nil)
    {
        *targetValueStore = nil;
    }
    else
    {
        NSUInteger index = [self.choices indexOfObject:(req_id)sourceValue];

        *targetValueStore = index == NSNotFound ? nil : @((NSInteger)index);
    }
    return result;
}

#pragma mark - Change Tracking

- (BOOL)                                startObservingChanges
{
    BOOL result = [super startObservingChanges];

    return result;
}

- (BOOL)                                 stopObservingChanges
{
    BOOL result = [super stopObservingChanges];

    return result;
}

- (IBAction)                               viewValueDidChange:(id)sender
{
    (void)sender;

    NSInteger row = self.segmentedControl.selectedSegmentIndex;

    [self targetValueDidChangeFromOldValue:@(self.previouslySelectedRow)
                                toNewValue:@(row)];

    _previouslySelectedRow = row;
}

#pragma mark - Properties

- (UISegmentedControl *)                     segmentedControl
{
    UIView* result = self.target;

    NSAssert([result isKindOfClass:[UISegmentedControl class]], @"Internal inconsistency, expected view %@ to be an instance of UISegmentedControl", result);

    return (UISegmentedControl*)result;
}

@synthesize titleProperty = _titleProperty;
- (AKAUnboundProperty*)                         titleProperty
{
    if (_titleProperty == nil && self.titleBindingExpression != nil)
    {
        id<AKABindingContextProtocol> context = self.bindingContext;

        if (context != nil)
        {
            _titleProperty = [self.titleBindingExpression bindingSourceUnboundPropertyInContext:context];
        }
    }

    return _titleProperty;
}

@synthesize imageProperty = _imageProperty;
- (AKAUnboundProperty*)                         imageProperty
{
    if (_imageProperty == nil && self.imageBindingExpression != nil)
    {
        id<AKABindingContextProtocol> context = self.bindingContext;

        if (context != nil)
        {
            _imageProperty = [self.imageBindingExpression bindingSourceUnboundPropertyInContext:context];
        }
    }

    return _imageProperty;
}

#pragma mark - Titles and Images

- (NSString*)                                    titleForItem:(id)item
                                                  withDefault:(id)defaultValue
{
    AKAUnboundProperty* titleProperty = self.titleProperty;
    id title; // = [self.titleProperty valueForTarget:item];
    if (titleProperty == nil && [self.titleBindingExpression isKindOfClass:[AKAConditionalBindingExpression class]])
    {
        AKABindingController* controller =
            [AKABindingController bindingControllerForViewController:nil
                                                     withDataContext:item
                                                            delegate:nil
                                                               error:nil];
        title = [self.titleBindingExpression evaluateInBindingContext:controller error:nil];
    }
    else
    {
        title = [self.titleProperty valueForTarget:item];

    }
    
    if (title == nil)
    {
        title = defaultValue;
    }
    if (title != nil && ![title isKindOfClass:[NSString class]])
    {
        title = [NSString stringWithFormat:@"%@", title];
    }
    return title;
}

- (UIImage*)                                     imageForItem:(id)item
{
    id image = [self.imageProperty valueForTarget:item];
    if (image != nil && ![image isKindOfClass:[UIImage class]])
    {
        if ([image isKindOfClass:[NSString class]])
        {
            image = [UIImage imageNamed:(NSString*)image];
        }
        else if ([image isKindOfClass:[NSData class]])
        {
            image = [UIImage imageWithData:(NSData*)image];
        }
        else
        {
            // TODO: do something when we can't use the value as image
            image = nil;
        }
    }
    return image;
}

#pragma mark - AKABindingDelegate

- (BOOL)          shouldReceiveDelegateMessagesForSubBindings
{
    return YES;
}

- (BOOL)shouldReceiveDelegateMessagesForTransitiveSubBindings
{
    return YES;
}

- (void)                                              binding:(req_AKABinding)binding
                                         didUpdateTargetValue:(opt_id)oldTargetValue
                                                           to:(opt_id)newTargetValue
                                               forSourceValue:(opt_id __unused)oldSourceValue
                                                     changeTo:(opt_id __unused)newSourceValue
{
    if (self.shouldUpdateSegments) // TODO: check binding applies
    {
        // TODO: This should be implemented as AKACollectionProperty or AKACollectionBinding or something else which is reusable, review later
        NSArray* items = nil;
        if ([newTargetValue isKindOfClass:[NSSet class]])
        {
            items = [((NSSet*)newTargetValue) allObjects];
        }
        else if ([newTargetValue isKindOfClass:[NSArray class]])
        {
            items = newTargetValue;
        }
        if (items == nil)
        {
            items = @[];
        }

        NSArray* actualItems = nil;
        if ([oldTargetValue isKindOfClass:[NSSet class]])
        {
            actualItems = [((NSSet*)oldTargetValue) allObjects];
        }
        else if ([oldTargetValue isKindOfClass:[NSArray class]])
        {
            actualItems = oldTargetValue;
        }
        if (actualItems == nil)
        {
            actualItems = @[];
        }

        [self binding:binding sourceControllerWillChangeContent:self.sourceValueProperty];

        NSInteger placeholderContentSection = 0;

        // Remove items no longer in new items collection
        NSMutableArray* oldItems = nil;

        if (actualItems.count > 0)
        {
            oldItems = [NSMutableArray arrayWithArray:actualItems];
            for (NSInteger i = (NSInteger)oldItems.count - 1; i >= 0; --i)
            {
                id oldItem = oldItems[(NSUInteger)i];

                if ([items indexOfObject:oldItem] == NSNotFound)
                {
                    [oldItems removeObjectAtIndex:(NSUInteger)i];

                    NSIndexPath* oldItemIndexPath = [NSIndexPath indexPathForRow:i
                                                                       inSection:placeholderContentSection];
                    [self binding:binding sourceController:self.sourceValueProperty
                      deletedItem:oldItem
                      atIndexPath:oldItemIndexPath];
                }
            }
        }
        else
        {
            oldItems = NSMutableArray.new;
        }

        // Process insertions and movements
        NSUInteger insertedItemCount = 0;

        for (NSInteger i = 0; i < ((NSArray*)items).count; ++i)
        {
            id item = ((NSArray*)items)[(NSUInteger)i];
            NSUInteger oldIndex = [oldItems indexOfObject:item];

            NSIndexPath* itemIndexPath = [NSIndexPath indexPathForRow:i
                                                            inSection:placeholderContentSection];
            // TODO: consider manipulating oldItems to match changes
            if (oldIndex == NSNotFound)
            {
                [self binding:binding sourceController:self.sourceValueProperty
                 insertedItem:item
                  atIndexPath:itemIndexPath];
                ++insertedItemCount;
            }
            else if (oldIndex + insertedItemCount != i)
            {
                NSAssert(oldIndex + insertedItemCount > i, @"");

                [oldItems removeObjectAtIndex:oldIndex];

                NSIndexPath* itemOldIndexPath =
                [NSIndexPath indexPathForRow:(NSInteger)(oldIndex + insertedItemCount)
                                   inSection:placeholderContentSection];

                [self binding:binding sourceController:self.sourceValueProperty
                    movedItem:item
                fromIndexPath:itemOldIndexPath
                  toIndexPath:itemIndexPath];
                ++insertedItemCount;
            }
            else
            {
                /*
                [self binding:binding sourceController:self.sourceValueProperty
                  updatedItem:items[(NSUInteger)itemIndexPath.row]
                  atIndexPath:itemIndexPath];
                 */
            }
        }
        
        [self binding:binding sourceControllerDidChangeContent:self.sourceValueProperty];
    }
}

- (void)                                              binding:(req_AKACollectionControlViewBinding)binding
                            sourceControllerWillChangeContent:(id)sourceDataController
{
    (void)binding;
    (void)sourceDataController;

    [UIView beginAnimations:nil context:nil];
}

- (void)                                              binding:(req_AKACollectionControlViewBinding)binding
                                             sourceController:(id)sourceDataController
                                                 insertedItem:(id)sourceCollectionItem
                                                  atIndexPath:(NSIndexPath *)indexPath
{
    (void)binding;
    (void)sourceDataController;

    id context = sourceCollectionItem;

    id image = [self imageForItem:context];
    id title = [self titleForItem:context withDefault:image ? nil : context];

    if ([image isKindOfClass:[UIImage class]] && (![title length] || !self.preferTitleOverImage))
    {
        [self.segmentedControl insertSegmentWithImage:(UIImage*)image
                                              atIndex:(NSUInteger)indexPath.row
                                             animated:YES];
    }
    else
    {
        [self.segmentedControl insertSegmentWithTitle:title
                                              atIndex:(NSUInteger)indexPath.row
                                             animated:YES];
    }
}

- (void)                                              binding:(req_AKACollectionControlViewBinding __unused)binding
                                             sourceController:(id __unused)sourceDataController
                                                  deletedItem:(id __unused)sourceCollectionItem
                                                  atIndexPath:(NSIndexPath *)indexPath
{
    [self.segmentedControl removeSegmentAtIndex:(NSUInteger)indexPath.row animated:YES];
}

- (void)                                              binding:(req_AKACollectionControlViewBinding __unused)binding
                                             sourceController:(id __unused)sourceDataController
                                                  updatedItem:(id)sourceCollectionItem
                                                  atIndexPath:(NSIndexPath *)indexPath
{
    id context = sourceCollectionItem;

    id image = [self imageForItem:context];
    id title = [self titleForItem:context withDefault:image ? nil : context];

    if ([image isKindOfClass:[UIImage class]] && (![title length] || !self.preferTitleOverImage))
    {
        [self.segmentedControl setImage:image forSegmentAtIndex:(NSUInteger)indexPath.row];
    }
    else
    {
        [self.segmentedControl setTitle:title forSegmentAtIndex:(NSUInteger)indexPath.row];
    }
}

- (void)                                              binding:(req_AKACollectionControlViewBinding __unused)binding
                                             sourceController:(id __unused)sourceDataController
                                                    movedItem:(id)sourceCollectionItem
                                                fromIndexPath:(NSIndexPath *)fromIndexPath
                                                  toIndexPath:(NSIndexPath *)toIndexPath
{
    NSUInteger fromIndex = (NSUInteger)fromIndexPath.row;
    NSUInteger toIndex = (NSUInteger)toIndexPath.row;
    if (toIndex > fromIndex)
    {
        --toIndex;
    }

    id context = sourceCollectionItem;

    id title = [self.titleProperty valueForTarget:context];
    if (title != nil && ![title isKindOfClass:[NSString class]])
    {
        title = [NSString stringWithFormat:@"%@", title];
    }

    id image = [self.imageProperty valueForTarget:context];
    if (image != nil && ![image isKindOfClass:[UIImage class]])
    {
        if ([image isKindOfClass:[NSString class]])
        {
            image = [UIImage imageNamed:(NSString*)image];
        }
        else if ([image isKindOfClass:[NSData class]])
        {
            image = [UIImage imageWithData:(NSData*)image];
        }
        else
        {
            // TODO: something when we can't use the value as image
            image = nil;
        }
    }

    [self.segmentedControl removeSegmentAtIndex:fromIndex animated:YES];
    if ([image isKindOfClass:[UIImage class]] && (![title length] || !self.preferTitleOverImage))
    {
        [self.segmentedControl insertSegmentWithImage:(UIImage*)image
                                              atIndex:toIndex
                                             animated:YES];
    }
    else
    {
        [self.segmentedControl insertSegmentWithTitle:title
                                              atIndex:toIndex
                                             animated:YES];
    }
}

- (void)                                              binding:(req_AKACollectionControlViewBinding __unused)binding
                             sourceControllerDidChangeContent:(id __unused)sourceDataController
{
    [UIView commitAnimations];
    [self updateTargetValue];
}

@end
