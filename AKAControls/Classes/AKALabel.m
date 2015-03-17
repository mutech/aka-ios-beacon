//
//  AKALabel.m
//  AKACommons
//
//  Created by Michael Utech on 14.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKALabel.h"

#import "AKAControl.h"
#import "AKAControlViewBinding_Protected.h"
#import "AKAProperty.h"

@interface AKALabelControlViewBinding: AKAControlViewBinding

#pragma mark - Convenience

@property(nonatomic, readonly) AKALabel* label;

@end

@implementation AKALabelControlViewBinding

#pragma mark - View Value Binding

- (AKAProperty *)createViewValueProperty
{
    AKAProperty* result;
    result = [AKAProperty propertyWithGetter:^id {
        return self.label.text;
    } setter:^(id value) {
        if ([value isKindOfClass:[NSString class]])
        {
            self.label.text = value;
        }
        else
        {
            self.label.text = [NSString stringWithFormat:@"%@", value];
        }
    } observationStarter:^BOOL (void(^notifyPropertyOnChange)(id, id)) {
        (void)notifyPropertyOnChange; // Not used, view value is not updated by UI and we do not notify on programmatic changes (analogue to UIKit)
        return YES;
    } observationStopper:^BOOL {
        return YES;
    }];
    return result;
}

#pragma mark - Convenience

- (AKALabel *)label
{
    return (AKALabel*)self.view;
}

@end


@interface AKALabel() {
    AKALabelControlViewBinding* _controlBinding;
}
@end

@implementation AKALabel

- (AKAControlViewBinding *)bindToControl:(AKAControl *)control
{
    AKAControlViewBinding* currentBinding = self.controlBinding;
    AKALabelControlViewBinding* result;
    if (currentBinding != nil)
    {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"Invalid attempt to bind %@ to %@: Already bound: %@", self, control, currentBinding]
                                     userInfo:nil];
    }
    _controlBinding = result =
    [[AKALabelControlViewBinding alloc] initWithControl:control
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
