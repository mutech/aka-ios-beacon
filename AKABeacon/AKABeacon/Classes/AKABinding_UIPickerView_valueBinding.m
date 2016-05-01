//
//  AKABinding_UIPickerView_valueBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 24.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.NSObject_AKAConcurrencyTools;

#import "AKABinding_UIPickerView_valueBinding.h"

@interface AKABinding_UIPickerView_valueBinding() <UIPickerViewDelegate, UIPickerViewDataSource>

@property(nonatomic, readonly)       UIPickerView*             pickerView;
@property(nonatomic, readonly)       NSArray*                  choices;
@property(nonatomic, readonly)       AKAProperty*              choicesProperty;
@property(nonatomic, readonly)       AKAUnboundProperty*       titleProperty;
@property(nonatomic)                 NSInteger                 previouslySelectedRow;

@end

@implementation AKABinding_UIPickerView_valueBinding

+ (AKABindingSpecification *)                   specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":              [AKABinding_UIPickerView_valueBinding class],
           @"targetType":               [UIPickerView class],
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

- (void)                                    validateTargetView:(req_UIView)targetView
{
    (void)targetView;
    NSParameterAssert([targetView isKindOfClass:[UIPickerView class]]);
}

- (req_AKAProperty)         createBindingTargetPropertyForView:(req_UIView)view
{
    NSParameterAssert(view == nil || [view isKindOfClass:[UIPickerView class]]);
    (void)view;

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                id result;
                AKABinding_UIPickerView_valueBinding* binding = target;

                NSInteger row = [binding.pickerView selectedRowInComponent:0];
                result = [binding itemForRow:row];

                return result;
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_UIPickerView_valueBinding* binding = target;
                NSInteger row = [binding rowForItem:value];

                if (row != NSNotFound)
                {
                    id currentValue = [binding itemForRow:[binding.pickerView selectedRowInComponent:0]];

                    if (currentValue == nil && currentValue != value)
                    {
                        currentValue = [NSNull null];
                    }

                    if (currentValue != value)
                    {
                        // Only update picker, if the value associated with
                        // the previously selected row is different from the
                        // new value (selections, especially if undefined,
                        // may have the same associated values and in these
                        // cases we don't want to change the selection).
                        [binding.pickerView selectRow:row inComponent:0 animated:YES];
                        binding.previouslySelectedRow = row;
                    }
                }
            }

                          observationStarter:
            ^BOOL (id target)
            {
                AKABinding_UIPickerView_valueBinding* binding = target;

                binding.pickerView.delegate = binding;
                binding.pickerView.dataSource = binding;

                [binding setNeedsReloadChoices];
                [binding reloadChoicesIfNeeded];

                return YES;
            }

                          observationStopper:
            ^BOOL (id target)
            {
                AKABinding_UIPickerView_valueBinding* binding = target;

                binding.pickerView.delegate = nil;
                binding.pickerView.dataSource = nil;
                
                return YES;
            }];
}

#pragma mark - Change Tracking

- (BOOL)startObservingChanges
{
    BOOL result = [super startObservingChanges];

    [self.choicesProperty startObservingChanges];

    return result;
}

- (BOOL)stopObservingChanges
{
    // Use field to prevent lazy creation:
    [_choicesProperty stopObservingChanges];

    BOOL result = [super stopObservingChanges];

    return result;
}

#pragma mark - Properties

- (UIPickerView*)                                  pickerView
{
    UIView* result = self.view;

    NSAssert([result isKindOfClass:[UIPickerView class]], @"Internal inconsistency, expected view %@ to be an instance of UIPickerView", result);
    
    return (UIPickerView*)result;
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

@synthesize choicesProperty = _choicesProperty;
- (AKAProperty*)choicesProperty
{
    if (_choicesProperty == nil)
    {
        id<AKABindingContextProtocol> context = self.bindingContext;

        if (context)
        {
            __weak typeof(self) weakSelf = self;
            _choicesProperty = [self.choicesBindingExpression
                                bindingSourcePropertyInContext:context
                                changeObserer:
                                ^(opt_id oldValue, opt_id newValue)
                                {
                                    (void)oldValue;
                                    (void)newValue;
                                    [weakSelf choicesDidChange];
                                }];
            [_choicesProperty startObservingChanges];
        }
    }

    return _choicesProperty;
}

@synthesize choices = _choices;
- (NSArray*)                                           choices
{
    if (_choices == nil)
    {
        id value = self.choicesProperty.value;

        if ([value isKindOfClass:[NSArray class]])
        {
            _choices = value;
        }
        else if ([value isKindOfClass:[NSSet class]])
        {
            _choices = [((NSSet*)value) allObjects];
        }

        if (_choices != nil)
        {
            [self setNeedsReloadChoices];
            [self reloadChoicesIfNeeded];
        }
    }

    return _choices;
}

- (void)                                      choicesDidChange
{
    [self aka_performBlockInMainThreadOrQueue:^{
        self->_choices = nil;
        [self setNeedsReloadChoices];
    }
                            waitForCompletion:NO];
}

- (void)                                 setNeedsReloadChoices
{
    _needsReloadChoices = YES;
}

- (void)                                 reloadChoicesIfNeeded
{
    if (self.needsReloadChoices)
    {
        [self reloadChoices];
    }
}

- (void)                                         reloadChoices
{
    if (self.pickerView.dataSource == self)
    {
        [self.pickerView reloadAllComponents];
        _needsReloadChoices = NO;
    }
}

- (NSComparisonResult)orderInChoicesForValue:(id)firstValue value:(id)secondValue
{
    NSInteger firstRow = [self rowForItem:firstValue];
    NSInteger secondRow = [self rowForItem:secondValue];

    if (firstRow < secondRow)
    {
        return NSOrderedAscending;
    }
    else if (firstRow > secondRow)
    {
        return NSOrderedDescending;
    }
    else
    {
        return NSOrderedSame;
    }
}

#pragma mark - UIPickerViewDelegate Implementation

- (NSString*)                                      pickerView:(UIPickerView*)pickerView
                                                  titleForRow:(NSInteger)row
                                                 forComponent:(NSInteger)component
{
    (void)pickerView;
    (void)component;
    NSParameterAssert(pickerView == self.pickerView);
    NSAssert(component == 0, @"AKAPickerViewBinding currently only supports single component picker views");

    NSString* result = nil;

    if (row == self.rowForUndefinedValue)
    {
        result = self.titleForUndefinedValue;
    }
    else if (row == self.rowForOtherValue)
    {
        result = self.titleForOtherValue;
    }
    else
    {
        NSInteger index = [self indexForRow:row];

        if (index >= 0 && index < self.choices.count)
        {
            id choice = self.choices[(NSUInteger)index];

            if (self.titleProperty != nil)
            {
                choice = [self.titleProperty valueForTarget:choice];
            }

            if ([choice isKindOfClass:NSString.class])
            {
                result = choice;
            }
            else if ([choice isKindOfClass:NSObject.class])
            {
                result = ((NSObject*)choice).description;
            }
        }
    }

    return result;
}

- (void)                                            pickerView:(UIPickerView*)pickerView
                                                  didSelectRow:(NSInteger)row
                                                   inComponent:(NSInteger)component
{
    (void)pickerView;
    (void)component;
    NSParameterAssert(pickerView == self.pickerView);
    NSParameterAssert(component == 0);

    id value = [self itemForRow:row];
    id oldValue = [self itemForRow:self.previouslySelectedRow];

    [self targetValueDidChangeFromOldValue:oldValue
                                toNewValue:value];

    _previouslySelectedRow = row;
}

#pragma mark - UIPickerViewDataSource Implementation

- (NSInteger)                   numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    (void)pickerView;
    NSParameterAssert(pickerView == self.pickerView);

    return 1;
}

- (NSInteger)                                       pickerView:(UIPickerView*)pickerView
                                       numberOfRowsInComponent:(NSInteger)component
{
    (void)pickerView;
    (void)component;
    NSParameterAssert(pickerView == self.pickerView);
    NSParameterAssert(component == 0);

    NSInteger result = (NSInteger)self.choices.count;

    if (self.supportsUndefinedValue)
    {
        ++result;
    }

    if (self.supportsOtherValue)
    {
        ++result;
    }

    return result;
}

#pragma mark - Implementation

- (BOOL)                                supportsUndefinedValue
{
    return self.titleForUndefinedValue.length > 0;
}

- (NSInteger)                             rowForUndefinedValue
{
    return self.supportsUndefinedValue ? 0 : NSNotFound;
}

- (BOOL)                                    supportsOtherValue
{
    return self.titleForOtherValue.length > 0;
}

- (NSInteger)                                 rowForOtherValue
{
    NSInteger result = self.supportsOtherValue ? (NSInteger)self.choices.count : NSNotFound;

    if (result != NSNotFound && self.supportsUndefinedValue)
    {
        ++result;
    }

    return result;
}

- (NSInteger)                                      indexForRow:(NSInteger)row
{
    NSInteger result = row;
    NSInteger undefinedValueRow = self.rowForUndefinedValue;
    NSInteger otherValueRow = self.rowForOtherValue;

    if (undefinedValueRow != NSNotFound && otherValueRow != NSNotFound)
    {
        NSInteger minSpecial;
        NSInteger maxSpecial;

        if (undefinedValueRow < otherValueRow)
        {
            minSpecial = undefinedValueRow;
            maxSpecial = otherValueRow;
        }
        else
        {
            NSAssert(undefinedValueRow != otherValueRow, @"Undefined and other value use the same row index");
            minSpecial = otherValueRow;
            maxSpecial = undefinedValueRow;
        }

        if (row >= maxSpecial)
        {
            result -= 2;
        }
        else if (row >= minSpecial)
        {
            result -= 1;
        }
    }
    else if (undefinedValueRow != NSNotFound)
    {
        if (row > undefinedValueRow)
        {
            result -= 1;
        }
    }
    else if (otherValueRow != NSNotFound)
    {
        if (row >= otherValueRow)
        {
            result -= 1;
        }
    }

    return result;
}

- (NSInteger)                                      rowForIndex:(NSInteger)index
{
    NSInteger result = index;
    NSInteger undefinedValueRow = self.rowForUndefinedValue;
    NSInteger otherValueRow = self.rowForOtherValue;

    if (undefinedValueRow != NSNotFound && otherValueRow != NSNotFound)
    {
        NSInteger minSpecial;
        NSInteger maxSpecial;

        if (undefinedValueRow < otherValueRow)
        {
            minSpecial = undefinedValueRow;
            maxSpecial = otherValueRow;
        }
        else
        {
            NSAssert(undefinedValueRow != otherValueRow, @"Undefined and other value use the same row index");
            minSpecial = otherValueRow;
            maxSpecial = undefinedValueRow;
        }

        if (index >= minSpecial)
        {
            ++result;
        }

        if (index >= maxSpecial)
        {
            ++result;
        }
    }
    else if (undefinedValueRow != NSNotFound)
    {
        if (index >= undefinedValueRow)
        {
            ++result;
        }
    }
    else if (otherValueRow != NSNotFound)
    {
        if (index >= otherValueRow)
        {
            ++result;
        }
    }

    return result;
}

- (id)                                              itemForRow:(NSInteger)row
{
    id result = nil;
    NSInteger undefinedValueRow = self.rowForUndefinedValue;
    NSInteger otherValueRow = self.rowForOtherValue;

    if (undefinedValueRow != NSNotFound && row == undefinedValueRow)
    {
        return nil;
    }
    else if (otherValueRow != NSNotFound && row == otherValueRow)
    {
        return self.otherValue;
    }
    else
    {
        NSInteger index = [self indexForRow:row];

        if (index >= 0 && index < self.choices.count)
        {
            result = self.choices[(NSUInteger)index];
        }
    }

    return result;
}

- (NSInteger)                                       rowForItem:(id)item
{
    NSInteger result = NSNotFound;
    NSInteger index = (NSInteger)[self.choices indexOfObject:(item == nil ? [NSNull null] : item)];

    if (index == NSNotFound)
    {
        if (self.supportsUndefinedValue && (item == nil || item == [NSNull null]))
        {
            result = self.rowForUndefinedValue;
        }
        else if (self.supportsOtherValue)
        {
            result = self.rowForOtherValue;
        }
    }
    else
    {
        result = [self rowForIndex:index];
    }
    
    return result;
}

@end
