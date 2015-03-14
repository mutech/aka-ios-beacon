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
    AKAProperty* result;
    result = [AKAProperty propertyWithGetter:^id {
        return @(self.switchView.on);
    } setter:^(id value) {
        if ([value isKindOfClass:[NSNumber class]])
        {
            self.switchView.on = ((NSNumber*)value).boolValue;
        }
    } observationStarter:^BOOL (void(^notifyPropertyOnChange)(id, id)) {
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
    return result;
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
}

@end


@interface AKASwitch() {
    AKASwitchControlViewBinding* _controlBinding;
}
@end

@implementation AKASwitch

- (AKAControlViewBinding *)bindToControl:(AKAControl *)control
{
    AKASwitchControlViewBinding* result;
    if (self.controlBinding != nil)
    {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"Invalid attempt to bind %@ to %@: Already bound: %@", self, control, self.controlBinding]
                                     userInfo:nil];
    }
    _controlBinding = result =
    [[AKASwitchControlViewBinding alloc] initWithControl:control
                                                       view:self];
    return result;
}

- (AKAControl*)createControlWithDataContext:(id)dataContext
{
    AKAControl* result = [AKAControl controlWithDataContext:dataContext keyPath:self.textKeyPath];
    result.viewBinding = [self bindToControl:result];
    return result;
}

- (AKAControl*)createControlWithOwner:(AKACompositeControl *)owner
{
    AKAControl* result = [AKAControl controlWithOwner:owner keyPath:self.textKeyPath];
    result.viewBinding = [self bindToControl:result];
    return result;
}

- (AKAControlViewBinding *)controlBinding
{
    return _controlBinding;
}

@end
