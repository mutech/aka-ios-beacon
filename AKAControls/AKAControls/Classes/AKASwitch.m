//
//  AKASwitch.m
//  AKACommons
//
//  Created by Michael Utech on 14.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKASwitch.h"
#import "AKAControlViewBinding_Protected.h"
#import "AKAProperty.h"
#import "AKAControl.h"

@interface AKASwitchControlViewBinding: AKAControlViewBinding
#pragma mark - State

@property(nonatomic, weak) id<UITextFieldDelegate> savedSwitchDelegate;

@property(nonatomic) NSString* originalText;

#pragma mark - Convenience

@property(nonatomic, readonly) AKASwitch* switchView;

@end


@implementation AKASwitchControlViewBinding

#pragma mark - View Value Binding

- (AKAProperty *)createViewValueProperty
{
    AKAProperty* property = [AKAProperty propertyWithGetter:^id {
        return @(self.switchView.on);
    } setter:^(id value) {
        if ([value isKindOfClass:[NSNumber class]])
        {
            self.switchView.on = ((NSNumber*)value).boolValue;
        }
    } observationStarter:^BOOL () {
        BOOL result = self.switchView != nil;
        if (result)
        {
            [self.switchView addTarget:self
                                action:@selector(viewValueDidChange:)
                      forControlEvents:UIControlEventValueChanged];
        }
        return result;
    } observationStopper:^BOOL {
        BOOL result = self.switchView != nil;
        if (result)
        {
            [self.switchView removeTarget:self
                                   action:@selector(viewValueDidChange:)
                         forControlEvents:UIControlEventValueChanged];
        }
        return result;
    }];
    return property;
}

#pragma mark - Convenience

- (AKASwitch*)switchView
{
    return (AKASwitch*)self.view;
}

- (void)viewValueDidChange:(AKASwitch*)view
{
    [self           controlView:view
      didChangeValueChangedFrom:@(!view.on)
                             to:@(view.on)];
    [self.viewValueProperty notifyPropertyValueDidChangeFrom:@(!view.on)
                                                          to:@(view.on)];
}

@end


@interface AKASwitch()
@end

@implementation AKASwitch

- (Class)preferredBindingType
{
    return [AKASwitchControlViewBinding class];
}

@end
