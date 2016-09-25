//
//  AKABinding_UISearchBar_textBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 21.09.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding_UISearchBar_textBinding.h"
#import "AKABindingErrors.h"
#import "AKANumberFormatterPropertyBinding.h"
#import "AKADateFormatterPropertyBinding.h"

@interface  AKABinding_UISearchBar_textBinding() <UISearchBarDelegate>

#pragma mark - Saved UITextField State

@property(nonatomic, weak) id<UISearchBarDelegate>         savedSearchBarDelegate;
@property(nonatomic, nullable) NSString*                   previousText;
@property(nonatomic) BOOL                                  useEditingFormat;

#pragma mark - Convenience

@property(nonatomic, readonly) UISearchBar*                searchBar;

@end


@implementation AKABinding_UISearchBar_textBinding

#pragma mark - Specification

+ (AKABindingSpecification*)                 specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        // see specification defined in AKAKeyboardControlViewBindingProvider:
        NSDictionary* spec = @{
                               @"bindingType":          [AKABinding_UISearchBar_textBinding class],
                               @"targetType":           [UISearchBar class],
                               @"expressionType":       @(AKABindingExpressionTypeAny),
                               @"attributes": @{
                                       @"numberFormatter": @{
                                               @"bindingType":         [AKANumberFormatterPropertyBinding class],
                                               @"use":                 @(AKABindingAttributeUseBindToBindingProperty),
                                               @"bindingProperty":     @"formatter"
                                               },
                                       @"dateFormatter": @{
                                               @"bindingType":         [AKADateFormatterPropertyBinding class],
                                               @"use":                 @(AKABindingAttributeUseBindToBindingProperty),
                                               @"bindingProperty":     @"formatter"
                                               },
                                       @"formatter": @{
                                               @"bindingType":         [AKAFormatterPropertyBinding class],
                                               @"use":                 @(AKABindingAttributeUseBindToBindingProperty),
                                               @"bindingProperty":     @"formatter"
                                               },
                                       @"editingNumberFormatter": @{
                                               @"bindingType":         [AKANumberFormatterPropertyBinding class],
                                               @"use":                 @(AKABindingAttributeUseBindToBindingProperty),
                                               @"bindingProperty":     @"editingFormatter"
                                               },
                                       @"editingDateFormatter": @{
                                               @"bindingType":         [AKADateFormatterPropertyBinding class],
                                               @"use":                 @(AKABindingAttributeUseBindToBindingProperty),
                                               @"bindingProperty":     @"editingFormatter"
                                               },
                                       @"editingFormatter": @{
                                               @"bindingType":         [AKAFormatterPropertyBinding class],
                                               @"use":                 @(AKABindingAttributeUseBindToBindingProperty),
                                               @"bindingProperty":     @"editingFormatter"
                                               },
                                       @"textForUndefinedValue": @{
                                               @"expressionType":      @(AKABindingExpressionTypeString),
                                               @"use":                 @(AKABindingAttributeUseAssignValueToBindingProperty),
                                               @"bindingProperty":     @"textForUndefinedValue"
                                               },
                                       @"treatEmptyTextAsUndefined": @{
                                               @"expressionType":      @(AKABindingExpressionTypeBoolean),
                                               @"use":                 @(AKABindingAttributeUseAssignValueToBindingProperty),
                                               @"bindingProperty":     @"treatEmptyTextAsUndefined"
                                               }
                                       }
                               };
        
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    
    return result;
}

#pragma mark - Initialization

- (instancetype)init
{
    if (self = [super init])
    {
        // Searchbar should not by default participate in keyboard activation sequence
        self.shouldParticipateInKeyboardActivationSequence = NO;
    }
    return self;
}

#pragma mark - Initialization - Target Value Property

- (req_AKAProperty)     createTargetValuePropertyForTarget:(req_id __unused)view
                                                     error:(out_NSError __unused)error
{
    NSAssert([view isKindOfClass:[UISearchBar class]], @"Expected a UISearchBar, got %@", view);

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                AKABinding_UISearchBar_textBinding* binding = target;

                return binding.searchBar.text;
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_UISearchBar_textBinding* binding = target;

                if (value == nil)
                {
                    binding.searchBar.text = @"";
                }
                else if ([value isKindOfClass:[NSString class]])
                {
                    binding.searchBar.text = value;
                }
                else
                {
                    binding.searchBar.text = [NSString stringWithFormat:@"%@", value];
                }

                // A programmatic change resets edits and thus needs to be reflected in previousText
                binding.previousText = binding.searchBar.text;
            }
                          observationStarter:
            ^BOOL (id target)
            {
                AKABinding_UISearchBar_textBinding* binding = target;
                UISearchBar* searchBar = binding.searchBar;
                id<UISearchBarDelegate> searchBarDelegate = searchBar.delegate;

                if (searchBarDelegate != binding)
                {
                    binding.previousText = nil;
                    searchBar.placeholder = binding.textForUndefinedValue;

                    // Format text for editing and save the result as previousText
                    // representing the target value for the current source value.
                    BOOL wasEditing = binding.useEditingFormat;

                    if (!wasEditing)
                    {
                        binding.useEditingFormat = YES;
                        [binding updateTargetValue];
                    }
                    binding.previousText = binding.searchBar.text;

                    // Render text for display
                    if (!wasEditing)
                    {
                        binding.useEditingFormat = NO;
                        [binding updateTargetValue];
                    }

                    binding.savedSearchBarDelegate = searchBarDelegate;
                    searchBar.delegate = binding;
                }
                else
                {
                    //AKALogDebug(@"Binding %@ is already observing %@", binding, binding.textField);
                }

                return YES;
            }
                          observationStopper:
            ^BOOL (id target)
            {
                AKABinding_UISearchBar_textBinding* binding = target;
                UISearchBar* searchBar = binding.searchBar;
                id<UISearchBarDelegate> searchBarDelegate = searchBar.delegate;

                if (searchBarDelegate == binding)
                {

                    searchBar.delegate = binding.savedSearchBarDelegate;

                    binding.previousText = nil;
                }
                
                return YES;
            }];
}

#pragma mark - Conversion

- (BOOL)                                convertTargetValue:(opt_id)targetValue
                                             toSourceValue:(out_id)sourceValueStore
                                                     error:(out_NSError)error
{
    BOOL result = NO;

    if (targetValue)
    {
        NSString* errorDescription = nil;
        NSFormatter* formatter = nil;

        if (self.useEditingFormat && self.editingFormatter)
        {
            formatter = self.editingFormatter;
            result = [formatter getObjectValue:sourceValueStore
                                     forString:(req_id)targetValue
                              errorDescription:&errorDescription];
        }
        else if (self.formatter)
        {
            formatter = self.formatter;
            result = [formatter getObjectValue:sourceValueStore
                                     forString:(req_id)targetValue
                              errorDescription:&errorDescription];
        }
        else
        {
            result = [super convertTargetValue:targetValue
                                 toSourceValue:sourceValueStore
                                         error:error];
        }

        if (!result && formatter && error)
        {
            *error = [AKABindingErrors bindingErrorConversionOfBinding:self
                                                           targetValue:targetValue
                                                        usingFormatter:(req_NSFormatter)self.formatter
                                                     failedWithMessage:errorDescription];
        }
    }
    else
    {
        result = [super convertTargetValue:targetValue
                             toSourceValue:sourceValueStore
                                     error:error];
    }

    return result;
}

- (BOOL)                                convertSourceValue:(opt_id)sourceValue
                                             toTargetValue:(out_id)targetValueStore
                                                     error:(out_NSError)error
{
    BOOL result = NO;

    id effectiveSourceValue = sourceValue;

    if (self.treatEmptyTextAsUndefined && [effectiveSourceValue isKindOfClass:[NSString class]])
    {
        NSString* text = (NSString*)effectiveSourceValue;

        // TODO: the disabled behavior below is more robust, but maybe not expected, consider adding
        // another configuration item or enabling this:
        //text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        if (text.length == 0)
        {
            effectiveSourceValue = nil;
        }
    }

    if (effectiveSourceValue)
    {
        NSString* errorDescription = nil;
        NSFormatter* formatter = nil;
        NSString* text = nil;

        if (self.useEditingFormat && self.editingFormatter)
        {
            formatter = self.editingFormatter;
            text = [formatter stringForObjectValue:(req_id)effectiveSourceValue];
            result = text != nil;
        }
        else if (self.formatter)
        {
            formatter = self.formatter;

            if (self.useEditingFormat)
            {
                text = [formatter editingStringForObjectValue:(req_id)effectiveSourceValue];
                result = text != nil;
            }
            else
            {
                text = [self.formatter stringForObjectValue:(req_id)effectiveSourceValue];
                result = text != nil;
            }
        }
        else
        {
            result = [super convertSourceValue:effectiveSourceValue
                                 toTargetValue:targetValueStore
                                         error:error];
        }

        if (formatter)
        {
            if (result)
            {
                *targetValueStore = text;
            }
            else if (error)
            {
                *error = [AKABindingErrors bindingErrorConversionOfBinding:self
                                                               sourceValue:effectiveSourceValue
                                                            usingFormatter:(req_NSFormatter)formatter
                                                         failedWithMessage:errorDescription];
            }
        }
    }
    else
    {
        result = [super convertSourceValue:effectiveSourceValue
                             toTargetValue:targetValueStore
                                     error:error];
    }
    
    return result;
}

#pragma mark - Properties

- (UISearchBar *)searchBar
{
    UIView* view = self.target;

    NSParameterAssert(view == nil || [view isKindOfClass:[UISearchBar class]]);

    return (UISearchBar*)view;
}

- (void)                         setSavedSearchBarDelegate:(id<UISearchBarDelegate>)savedSearchBarDelegate
{
    NSAssert(savedSearchBarDelegate != self, @"Cannot register search bar binding as saved delegate, it already acts as replacement/proxy delegate");

    _savedSearchBarDelegate = savedSearchBarDelegate;
}

#pragma mark - UISearchBarDelegate

- (BOOL)                      searchBarShouldBeginEditing:(UISearchBar*)searchBar
{
    id<UISearchBarDelegate> secondary = self.savedSearchBarDelegate;

    BOOL result = YES;

    if ([secondary respondsToSelector:@selector(searchBarShouldBeginEditing:)])
    {
        result = [secondary searchBarShouldBeginEditing:searchBar];
    }

    if (result)
    {
        result = [self shouldActivate];
    }

    return result;
}

- (void)                     searchBarTextDidBeginEditing:(UISearchBar*)searchBar
{
    NSParameterAssert(searchBar == self.searchBar);
    id<UISearchBarDelegate> secondary = self.savedSearchBarDelegate;

    self.useEditingFormat = YES;

    if (self.liveModelUpdates || self.searchBar.text.length > 0)
    {
        // update unless the current state may be the result of a clear button press, in which case the update would undo the clear action.
        [self updateTargetValue];
    }

    [self responderDidActivate:self.searchBar];

    if ([secondary respondsToSelector:@selector(searchBarTextDidBeginEditing:)])
    {
        [secondary searchBarTextDidBeginEditing:searchBar];
    }
}

- (BOOL)                                        searchBar:(UISearchBar *)searchBar
                                  shouldChangeTextInRange:(NSRange)range
                                          replacementText:(NSString *)text
{
    NSParameterAssert(searchBar == self.searchBar);
    id<UISearchBarDelegate> secondary = self.savedSearchBarDelegate;

    BOOL result = YES;

    if ([secondary respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)])
    {
        result = [secondary           searchBar:searchBar
                        shouldChangeTextInRange:range
                                replacementText:text];
    }

    return result;
}

- (void)                                        searchBar:(UISearchBar*__unused)searchBar
                                            textDidChange:(NSString*__unused)searchText
{
    NSParameterAssert(searchBar == self.searchBar);

    [self viewValueDidChange];
}

- (BOOL)                        searchBarShouldEndEditing:(UISearchBar*)searchBar
{
    NSParameterAssert(searchBar == self.searchBar);
    id<UISearchBarDelegate> secondary = self.savedSearchBarDelegate;

    BOOL result = YES;

    if ([secondary respondsToSelector:@selector(searchBarShouldEndEditing::)])
    {
        result &= [secondary searchBarShouldEndEditing:searchBar];
    }
    result &= [self shouldDeactivate];

    return result;
}

- (void)                       searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    id<UISearchBarDelegate> secondary = self.savedSearchBarDelegate;

    NSParameterAssert(searchBar == self.searchBar);

    // Call delegate first to give it a chance to change the value
    if ([secondary respondsToSelector:@selector(searchBarTextDidEndEditing:)])
    {
        [secondary searchBarTextDidEndEditing:searchBar];
    }

    // Update source
    [self viewValueDidChange];

    // Notify delegates
    [self responderDidDeactivate:searchBar];

    // Rerender text in display format
    self.useEditingFormat = NO;
    [self updateTargetValue];
}

#pragma mark - Change Observation

- (void)                                viewValueDidChange
{
    NSString* oldValue = self.previousText;
    NSString* newValue = self.searchBar.text;

    if (self.liveModelUpdates || !self.searchBar.isFirstResponder)
    {
        // Send change notification
        if (newValue != oldValue && ![newValue isEqualToString:oldValue])
        {
            [self targetValueDidChangeFromOldValue:oldValue toNewValue:newValue];
            newValue = self.searchBar.text; // the delegate may change the value
        }

        if (newValue != oldValue && ![newValue isEqualToString:oldValue])
        {
            [self.targetValueProperty notifyPropertyValueDidChangeFrom:oldValue to:newValue];
            self.previousText = newValue;
        }
    }
}

#pragma mark - Keyboard Activation Sequence

- (BOOL)     shouldParticipateInKeyboardActivationSequence
{
    BOOL result = ([super shouldParticipateInKeyboardActivationSequence] &&
                   self.supportsActivation);

    return result;
}

- (void)                    setResponderInputAccessoryView:(UIView*)responderInputAccessoryView
{
    self.searchBar.inputAccessoryView = responderInputAccessoryView;
}

#pragma mark - Obsolete (probably) Activation

- (BOOL)                                supportsActivation
{
    BOOL result = self.searchBar != nil;

    return result;
}

- (BOOL)                                shouldAutoActivate
{
    BOOL result = self.supportsActivation && self.autoActivate;

    return result;
}

#pragma mark - Obsolete (probably) Delegate Support Methods

- (BOOL)                                    shouldActivate
{
    return YES;
}

- (BOOL)                                  shouldDeactivate
{
    return YES;
}


@end
