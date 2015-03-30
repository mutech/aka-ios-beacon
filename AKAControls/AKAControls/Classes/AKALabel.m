//
//  AKALabel.m
//  AKACommons
//
//  Created by Michael Utech on 14.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKALabel.h"

#import "AKAControl_Protected.h"
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
    result = [AKAProperty propertyOfWeakTarget:self
                                      getter:
              ^id (id target)
              {
                  AKALabelControlViewBinding* binding = target;
                  return binding.label.text;
              }
                                      setter:
              ^(id target, id value)
              {
                  AKALabelControlViewBinding* binding = target;
                  if ([value isKindOfClass:[NSString class]])
                  {
                      binding.label.text = value;
                  }
                  else
                  {
                      binding.label.text = [NSString stringWithFormat:@"%@", value];
                  }
              }
                          observationStarter:
              ^BOOL (id target)
              {
                  return YES;
              }
                          observationStopper:
              ^BOOL (id target) {
                  (void)target;
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


@interface AKALabel()
@end

@implementation AKALabel

- (Class)preferredBindingType
{
    return [AKALabelControlViewBinding class];
}

@end
