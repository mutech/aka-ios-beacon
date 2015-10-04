//
//  AKAPickerViewBinding.m
//  AKAControls
//
//  Created by Michael Utech on 14.09.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.NSObject_AKAConcurrencyTools;
@import AKACommons.AKAProperty;

#import "AKAPickerViewBinding.h"
#import "AKAPickerView.h"
#import "AKAControlConverterProtocol.h"


@interface AKAPickerViewBinding() <UIPickerViewDelegate, UIPickerViewDataSource>

@property(nonatomic, readonly) UIPickerView* pickerView;
@property(nonatomic, readonly) AKAPickerViewBindingConfiguration* configuration;

@property(nonatomic, readonly, strong) AKAProperty* choicesProperty;

@property(nonatomic, readonly) NSArray* choices;
@property(nonatomic, readonly) AKAProperty* choiceTitleProperty;

@property(nonatomic, readonly) id<AKAControlConverterProtocol> titleConverter;
@property(nonatomic, readonly) AKAUnboundProperty* titleProperty;

@property(nonatomic, weak) id otherValue;

@property(nonatomic, readonly) BOOL needsReloadChoices;

@property(nonatomic) NSInteger previouslySelectedRow;

@end

@implementation AKAPickerViewBinding

#pragma mark - Binding Configuration

- (AKAPickerViewBindingConfiguration*)configuration
{
    return (AKAPickerViewBindingConfiguration*)super.configuration;
}

- (UIPickerView *)pickerView
{
    return (UIPickerView*)self.view;
}

#pragma mark - View Value Binding

- (AKAProperty*)createViewValueProperty
{
    AKAProperty* result;
    result = [AKAProperty propertyOfWeakTarget:self getter:
              ^id(id target)
              {
                  id result;
                  AKAPickerViewBinding* binding = target;
                  NSUInteger row = [binding.pickerView selectedRowInComponent:0];
                  result = [binding itemForRow:row];
                  return result;
              }
                                        setter:
              ^(id target, id value)
              {
                  AKAPickerViewBinding* binding = target;
                  NSInteger row = [binding rowForItem:value];
                  if (row != NSNotFound)
                  {
                      id currentValue = [self itemForRow:[binding.pickerView selectedRowInComponent:0]];
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
                          self.previouslySelectedRow = row;
                      }
                  }
              }
                            observationStarter:
              ^BOOL(id target)
              {
                  AKAPickerViewBinding* binding = target;
                  binding.pickerView.delegate = binding;
                  binding.pickerView.dataSource = binding;
                  [binding setNeedsReloadChoices];
                  [binding reloadChoicesIfNeeded];
                  return YES;
              }
                            observationStopper:
              ^BOOL(id target)
              {
                  AKAPickerViewBinding* binding = target;
                  binding.pickerView.delegate = nil;
                  binding.pickerView.dataSource = nil;
                  return YES;
              }];
    return result;
}

- (BOOL)supportsUndefinedValue
{
    return self.configuration.undefinedValueTitle.length > 0;
}

- (NSInteger)rowForUndefinedValue
{
    return self.supportsUndefinedValue ? 0 : NSNotFound;
}

- (BOOL)supportsOtherValue
{
    return self.configuration.otherValueTitle.length > 0;
}

- (NSInteger)rowForOtherValue
{
    NSInteger result =  self.supportsOtherValue ? self.choices.count : NSNotFound;
    if (result != NSNotFound && self.supportsUndefinedValue)
    {
        ++result;
    }
    return result;
}

- (NSInteger)indexForRow:(NSInteger)row
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

- (NSInteger)rowForIndex:(NSInteger)index
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

- (id)itemForRow:(NSInteger)row
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

- (NSInteger)rowForItem:(id)item
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

#pragma mark - Choices Binding

@synthesize choicesProperty = _choicesProperty;
- (AKAProperty *)choicesProperty
{
    if (_choicesProperty == nil && self.delegate != nil)
    {
        NSString* keyPath = self.configuration.pickerValuesKeyPath;
        if (keyPath.length > 0)
        {
            _choicesProperty = [self.delegate dataContextPropertyForKeyPath:keyPath
                                                        withChangeObserver:
                                ^(id oldValue, id newValue)
                                {
                                    [self choicesDidChange];
                                }];
            if (_choicesProperty != nil)
            {
                [self setNeedsReloadChoices];
            }
        }
    }
    return _choicesProperty;
}

@synthesize choices = _choices;
- (NSArray*)choices
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

- (void)choicesDidChange
{
    [self aka_performBlockInMainThreadOrQueue:^{
        _choices = nil;
        [self setNeedsReloadChoices];
    }
                            waitForCompletion:NO];
}

- (void)setNeedsReloadChoices
{
    _needsReloadChoices = YES;
}

- (void)reloadChoicesIfNeeded
{
    if (self.needsReloadChoices)
    {
        [self reloadChoices];
    }
}

- (void)reloadChoices
{
    if (self.pickerView.dataSource == self)
    {
        [self.pickerView reloadAllComponents];
        _needsReloadChoices = NO;
    }
}

@synthesize titleConverter = _titleConverter;
- (id<AKAControlConverterProtocol>)titleConverter
{
    if (_titleConverter == nil)
    {
        if (self.configuration.titleConverterKeyPath.length > 0)
        {
            AKAProperty* titleConverterProperty = [self.delegate dataContextPropertyForKeyPath:self.configuration.titleConverterKeyPath
                                                                           withChangeObserver:nil];
            _titleConverter = titleConverterProperty.value;
        }
    }
    return _titleConverter;
}

@synthesize titleProperty = _titleProperty;
- (AKAUnboundProperty*)titleProperty
{
    if (_titleProperty == nil && self.configuration.titleKeyPath.length > 0)
    {
        _titleProperty = [AKAProperty unboundPropertyWithKeyPath:self.configuration.titleKeyPath];
    }
    return _titleProperty;
}

#pragma mark - Validation

- (BOOL)managesValidationStateForContext:(id)validationContext view:(UIView *)view
{
    return NO; //view == self.pickerView;
}

#pragma mark - Activation

- (BOOL)supportsActivation
{
    // The picker itself cannot be activated, it serves as input view for another control
    return NO;
}

#pragma mark - Picker View Delegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    NSAssert(component == 0, @"AKAPickerViewBinding currently only supports single component picker views");
    NSString* result = nil;

    if (row == self.rowForUndefinedValue)
    {
        result = self.configuration.undefinedValueTitle;
    }
    else if (row == self.rowForOtherValue)
    {
        result = self.configuration.otherValueTitle;
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

            if (self.titleConverter != nil)
            {
                NSError* error = nil;
                if (![self.titleConverter convertModelValue:choice toViewValue:&choice error:&error])
                {
                    choice = error.localizedDescription;
                }
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

- (void)        pickerView:(UIPickerView *)pickerView
              didSelectRow:(NSInteger)row
               inComponent:(NSInteger)component
{
    id value = [self itemForRow:row];
    id oldValue = [self itemForRow:self.previouslySelectedRow];
    [self.delegate viewBinding:self
                          view:pickerView
            valueDidChangeFrom:oldValue to:value];
}

#pragma mark - Picker View Data Source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)   pickerView:(UIPickerView *)pickerView
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

@end


@implementation AKAPickerViewBindingConfiguration

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.pickerValuesKeyPath = [aDecoder decodeObjectForKey:@"pickerValuesKeyPath"];
        self.titleKeyPath = [aDecoder decodeObjectForKey:@"titleKeyPath"];
        self.titleConverterKeyPath = [aDecoder decodeObjectForKey:@"titleConverterKeyPath"];
        self.otherValueTitle = [aDecoder decodeObjectForKey:@"otherValueTitle"];
        self.undefinedValueTitle = [aDecoder decodeObjectForKey:@"undefinedValueTitle"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.pickerValuesKeyPath forKey:@"pickerValuesKeyPath"];
    [aCoder encodeObject:self.titleKeyPath forKey:@"titleKeyPath"];
    [aCoder encodeObject:self.titleConverterKeyPath forKey:@"titleConverterKeyPath"];
    [aCoder encodeObject:self.otherValueTitle forKey:@"otherValueTitle"];
    [aCoder encodeObject:self.undefinedValueTitle forKey:@"undefinedValueTitle"];
}

#pragma mark - Configuration

- (Class)preferredViewType
{
    return [AKAPickerView class];
}

- (Class)preferredBindingType
{
    return [AKAPickerViewBinding class];
}

@end
