//
//  AKASwitchControlViewBinding.m
//  AKAControls
//
//  Created by Michael Utech on 31.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKAProperty;

#import "AKASwitchBinding.h"
#import "AKASwitch.h"

#pragma mark - AKASwitchControlViewBinding
#pragma mark -

@interface AKASwitchBinding()

#pragma mark - Convenience

@property(nonatomic, readonly) UISwitch* switchView;

@end

@implementation AKASwitchBinding

#pragma mark - View Value Binding

- (AKAProperty *)createViewValueProperty
{
    AKAProperty* property = [AKAProperty propertyOfWeakTarget:self
                                                       getter:
                             ^id (id target)
                             {
                                 AKASwitchBinding* binding = target;
                                 return @(binding.switchView.on);
                             }
                                                       setter:
                             ^(id target, id value)
                             {
                                 AKASwitchBinding* binding = target;
                                 if ([value isKindOfClass:[NSNumber class]])
                                 {
                                     binding.switchView.on = ((NSNumber*)value).boolValue;
                                 }
                             }
                                           observationStarter:
                             ^BOOL (id target)
                             {
                                 AKASwitchBinding* binding = target;
                                 BOOL result = binding.switchView != nil;
                                 if (result)
                                 {
                                     [binding.switchView addTarget:binding
                                                            action:@selector(viewValueDidChange:)
                                                  forControlEvents:UIControlEventValueChanged];
                                 }
                                 return result;
                             }
                                           observationStopper:
                             ^BOOL (id target)
                             {
                                 AKASwitchBinding* binding = target;
                                 BOOL result = binding.switchView != nil;
                                 if (result)
                                 {
                                     [self.switchView removeTarget:binding
                                                            action:@selector(viewValueDidChange:)
                                                  forControlEvents:UIControlEventValueChanged];
                                 }
                                 return result;
                             }];
    return property;
}

#pragma mark - Convenience

- (UISwitch*)switchView
{
    UIView* view = self.view;
    return [view isKindOfClass:[UISwitch class]] ? (UISwitch*)view : nil;
}

- (void)viewValueDidChange:(UISwitch*)view
{
    NSNumber* newValue = @(self.switchView.on);
    NSNumber* oldValue = @(!newValue);

    [self viewValueDidChangeFrom:oldValue to:newValue];
    newValue = @(self.switchView.on); // delegate might change the value again
    if (oldValue.boolValue != newValue.boolValue)
    {
        [self.viewValueProperty notifyPropertyValueDidChangeFrom:oldValue
                                                              to:newValue];
    }
}

@end

#pragma mark - AKASwitchControlViewBindingConfiguration
#pragma mark -

@implementation AKASwitchBindingConfiguration

- (Class)preferredBindingType
{
    return [AKASwitchBinding class];
}

- (Class)preferredViewType
{
    return [AKASwitch class];
}

@end