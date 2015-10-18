//
//  AKABinding_AKAPickerKeyboardTriggerView_pickerBinding.m
//  AKAControls
//
//  Created by Michael Utech on 04.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.NSObject_AKAConcurrencyTools;

#import "AKABinding_AKAPickerKeyboardTriggerView_pickerBinding.h"
#import "AKAPickerKeyboardTriggerView.h"
#import "AKAKeyboardActivationSequenceAccessoryView.h"


#pragma mark - AKABinding_AKAPickerKeyboardTriggerView_pickerBinding - Private Interface
#pragma mark -

@interface AKABinding_AKAPickerKeyboardTriggerView_pickerBinding() <
    AKACustomKeyboardResponderDelegate,
    UIPickerViewDelegate,
    UIPickerViewDataSource
>

@property(nonatomic, readonly, weak) AKAPickerKeyboardTriggerView*          triggerView;
@property(nonatomic, readonly)       UIPickerView*                          pickerView;

@property(nonatomic, readonly, weak) id<AKABindingContextProtocol>          bindingContext;

@property(nonatomic, readonly)       NSArray*                               choices;
@property(nonatomic, readonly)       AKAUnboundProperty*                    titleProperty;

@property(nonatomic)                 NSInteger                              originallySelectedRow;
@property(nonatomic)                 NSInteger                              previouslySelectedRow;

@end


#pragma mark - AKABinding_AKAPickerKeyboardTriggerView_pickerBinding - Implementation
#pragma mark -

@implementation AKABinding_AKAPickerKeyboardTriggerView_pickerBinding

#pragma mark - Initialization

- (instancetype)                                  initWithView:(AKAPickerKeyboardTriggerView* _Nonnull)triggerView
                                                    expression:(req_AKABindingExpression)bindingExpression
                                                       context:(req_AKABindingContext)bindingContext
                                                      delegate:(opt_AKABindingDelegate)delegate
{
    if (self = [super initWithView:triggerView
                        expression:bindingExpression
                           context:bindingContext
                          delegate:delegate])
    {
        _bindingContext = bindingContext;
    }
    return self;
}

- (void)                                    validateTargetView:(req_UIView)targetView
{
    NSParameterAssert([targetView isKindOfClass:[AKAPickerKeyboardTriggerView class]]);
}

- (req_AKAProperty)         createBindingTargetPropertyForView:(req_UIView)view
{
    NSParameterAssert(view == nil || [view isKindOfClass:[AKAPickerKeyboardTriggerView class]]);
    (void)view;

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                id result;
                AKABinding_AKAPickerKeyboardTriggerView_pickerBinding* binding = target;
                NSUInteger row = [binding.pickerView selectedRowInComponent:0];
                result = [binding itemForRow:row];
                return result;
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_AKAPickerKeyboardTriggerView_pickerBinding* binding = target;
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
                        // new value (selections, especially undefined and
                        // may have the same associated values and in these
                        // cases we don't want to change the selection).
                        [binding.pickerView selectRow:row inComponent:0 animated:YES];
                        binding.originallySelectedRow = row;
                        binding.previouslySelectedRow = row;
                    }
                }
            }
                          observationStarter:
            ^BOOL (id target)
            {
                AKABinding_AKAPickerKeyboardTriggerView_pickerBinding* binding = target;
                [binding attachToCustomKeyboardResponderView];
                binding.pickerView.delegate = binding;
                binding.pickerView.dataSource = binding;
                [binding setNeedsReloadChoices];
                [binding reloadChoicesIfNeeded];
                return YES;
            }
                          observationStopper:
            ^BOOL (id target)
            {
                AKABinding_AKAPickerKeyboardTriggerView_pickerBinding* binding = target;
                binding.pickerView.delegate = nil;
                binding.pickerView.dataSource = nil;
                [binding detachFromCustomKeyboardResponderView];
                return YES;
            }];
}

#pragma mark - Properties

- (AKAPickerKeyboardTriggerView *)                 triggerView
{
    UIView* result = super.triggerView;
    NSParameterAssert(result == nil || [result isKindOfClass:[AKAPickerKeyboardTriggerView class]]);

    return (AKAPickerKeyboardTriggerView*)result;
}

@synthesize pickerView = _pickerView;
- (UIPickerView *)                                  pickerView
{
    if (_pickerView == nil)
    {
        UIView* inputView = [super inputViewForCustomKeyboardResponderView:self.triggerView];
        if ([inputView isKindOfClass:[UIPickerView class]])
        {
            _pickerView = (UIPickerView*)inputView;
        }
        else
        {
            NSAssert(inputView == nil, @"Binding %@ conflicts with delegate defined for view %@: the input view %@ provided by the original delegate is not an instance of UIPickerView.", self, self.triggerView, inputView);

            _pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
            _pickerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        }
    }
    return _pickerView;
}

#pragma mark - AKACustomKeyboardResponderDelegate Implementation

- (UIView *)           inputViewForCustomKeyboardResponderView:(AKACustomKeyboardResponderView *)view
{
    // The view returned by the super class implementation, if defined and valid, is used by
    // self.pickerView if possible.
    return self.pickerView;
}

#pragma mark -

- (void)responderWillActivate:(req_UIResponder)responder
{
    [super responderWillActivate:responder];

    self.originallySelectedRow = [self rowForItem:self.bindingSource.value];
}

- (void)responderDidDeactivate:(req_UIResponder)responder
{
    if (!self.liveModelUpdates)
    {
        NSInteger row = [self.pickerView selectedRowInComponent:0];
        if (row != self.originallySelectedRow)
        {
            id value = [self itemForRow:row];
            id oldValue = [self itemForRow:self.previouslySelectedRow];
            __weak AKABinding_AKAPickerKeyboardTriggerView_pickerBinding* weakSelf = self;
            [self animateTriggerForSelectedRow:self.originallySelectedRow changeTo:row animations:
             ^{
                 [weakSelf targetValueDidChangeFromOldValue:oldValue toNewValue:value];
             }];
        }
    }

    [super responderDidDeactivate:responder];
}

#pragma mark - Title

@synthesize titleProperty = _titleProperty;
- (AKAUnboundProperty *)                         titleProperty
{
    if (_titleProperty == nil && self.titleBindingExpression != nil)
    {
        _titleProperty = [self.titleBindingExpression bindingSourceUnboundPropertyInContext:self.bindingContext];
    }
    return _titleProperty;
}

#pragma mark - Animated Target Value Update

- (void)                          animateTriggerForSelectedRow:(NSInteger)oldSelectedRow
                                                      changeTo:(NSInteger)newSelectedRow
                                                    animations:(void(^)())block
{
    if (block)
    {
        CGFloat duration = .3;
        UIViewAnimationOptions options;
        if (oldSelectedRow < newSelectedRow)
        {
            options = UIViewAnimationOptionTransitionFlipFromTop;
        }
        else if (oldSelectedRow > newSelectedRow)
        {
            options = UIViewAnimationOptionTransitionFlipFromBottom;
        }
        else
        {
            options = UIViewAnimationOptionTransitionCrossDissolve;
        }
        [UIView transitionWithView:self.triggerView
                          duration:duration
                           options:options
                        animations:
         ^{
             block();
         }
                        completion:nil];
    }
}

- (BOOL)        shouldResignFirstResponderOnSelectedRowChanged
{
    return (self.liveModelUpdates &&
            ![self.inputAccessoryView isKindOfClass:[AKAKeyboardActivationSequenceAccessoryView class]]);
}


#pragma mark - Choices

@synthesize choices = _choices;
- (NSArray*)                                           choices
{
    if (_choices == nil)
    {
        id value = [self.choicesBindingExpression bindingSourceValueInContext:self.bindingContext];
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
        _choices = nil;
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

#pragma mark - UIPickerViewDelegate Implementation

- (NSString *)                                      pickerView:(UIPickerView *)pickerView
                                                   titleForRow:(NSInteger)row
                                                  forComponent:(NSInteger)component
{
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
            id choice = self.choices[index];

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

- (void)                                            pickerView:(UIPickerView *)pickerView
                                                  didSelectRow:(NSInteger)row
                                                   inComponent:(NSInteger)component
{
    id value = [self itemForRow:row];
    id oldValue = [self itemForRow:self.previouslySelectedRow];
    if (self.liveModelUpdates)
    {
        __weak AKABinding_AKAPickerKeyboardTriggerView_pickerBinding* weakSelf = self;
        [self animateTriggerForSelectedRow:self.previouslySelectedRow
                                  changeTo:row
                                animations:
         ^{
             [weakSelf targetValueDidChangeFromOldValue:oldValue toNewValue:value];
             weakSelf.previouslySelectedRow = row;
         }];
    }
    if ([self shouldResignFirstResponderOnSelectedRowChanged])
    {
        [self.triggerView resignFirstResponder];
    }
}

#pragma mark - UIPickerViewDataSource Implementation

- (NSInteger)                   numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)                                       pickerView:(UIPickerView *)pickerView
                                       numberOfRowsInComponent:(NSInteger)component
{
    NSAssert(component == 0, @"AKAPickerViewBinding currently only supports single component picker views");

    NSInteger result = self.choices.count;
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
    NSInteger result =  self.supportsOtherValue ? self.choices.count : NSNotFound;
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
            result = self.choices[index];
        }
    }
    return result;
}

- (NSInteger)                                       rowForItem:(id)item
{
    NSInteger result = NSNotFound;
    NSInteger index = [self.choices indexOfObject:(item == nil ? [NSNull null] : item)];

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
