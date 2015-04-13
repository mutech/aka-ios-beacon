//
//  AKAEditorControlView.m
//  AKACommons
//
//  Created by Michael Utech on 15.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAEditorControlView.h"
#import "AKAControlViewProtocol.h"
#import "AKACompositeControl.h"
#import "AKALabel.h"

#import "AKAControlsErrors.h"
#import "AKAProperty.h"

#import "UIView+AKABinding.h"

#import <AKACommons/AKALog.h>

@interface AKAEditorControlView()

@property(nonatomic, assign) BOOL setupActive;
@property(nonatomic) AKAProperty* themeNameProperty;
@property(nonatomic, readonly) AKAEditorBindingConfiguration* editorBindingConfiguration;

@end

@implementation AKAEditorControlView

@synthesize editorBindingConfiguration = _editorBindingConfiguration;

#pragma mark - Initialization

- (void)setupDefaultValues
{
    [super setupDefaultValues];
    _editorBindingConfiguration = AKAEditorBindingConfiguration.new;
}

#pragma mark - Binding Configuration
/// @name Binding configuration

- (AKAViewBindingConfiguration*)bindingConfiguration
{
    return self.editorBindingConfiguration;
}

#pragma mark - Interface Builder Properties
/// @name Interface Builder Properties

- (NSString *)controlName
{
    return self.bindingConfiguration.controlName;
}
- (void)setControlName:(NSString *)controlName
{
    self.bindingConfiguration.controlName = controlName;
}

- (NSString *)role
{
    return self.bindingConfiguration.role;
}
- (void)setRole:(NSString *)role
{
    self.bindingConfiguration.role = role;
}

- (NSString *)valueKeyPath
{
    return self.bindingConfiguration.valueKeyPath;
}
- (void)setValueKeyPath:(NSString *)valueKeyPath
{
    self.bindingConfiguration.valueKeyPath = valueKeyPath;
}

- (NSString *)converterKeyPath
{
    return self.bindingConfiguration.converterKeyPath;
}
- (void)setConverterKeyPath:(NSString *)converterKeyPath
{
    self.bindingConfiguration.converterKeyPath = converterKeyPath;
}

- (NSString *)validatorKeyPath
{
    return self.bindingConfiguration.validatorKeyPath;
}
- (void)setValidatorKeyPath:(NSString *)validatorKeyPath
{
    self.bindingConfiguration.validatorKeyPath = validatorKeyPath;
}

- (NSString *)labelText
{
    return self.editorBindingConfiguration.labelText;
}
- (void)setLabelText:(NSString *)labelText
{
    self.editorBindingConfiguration.labelText = labelText;
}

#pragma mark - Configuration

- (NSString *)themeName
{
    NSString* result = super.themeName;
    if (result.length == 0)
    {
        result = self.themeNameProperty.value;
    }
    return result;
}

- (void)viewBindingChangedFrom:(AKAViewBinding *)oldBinding
                            to:(AKAViewBinding *)newBinding
{
    self.themeNameProperty = nil;
    __weak typeof(self) weakSelf = self;
    self.themeNameProperty = [newBinding.delegate themeNamePropertyForView:self
                                                   changeObserver:^(id oldValue,
                                                                    id newValue)
                              {
                                  [weakSelf setNeedsApplySelectedTheme];
                                  [weakSelf setNeedsLayout];

                                  [weakSelf updateConstraintsIfNeeded];
                                  [weakSelf layoutIfNeeded];
                              }];
    [self.themeNameProperty startObservingChanges];
    if (super.themeName.length == 0)
    {
        [self setNeedsApplySelectedTheme];
        [self setNeedsUpdateConstraints];
        [self setNeedsLayout];
    }
}

+ (AKASubviewsSpecification *)subviewsSpecification
{
    static dispatch_once_t token;
    static AKASubviewsSpecification* instance = nil;
    dispatch_once(&token, ^{
        instance = [[AKASubviewsSpecification alloc] initWithDictionary:
                    @{ @"self":
                           @{ @"requirements": @{ @"present": @YES,
                                                  @"type": [AKAEditorControlView class] }
                              },
                       @"label":
                           @{ @"outlet": [NSString stringWithUTF8String:sel_getName(@selector(label))],
                              @"viewTag": @1,
                              @"requirements": @{ @"present": @YES,
                                                  @"type": [UILabel class] }
                              },
                       @"editor":
                           @{ @"outlet": [NSString stringWithUTF8String:sel_getName(@selector(editor))],
                              @"viewTag": @2,
                              @"requirements": @{ @"present": @YES,
                                                  @"type": [UIView class] }
                              },
                       @"message":
                           @{ @"outlet": [NSString stringWithUTF8String:sel_getName(@selector(messageLabel))],
                              @"viewTag": @3,
                              @"requirements": @{ @"present": @YES,
                                                  @"type": [UILabel class] }
                              },
                       }];
    });
    return instance;
}

+ (NSDictionary*)builtinThemes
{
    static dispatch_once_t token;
    static NSDictionary* instance = nil;
    dispatch_once(&token, ^{
        instance = @{ @"default": [self builtinDefaultTheme],
                      @"tableview": [self builtinTableViewTheme]
                      };
    });
    return instance;
}

+ (AKATheme*)builtinDefaultTheme
{
    static dispatch_once_t token;
    static AKATheme* result = nil;
    dispatch_once(&token, ^{
        result = [AKATheme themeWithDictionary:
                  @{ @"viewCustomization":
                         @[ @{ @"view": @"label",
                               @"requirements": @{ @"type": [UILabel class] },
                               @"properties":
                                   @{ @"font": [UIFont systemFontOfSize:16.0 weight:UIFontWeightLight],
                                      @"textColor": [UIColor grayColor],
                                      @"numberOfLines": @(1),
                                      @"lineBreakMode": @(NSLineBreakByTruncatingTail),
                                      @"textAlignment": @(NSTextAlignmentLeft),
                                      @"adjustsFontSizeToFitWidth": @YES,
                                      @"minimumScaleFactor": @(.5f)
                                      }
                               },
                            @{ @"view": @"editor",
                               @"requirements": @{ @"type": [UITextField class] },
                               @"properties":
                                   @{ @"font": [UIFont systemFontOfSize:16.0],
                                      @"backgroundColor": [UIColor whiteColor],
                                      @"borderStyle": @(UITextBorderStyleRoundedRect) }
                               },
                            @{ @"view": @"message",
                               @"requirements": @{ @"type": [UILabel class] },
                               @"properties":
                                   @{ @"font": [UIFont systemFontOfSize:12.0 weight:UIFontWeightLight],
                                      @"textColor": [UIColor redColor],
                                      @"numberOfLines": @(0),
                                      @"lineBreakMode": @(NSLineBreakByWordWrapping) }
                               },
                            ],
                     @"metrics": @{ @"pl":@(0), @"pr":@(0), @"pt":@(8), @"pb":@(8),
                                    @"vs":@(0), @"hs":@(4),
                                    @"labelWidth":@(100)},
                     @"layouts":
                         @[ @{ @"viewRequirements": @{ @"label": @YES, @"editor": @YES },
                               @"constraints":
                                   @[ @{ @"format": @"V:|-(>=pt)-[label]-(>=pb)-|" }, // keep multiline label inside container view
                                      @{ @"format": @"V:|-(pt@249)-[label]-(pb@249)-|" }]
                               },

                            // First baseline alignment if editor has baseline
                            @{ @"viewRequirements": @{ @"label": @YES,
                                                       @"editor": @{ @"type": @[ [UITextField class],
                                                                                 [UILabel class],
                                                                                 [UIButton class] ] } },
                               @"constraints":
                                   @[ @{ @"format": @"H:|-(pl)-[label(labelWidth)]-(hs)-[editor]-(pr)-|" },
                                      @{  @"firstItem": @"editor",
                                          @"firstAttribute": @(NSLayoutAttributeFirstBaseline),
                                          @"secondItem": @"label",
                                          @"secondAttribute": @(NSLayoutAttributeFirstBaseline) },
                                      ]
                               },

                            // Center alignment if editor may not have baseline
                            @{ @"viewRequirements": @{ @"label": @YES,
                                                       @"editor": @{ @"notType": @[ [UITextField class],
                                                                                    [UILabel class],
                                                                                    [UIButton class] ] } },
                               @"constraints":
                                   @[ @{ @"format": @"H:|-(pl)-[label(labelWidth)]-(hs)-[editor]-(>=pr)-|" },
                                      @{ @"format": @"H:[editor]-(pr@249)-|" }, // avoid inequality ambiguities
                                      @{ @"firstItem": @"editor",
                                         @"firstAttribute": @(NSLayoutAttributeCenterY),
                                         @"secondItem": @"label",
                                         @"secondAttribute": @(NSLayoutAttributeCenterY) },
                                      ]
                               },

                            // For layout with message view:
                            @{ @"viewRequirements": @{ @"label": @YES, @"editor": @YES, @"message": @YES },
                               @"constraints":
                                   @[ @{ @"format": @"V:|-(pt)-[editor]-(vs)-[message]-(>=pb)-|",
                                         @"options":
                                             @(NSLayoutFormatAlignAllLeading|NSLayoutFormatAlignAllTrailing)
                                         },
                                      @{ @"format": @"V:[message]-(pb@249)-|" },
                                      ]
                               },
                            // For layout without message view
                            @{ @"viewRequirements": @{ @"label": @YES, @"editor": @YES, @"message": @NO },
                               @"constraints":
                                   @[ @{ @"format": @"V:|-(pt)-[editor]-(>=pb)-|",
                                         @"options": @(NSLayoutFormatAlignAllLeading|NSLayoutFormatAlignAllTrailing)
                                         },
                                      ]
                               },
                            ]
                     }];
    });
    return result;
}

+ (AKATheme*)builtinTableViewTheme
{
    static dispatch_once_t token;
    static AKATheme* result = nil;
    dispatch_once(&token, ^{
        result = [AKATheme themeWithDictionary:
                  @{ @"viewCustomization":
                         @[ @{ @"view": @"label",
                               @"requirements": @{ @"type": [UILabel class] },
                               @"properties":
                                   @{ @"font": [UIFont systemFontOfSize:12.0],
                                      @"textColor": [UIColor grayColor],
                                      @"numberOfLines": @(1),
                                      @"lineBreakMode": @(NSLineBreakByTruncatingTail)
                                      }
                               },
                            @{ @"view": @"editor",
                               @"requirements": @{ @"type": [UITextField class] },
                               @"properties":
                                   @{ @"font": [UIFont systemFontOfSize:18.0],
                                      @"backgroundColor": [UIColor colorWithWhite:1 alpha:0],
                                      @"borderStyle": @(UITextBorderStyleNone) }
                               },
                            @{ @"view": @"message",
                               @"requirements": @{ @"type": [UILabel class] },
                               @"properties":
                                   @{ @"font": [UIFont systemFontOfSize:10.0 weight:UIFontWeightLight],
                                      @"textColor": [UIColor redColor],
                                      @"numberOfLines": @(0),
                                      @"lineBreakMode": @(NSLineBreakByWordWrapping)
                                      }
                               },
                            ],
                     @"metrics": @{ @"pl":@(0), @"pr":@(0), @"pt":@(4), @"pb":@(4),
                                    @"vs12":@(2), @"vs23":@(0),
                                    @"hs":@(4) },
                     @"layouts":
                         @[ @{ @"viewRequirements":
                                   @{ @"label":   @YES,
                                      @"editor":  @{ @"type": [UISwitch class] },
                                      @"message": @YES },
                               @"constraints":
                                   @[ @{ @"format": @"H:|-(pl)-[label]-(>=hs)-[editor]-(pr)-|",
                                         @"options": @(NSLayoutFormatAlignAllTop)
                                         },
                                      @{ @"format": @"H:|-(pl)-[message]-(>=hs)-[editor]-(pr)-|",
                                         @"options": @(NSLayoutFormatAlignAllBottom)
                                         },
                                      @{ @"format": @"V:[label]-(vs12)-[message]" },
                                      @{ @"format": @"V:|-(>=pt)-[editor]-(>=pb)-|" },
                                      @{ @"format": @"V:|-(pt@249)-[editor]-(pb@249)-|" },
                                      @{ @"firstItem": @"editor",
                                         @"firstAttribute": @(NSLayoutAttributeCenterY),
                                         @"secondItem": @"self",
                                         @"secondAttribute": @(NSLayoutAttributeCenterY) }
                                      ] },
                            @{ @"viewRequirements":
                                   @{ @"label":   @YES,             // short for @{@"present": @YES}
                                      @"editor":  @{ @"type": [UISwitch class] },
                                      @"message": @NO },            // short for @{@"absent": @YES}
                               @"constraints":
                                   @[ @{ @"format": @"H:|-(pl)-[label]-(>=hs)-[editor]-(pr)-|",
                                         @"options": @(NSLayoutFormatAlignAllTop|NSLayoutFormatAlignAllBottom)
                                         },
                                      @{ @"format": @"V:|-(pt)-[editor]-(pb)-|"
                                         },
                                      @{ @"firstItem": @"editor",
                                         @"firstAttribute": @(NSLayoutAttributeCenterY),
                                         @"secondItem": @"self",
                                         @"secondAttribute": @(NSLayoutAttributeCenterY) }
                                      ] },
                            @{ @"viewRequirements":
                                   @{ @"editor":  @{ @"type": [UISwitch class] } },
                               @"viewCustomization":
                                   @[ @{ @"view": @"label",
                                         @"requirements": @{ @"type": [UILabel class] },
                                         @"properties":
                                             @{ @"font": [UIFont systemFontOfSize:14.0] } } ]
                               },

                            @{ @"viewRequirements":
                                   @{ @"label":   @YES,
                                      @"editor":  @{ @"notType": [UISwitch class] },
                                      @"message": @YES },
                               @"constraints":
                                   @[ @{ @"format": @"H:|-(pl)-[label]-(pr)-|" },
                                      @{ @"format": @"V:|-(pt)-[label]-(vs12)-[editor]-(>=vs23)-[message]-(pb)-|",
                                         @"options": @(NSLayoutFormatAlignAllLeading|NSLayoutFormatAlignAllTrailing)
                                         },
                                      @{ @"format": @"V:[editor]-(vs23@249)-[message]" },
                                      ]
                               },
                            @{ @"viewRequirements":
                                   @{ @"label":   @YES,
                                      @"editor":  @{ @"notType": [UISwitch class] },
                                      @"message": @NO },

                               @"constraints":
                                   @[ @{ @"format": @"H:|-(pl)-[label]-(pr)-|" },
                                      @{ @"format": @"V:|-(pt)-[label]-(vs12)-[editor]-(pb)-|",
                                         @"options": @(NSLayoutFormatAlignAllLeading|NSLayoutFormatAlignAllTrailing)
                                         }
                                      ]
                               }
                            ]
                     }];
    });
    return result;
}

#pragma mark - Automatic View Creation

- (BOOL)subviewSpecificationItem:(AKASubviewsSpecificationItem *)specification
         subviewNotFoundInTarget:(UIView *)containerView
                     createdView:(out UIView *__autoreleasing *)createdView
{
    BOOL result = NO;
    if (containerView == self)
    {
        if (specification.requirements.requirePresent)
        {
            if ([@"label" isEqualToString:specification.name])
            {
                result = [self autocreateLabel:createdView];
            }
            else if ([@"editor" isEqualToString:specification.name])
            {
                result = [self autocreateEditor:createdView];
            }
            else if ([@"message" isEqualToString:specification.name])
            {
                result = [self autocreateMessage:createdView];
            }
            else
            {
                AKALogError(@"Failed to create missing subview %@ in %@", specification.name, containerView);
            }
        }
    }
    if (result)
    {
        (*createdView).translatesAutoresizingMaskIntoConstraints = NO;
        if (self.themeName.length == 0)
        {
            // Set default theme to make sure layout is done.
            // Sine a view was missing and no theme was defined,
            // the layout cannot wotk otherwise.
            
            // TODO: use inherited/automatic theme instead of default
            //self.themeName = @"default";
        }
        AKALogDebug(@"Created missing subview %@ in %@", specification.name, containerView);
    }
    return result;
}

- (BOOL)autocreateLabel:(out UIView*__autoreleasing *)createdView
{
    BOOL result;
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
    result = label != nil;
    if (result)
    {
        label.text = self.labelText;
        *createdView = label;
    }
    return result;
}

- (BOOL)autocreateEditor:(out UIView*__autoreleasing *)createdView
{
    AKALogError(@"Attempt to automatically create an editor view. %@ requires an editor view to be present. Use more specific subclasses which can create their editor view instead.", self);
    return NO;
}

- (BOOL)autocreateMessage:(out UIView*__autoreleasing *)createdView
{
    BOOL result;
    AKALabel* errorMessageLabel = [[AKALabel alloc] initWithFrame:CGRectZero];
    result = errorMessageLabel != nil;
    if (result)
    {
        //errorMessageLabel.valueKeyPath = @"messageText";
        *createdView = errorMessageLabel;
    }
    return result;
}

@end

@implementation AKAEditorBindingConfiguration

- (Class)preferredBindingType
{
    return [AKAEditorBinding class];
}

- (Class)preferredViewType
{
    return [AKAEditorControlView class];
}

@end

@interface AKAEditorBinding()

@property(nonatomic, readonly)AKAEditorControlView* editorControlView;

@end

@implementation AKAEditorBinding

- (AKAEditorControlView *)editorControlView
{
    return (AKAEditorControlView*)self.view;
}

- (BOOL)managesValidationStateForContext:(id)validationContext view:(UIView *)view
{
    return (self.editorControlView.editor == view);
}

- (void)setValidationState:(NSError *)error
                   forView:(UIView *)view
         validationContext:(id)validationContext
{
    UILabel* messageLabel = self.editorControlView.messageLabel;
    if (messageLabel != nil)
    {
        messageLabel.text = error == nil ? @"" : error.localizedDescription;
    }
}

@end