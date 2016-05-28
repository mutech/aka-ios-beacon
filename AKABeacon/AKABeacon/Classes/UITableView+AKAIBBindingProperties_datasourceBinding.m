//
//  UITableView+AKAIBBindingProperties.m
//  AKABeacon
//
//  Created by Michael Utech on 06.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "NSObject+AKAAssociatedValues.h"

#import "UITableView+AKAIBBindingProperties_datasourceBinding.h"
#import "AKABinding_UITableView_dataSourceBinding.h"
#import "AKAViewBinding+IBPropertySupport.h"
#import "AKATableViewCompositeControl.h"


@implementation UITableView(AKAIBBindingProperties_datasourceBinding)

- (NSString *)dataSourceBinding_aka
{
    return [AKABinding_UITableView_dataSourceBinding bindingExpressionTextForSelector:@selector(dataSourceBinding_aka)
                                                                               inView:self];
}

- (void)setDataSourceBinding_aka:(NSString *)dataSourceBinding_aka
{
    [AKABinding_UITableView_dataSourceBinding setBindingExpressionText:dataSourceBinding_aka
                                                           forSelector:@selector(dataSourceBinding_aka)
                                                                inView:self];
}

#pragma mark - Obsolete

- (AKAMutableControlConfiguration*)aka_controlConfiguration
{
    NSString* key = NSStringFromSelector(@selector(aka_controlConfiguration));
    AKAMutableControlConfiguration* result = [self aka_associatedValueForKey:key];
    if (result == nil)
    {
        result = [AKAMutableControlConfiguration new];
        result[kAKAControlTypeKey] = [AKATableViewCompositeControl class];
        result[kAKAControlViewBinding] = NSStringFromSelector(@selector(dataSourceBinding_aka));
        [self aka_setAssociatedValue:result forKey:key];
    }
    return result;
}

- (void)aka_setControlConfigurationValue:(id)value forKey:(NSString *)key
{
    AKAMutableControlConfiguration* mutableConfiguration = (AKAMutableControlConfiguration*)self.aka_controlConfiguration;
    if (value == nil)
    {
        [mutableConfiguration removeObjectForKey:key];
    }
    else
    {
        mutableConfiguration[key] = value;
    }
}

@end
