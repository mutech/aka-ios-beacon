//
//  AKAEditorControlView.m
//  AKACommons
//
//  Created by Michael Utech on 15.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAEditorControlView.h"
#import "AKAThemableContainerView_Protected.h"

#import "AKAViewBindingConfiguration.h"
#import "AKATextLabel.h"

#import "AKAControlsErrors.h"
#import "AKAProperty.h"

#import "UIView+AKABinding.h"

@import AKACommons.AKALog;

@interface AKAEditorControlView()

@property(nonatomic, assign) BOOL setupActive;

@end

@implementation AKAEditorControlView

static NSString* const kEditorRole = @"editor";
static NSString* const kLabelRole = @"label";
static NSString* const kMessageRole = @"message";

#pragma mark - Initialization
#pragma mark -

#pragma mark - Binding Configuration
/// @name Binding configuration

- (AKAEditorBindingConfiguration*)bindingConfiguration
{
    return (AKAEditorBindingConfiguration*)super.bindingConfiguration;
}

- (AKAEditorBindingConfiguration*)createBindingConfiguration
{
    return AKAEditorBindingConfiguration.new;
}

#pragma mark - Interface Builder Properties
/// @name Interface Builder Properties

- (void)setReadOnly:(BOOL)readOnly
{
    super.readOnly = readOnly;
    if ([self.editor conformsToProtocol:@protocol(AKAControlConfigurationProtocol)])
    {
        UIView <AKAControlConfigurationProtocol> *controlView = (id) self.editor;
        controlView.readOnly = readOnly;
    }
    else if (self.editor != nil)
    {
        self.editor.userInteractionEnabled = !readOnly;
    }
}

- (NSString *)labelText
{
    return self.bindingConfiguration.labelText;
}
- (void)setLabelText:(NSString *)labelText
{
    self.bindingConfiguration.labelText = labelText;
}

- (NSString *)labelKeyPath
{
    return self.bindingConfiguration.labelKeyPath;
}
- (void)setLabelKeyPath:(NSString *)labelKeyPath
{
    self.bindingConfiguration.labelKeyPath = labelKeyPath;
}

- (NSString *)editorKeyPath
{
    return self.bindingConfiguration.editorKeyPath;
}
- (void)setEditorKeyPath:(NSString*)editorKeyPath
{
    self.bindingConfiguration.editorKeyPath = editorKeyPath;
}

#pragma mark - Outlets

- (void)setEditor:(UIView *)editor
{
    _editor = editor;

    if ([editor conformsToProtocol:@protocol(AKAControlViewProtocol)])
    {
        ((UIView<AKAControlViewProtocol>*)editor).bindingConfiguration.role = @"editor";
    }
    // TODO: consider doing this, if configurations are applied before outlets are set:
    
    // Ensure that read only setting is applied to editor view, if the outlet is initialized after
    // readOnly configuration is applied.
    // Problem is, that this would always override storyboard configurations of userInteraction,
    // which might not be a good idea.
    [self setReadOnly:self.readOnly];
}

#pragma mark - Configuration

+ (AKASubviewsSpecification *)subviewsSpecification
{
    static dispatch_once_t token;
    static AKASubviewsSpecification* instance = nil;
// Selectors used below are instance selectors and for this reason probably
// not defined in a class method. Ignore the warning
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
    dispatch_once(&token, ^{
        instance = [[AKASubviewsSpecification alloc] initWithDictionary:
                    @{ @"self":
                           @{ @"requirements": @{ @"present": @YES,
                                                  @"type": [AKAEditorControlView class] }
                              },
                       kLabelRole:
                           @{ @"outlet": NSStringFromSelector(@selector(label)),
                              @"viewTag": @1,
                              @"requirements": @{ @"present": @YES,
                                                  @"type": [UILabel class] }
                              },
                       kEditorRole:
                           @{ @"outlet": NSStringFromSelector(@selector(editor)),
                              @"viewTag": @2,
                              @"requirements": @{ @"present": @YES,
                                                  @"type": [UIView class] }
                              },
                       kMessageRole:
                           @{ @"outlet": NSStringFromSelector(@selector(messageLabel)),
                              @"viewTag": @3,
                              @"requirements": @{ @"present": @YES,
                                                  @"type": [UILabel class] }
                              },
                       }];
    });
#pragma clang diagnostic pop
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
                         @[ @{ @"view": kLabelRole,
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
                            @{ @"view": kEditorRole,
                               @"requirements": @{ @"type": [UITextField class] },
                               @"properties":
                                   @{ @"font": [UIFont systemFontOfSize:16.0],
                                      @"backgroundColor": [UIColor whiteColor],
                                      @"borderStyle": @(UITextBorderStyleRoundedRect) }
                               },
                            @{ @"view": kMessageRole,
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
                         @[ @{ @"viewRequirements": @{ kLabelRole: @YES, kEditorRole: @YES },
                               @"constraints":
                                   @[ @{ @"format": @"V:|-(>=pt)-[label]-(>=pb)-|" }, // keep multiline label inside container view
                                      @{ @"format": @"V:|-(pt@249)-[label]-(pb@249)-|" }]
                               },

                            // First baseline alignment if editor has baseline
                            @{ @"viewRequirements": @{ kLabelRole: @YES,
                                                       kEditorRole: @{ @"type": @[ [UITextField class],
                                                                                 [UILabel class],
                                                                                 [UIButton class] ] } },
                               @"constraints":
                                   @[ @{ @"format": @"H:|-(pl)-[label(labelWidth)]-(hs)-[editor]-(pr)-|" },
                                      @{  @"firstItem": kEditorRole,
                                          @"firstAttribute": @(NSLayoutAttributeFirstBaseline),
                                          @"secondItem": kLabelRole,
                                          @"secondAttribute": @(NSLayoutAttributeFirstBaseline) },
                                      ]
                               },

                            // Center alignment if editor may not have baseline
                            @{ @"viewRequirements": @{ kLabelRole: @YES,
                                                       kEditorRole: @{ @"notType": @[ [UITextField class],
                                                                                    [UILabel class],
                                                                                    [UIButton class] ] } },
                               @"constraints":
                                   @[ @{ @"format": @"H:|-(pl)-[label(labelWidth)]-(hs)-[editor]-(>=pr)-|" },
                                      @{ @"format": @"H:[editor]-(pr@249)-|" }, // avoid inequality ambiguities
                                      @{ @"firstItem": kEditorRole,
                                         @"firstAttribute": @(NSLayoutAttributeCenterY),
                                         @"secondItem": kLabelRole,
                                         @"secondAttribute": @(NSLayoutAttributeCenterY) },
                                      ]
                               },

                            // For layout with message view:
                            @{ @"viewRequirements": @{ kLabelRole: @YES, kEditorRole: @YES, kMessageRole: @YES },
                               @"constraints":
                                   @[ @{ @"format": @"V:|-(pt)-[editor]-(vs)-[message]-(>=pb)-|",
                                         @"options":
                                             @(NSLayoutFormatAlignAllLeading|NSLayoutFormatAlignAllTrailing)
                                         },
                                      @{ @"format": @"V:[message]-(pb@249)-|" },
                                      ]
                               },
                            // For layout without message view
                            @{ @"viewRequirements": @{ kLabelRole: @YES, kEditorRole: @YES, kMessageRole: @NO },
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
                         @[ @{ @"view": kLabelRole,
                               @"requirements": @{ @"type": [UILabel class] },
                               @"properties":
                                   @{ @"font": [UIFont systemFontOfSize:12.0],
                                      @"textColor": [UIColor grayColor],
                                      @"numberOfLines": @(1),
                                      @"lineBreakMode": @(NSLineBreakByTruncatingTail)
                                      }
                               },
                            @{ @"view": kEditorRole,
                               @"requirements": @{ @"type": [UITextField class] },
                               @"properties":
                                   @{ @"font": [UIFont systemFontOfSize:18.0],
                                      @"backgroundColor": [UIColor colorWithWhite:1 alpha:0],
                                      @"borderStyle": @(UITextBorderStyleNone) }
                               },
                            @{ @"view": kMessageRole,
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
                                   @{ kLabelRole:   @YES,
                                      kEditorRole:  @{ @"type": [UISwitch class] },
                                      kMessageRole: @YES },
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
                                      @{ @"firstItem": kEditorRole,
                                         @"firstAttribute": @(NSLayoutAttributeCenterY),
                                         @"secondItem": @"self",
                                         @"secondAttribute": @(NSLayoutAttributeCenterY) }
                                      ] },
                            @{ @"viewRequirements":
                                   @{ kLabelRole:   @YES,             // short for @{@"present": @YES}
                                      kEditorRole:  @{ @"type": [UISwitch class] },
                                      kMessageRole: @NO },            // short for @{@"absent": @YES}
                               @"constraints":
                                   @[ @{ @"format": @"H:|-(pl)-[label]-(>=hs)-[editor]-(pr)-|",
                                         @"options": @(NSLayoutFormatAlignAllTop|NSLayoutFormatAlignAllBottom)
                                         },
                                      @{ @"format": @"V:|-(pt)-[editor]-(pb)-|"
                                         },
                                      @{ @"firstItem": kEditorRole,
                                         @"firstAttribute": @(NSLayoutAttributeCenterY),
                                         @"secondItem": @"self",
                                         @"secondAttribute": @(NSLayoutAttributeCenterY) }
                                      ] },
                            @{ @"viewRequirements":
                                   @{ kEditorRole:  @{ @"type": [UISwitch class] } },
                               @"viewCustomization":
                                   @[ @{ @"view": kLabelRole,
                                         @"requirements": @{ @"type": [UILabel class] },
                                         @"properties":
                                             @{ @"font": [UIFont systemFontOfSize:14.0] } } ]
                               },

                            @{ @"viewRequirements":
                                   @{ kLabelRole:   @YES,
                                      kEditorRole:  @{ @"notType": [UISwitch class] },
                                      kMessageRole: @YES },
                               @"constraints":
                                   @[ @{ @"format": @"H:|-(pl)-[label]-(pr)-|" },
                                      @{ @"format": @"V:|-(pt)-[label]-(vs12)-[editor]-(>=vs23)-[message]-(pb)-|",
                                         @"options": @(NSLayoutFormatAlignAllLeading|NSLayoutFormatAlignAllTrailing)
                                         },
                                      @{ @"format": @"V:[editor]-(vs23@249)-[message]" },
                                      ]
                               },
                            @{ @"viewRequirements":
                                   @{ kLabelRole:   @YES,
                                      kEditorRole:  @{ @"notType": [UISwitch class] },
                                      kMessageRole: @NO },

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
    UIView* newView = nil;
    if (containerView == self)
    {
        if (specification.requirements.requirePresent)
        {
            if ([kLabelRole isEqualToString:specification.name])
            {
                result = [self autocreateLabel:&newView];
                if (result)
                {
                    if ([newView isKindOfClass:[UILabel class]])
                    {
                        UILabel* label = (UILabel*)newView;
                        label.text = self.labelText;
                    }
                    if ([newView conformsToProtocol:@protocol(AKAControlViewProtocol)])
                    {
                        ((UIView<AKAControlViewProtocol>*)newView).bindingConfiguration.valueKeyPath = self.labelKeyPath;
                    }
                }
            }
            else if ([kEditorRole isEqualToString:specification.name])
            {
                result = [self autocreateEditor:&newView];
                if ([newView conformsToProtocol:@protocol(AKAControlViewProtocol)])
                {
                    UIView<AKAControlViewProtocol>* editor =
                    ((UIView<AKAControlViewProtocol>*)newView);
                    editor.bindingConfiguration.valueKeyPath = self.editorKeyPath;
                    editor.bindingConfiguration.validatorKeyPath = self.validatorKeyPath;
                    editor.bindingConfiguration.converterKeyPath = self.converterKeyPath;
                }
            }
            else if ([kMessageRole isEqualToString:specification.name])
            {
                result = [self autocreateMessage:&newView];
            }
            else
            {
                AKALogError(@"Failed to create missing subview %@ in %@", specification.name, containerView);
            }
        }
    }
    if (result)
    {
        if (createdView != nil)
        {
            *createdView = newView;
        }
        if (newView != nil)
        {
            if ([newView conformsToProtocol:@protocol(AKAControlViewProtocol)])
            {
                ((UIView<AKAControlViewProtocol>*)newView).bindingConfiguration.role =
                    specification.name;
            }
        }
        (newView).translatesAutoresizingMaskIntoConstraints = NO;
        if (self.themeName.length == 0)
        {
            // Set default theme to make sure layout is done.
            // Sine a view was missing and no theme was defined,
            // the layout cannot wotk otherwise.
            
            // TODO: use inherited/automatic theme instead of default
            //self.themeName = @"default";
        }
        //AKALogDebug(@"Created missing subview %@ in %@", specification.name, containerView);
    }
    return result;
}

- (BOOL)autocreateLabel:(out UIView*__autoreleasing *)createdView
{
    BOOL result;
    AKATextLabel* label = [[AKATextLabel alloc] initWithFrame:CGRectZero];
    result = label != nil;
    if (result)
    {
        *createdView = label;
    }
    return result;
}

- (BOOL)autocreateEditor:(out UIView*__autoreleasing *)createdView
{
    AKALogError(@"Attempt to automatically create an editor view. %@ requires an editor view to be present. You can add an editor view on the storyboard and connect it to the editor outlet. Alternatively, you can use a subclass of AKAEditorControlView which can create its editor view automatically.", self);
    return NO;
}

- (BOOL)autocreateMessage:(out UIView*__autoreleasing *)createdView
{
    BOOL result;
    AKATextLabel* errorMessageLabel = [[AKATextLabel alloc] initWithFrame:CGRectZero];
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

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder])
    {
        self.editorKeyPath = [decoder decodeObjectForKey:@"editorKeyPath"];
        self.labelText = [decoder decodeObjectForKey:@"labelText"];
        self.labelKeyPath = [decoder decodeObjectForKey:@"labelKeyPath"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.editorKeyPath forKey:@"editorKeyPath"];
    [coder encodeObject:self.labelText forKey:@"labelText"];
    [coder encodeObject:self.labelKeyPath forKey:@"labelKeyPath"];
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
