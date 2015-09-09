//
//  AKATextLabelControlViewBinding.m
//  AKAControls
//
//  Created by Michael Utech on 31.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AKACommons/AKAProperty.h>

#import "AKATextLabelBinding.h"
#import "AKATextLabel.h"

@implementation AKATextLabelBinding

#pragma mark - View Value Binding

- (AKAProperty *)createViewValueProperty
{
    AKAProperty* result = [AKAProperty propertyOfWeakTarget:self.view
                                                     getter:
                           ^id (id target)
                           {
                               return ((UILabel*)target).text;
                           }
                                                     setter:
                           ^(id target, id value)
                           {
                               if ([value isKindOfClass:[NSString class]])
                               {
                                   ((UILabel*)target).text = value;
                               }
                               else if (value == nil)
                               {
                                   ((UILabel*)target).text = nil;
                               }
                               else
                               {
                                   ((UILabel*)target).text = [NSString stringWithFormat:@"%@", value];
                               }
                           }
                                         observationStarter:
                           ^BOOL (id target)
                           {
                               (void)target; // not needed
                               return YES;
                           }
                                         observationStopper:
                           ^BOOL (id target) {
                               (void)target;
                               return YES;
                           }];
    return result;
}

@end

#pragma mark - AKATextLabelControlViewBindingConfiguration
#pragma mark -

@implementation AKATextLabelBindingConfiguration

- (Class)preferredBindingType
{
    return [AKATextLabelBinding class];
}

- (Class)preferredViewType
{
    return [AKATextLabel class];
}

@end