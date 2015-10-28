//
//  AKAEditorControlView.m
//  AKACommons
//
//  Created by Michael Utech on 15.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKALog;

#import "AKAEditorControlView.h"
#import "AKAThemableContainerView_Protected.h"
#import "AKAControlViewProtocol.h"
#import "UITextView+AKAIBBindingProperties.h"
#import "UILabel+AKAIBBindingProperties.h"

#import "AKAControlsErrors.h"
#import "AKAProperty.h"

@interface AKAEditorControlView ()

@property(nonatomic, assign) BOOL setupActive;

@property(nonatomic, assign) BOOL readOnly;

@end

@implementation AKAEditorControlView

static NSString*const kEditorRole = @"editor";
static NSString*const kLabelRole = @"label";
static NSString*const kMessageRole = @"message";

#pragma mark - Initialization


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.labelTextBinding = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(labelTextBinding))];
        self.editorValueBinding = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(editorValueBinding))];
        self.themeName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(themeName))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:self.labelTextBinding forKey:NSStringFromSelector(@selector(labelTextBinding))];
    [coder encodeObject:self.editorValueBinding forKey:NSStringFromSelector(@selector(editorValueBinding))];
    [coder encodeObject:self.themeName forKey:NSStringFromSelector(@selector(themeName))];
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder
{
    AKAEditorControlView* result = [super awakeAfterUsingCoder:aDecoder];
    if (result.label)
    {
        [result setupLabel];
    }
    if (result.editor)
    {
        [result setupEditor];
    }
    if (result.messageLabel)
    {
        [result setupMessageLabel];
    }
    return result;
}

#pragma mark - Interface Builder Properties
/// @name Interface Builder Properties

@synthesize readOnly = _readOnly;
- (void)setReadOnly:(BOOL)readOnly
{
    _readOnly = readOnly;

    if (self.editor != nil)
    {
        self.editor.userInteractionEnabled = !readOnly;
    }
}

#pragma mark - Outlets

- (void)setEditor:(UIView*)editor
{
    _editor = editor;

    [self setupEditor];
}

- (void)setupEditor
{
    if ([self.editor conformsToProtocol:@protocol(AKAControlViewProtocol)])
    {
        UIView<AKAControlViewProtocol>* editor = ((UIView<AKAControlViewProtocol>*)self.editor);

        NSString* controlViewBindingKey = editor.aka_controlConfiguration[kAKAControlViewBinding];
        if (controlViewBindingKey.length > 0)
        {
            SEL selector = NSSelectorFromString(controlViewBindingKey);

            if ([editor respondsToSelector:selector])
            {
                [editor setValue:self.editorValueBinding forKey:controlViewBindingKey];
            }
        }

        [editor aka_setControlConfigurationValue:kEditorRole
                                          forKey:kAKAControlRoleKey];
    }
}

- (void)setLabel:(UILabel *)label
{
    _label = label;
    [self setupLabel];
}

- (void)setupLabel
{
    self.label.textBinding_aka = self.labelTextBinding;
    if ([self.label conformsToProtocol:@protocol(AKAControlViewProtocol)])
    {
        UIView<AKAControlViewProtocol>* label = ((UIView<AKAControlViewProtocol>*)self.label);

        [label aka_setControlConfigurationValue:kLabelRole
                                         forKey:kAKAControlRoleKey];
    }
}

- (void)setMessageLabel:(UILabel *)messageLabel
{
    _messageLabel = messageLabel;
    [self setupLabel];
}

- (void)setupMessageLabel
{
    if ([self.messageLabel conformsToProtocol:@protocol(AKAControlViewProtocol)])
    {
        UIView<AKAControlViewProtocol>* messageLabel = ((UIView<AKAControlViewProtocol>*)self.messageLabel);

        [messageLabel aka_setControlConfigurationValue:kMessageRole
                                                forKey:kAKAControlRoleKey];
    }
}

#pragma mark - Configuration

+ (AKASubviewsSpecification*)subviewsSpecification
{
    static dispatch_once_t token;
    static AKASubviewsSpecification* instance = nil;

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
                       }, }];
    });

    return instance;
}

+ (NSDictionary*)builtinThemes
{
    static dispatch_once_t token;
    static NSDictionary* instance = nil;

    dispatch_once(&token, ^{
        instance = @{ @"default": [self builtinDefaultTheme],
                      @"tableview": [self builtinTableViewTheme] };
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
                           @{ @"font": [UIFont systemFontOfSize:16.0
                                                         weight:UIFontWeightLight],
                              @"textColor": [UIColor grayColor],
                              @"numberOfLines": @(1),
                              @"lineBreakMode": @(NSLineBreakByTruncatingTail),
                              @"textAlignment": @(NSTextAlignmentLeft),
                              @"adjustsFontSizeToFitWidth": @YES,
                              @"minimumScaleFactor": @(.5f) }
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
                           @{ @"font": [UIFont systemFontOfSize:12.0
                                                         weight:UIFontWeightLight],
                              @"textColor": [UIColor redColor],
                              @"numberOfLines": @(0),
                              @"lineBreakMode": @(NSLineBreakByWordWrapping) }
                        },
                     ],
                     @"metrics": @{ @"pl": @(0), @"pr": @(0), @"pt": @(8), @"pb": @(8),
                                    @"vs": @(0), @"hs": @(4),
                                    @"labelWidth": @(100) },
                     @"layouts":
                     @[ @{ @"viewRequirements": @{ kLabelRole: @YES, kEditorRole: @YES },
                           @"constraints":
                           @[ @{ @"format": @"V:|-(>=pt)-[label]-(>=pb)-|" },         // keep multiline label inside container view
                              @{ @"format": @"V:|-(pt@249)-[label]-(pb@249)-|" }] },

                        // First baseline alignment if editor has baseline
                        @{ @"viewRequirements": @{ kLabelRole: @YES,
                                                   kEditorRole: @{ @"type": @[ [UITextField class],
                                                                               [UILabel class],
                                                                               [UIButton class] ] }
                           },
                           @"constraints":
                           @[ @{ @"format": @"H:|-(pl)-[label(labelWidth)]-(hs)-[editor]-(pr)-|" },
                              @{  @"firstItem": kEditorRole,
                                  @"firstAttribute": @(NSLayoutAttributeFirstBaseline),
                                  @"secondItem": kLabelRole,
                                  @"secondAttribute": @(NSLayoutAttributeFirstBaseline) },
                           ] },

                        // Use center alignment if editor may not have meaningful baseline
                        @{ @"viewRequirements": @{ kLabelRole: @YES,
                                                   kEditorRole: @{ @"notType": @[ [UITextField class],
                                                                                  [UILabel class],
                                                                                  [UIButton class] ] }
                           },
                           @"constraints":
                           @[ @{ @"format": @"H:|-(pl)-[label(labelWidth)]-(hs)-[editor]-(>=pr)-|" },
                              @{ @"format": @"H:[editor]-(pr@249)-|" },         // avoid inequality ambiguities
                              @{ @"firstItem": kEditorRole,
                                 @"firstAttribute": @(NSLayoutAttributeCenterY),
                                 @"secondItem": kLabelRole,
                                 @"secondAttribute": @(NSLayoutAttributeCenterY) },
                           ] },

                        // For layout with message view:
                        @{ @"viewRequirements": @{ kLabelRole: @YES, kEditorRole: @YES, kMessageRole: @YES },
                           @"constraints":
                           @[ @{ @"format": @"V:|-(pt)-[editor]-(vs)-[message]-(>=pb)-|",
                                 @"options":
                                 @(NSLayoutFormatAlignAllLeading | NSLayoutFormatAlignAllTrailing) },
                              @{ @"format": @"V:[message]-(pb@249)-|" },
                           ] },
                        // For layout without message view
                        @{ @"viewRequirements": @{ kLabelRole: @YES, kEditorRole: @YES, kMessageRole: @NO },
                           @"constraints":
                           @[ @{ @"format": @"V:|-(pt)-[editor]-(>=pb)-|",
                                 @"options": @(NSLayoutFormatAlignAllLeading | NSLayoutFormatAlignAllTrailing) },
                           ] },
                     ] }];
    });

    return result;
}

+ (AKATheme*)builtinTableViewTheme
{
    static dispatch_once_t token;
    static AKATheme* result = nil;

    dispatch_once(&token, ^{
        result =
            [AKATheme themeWithDictionary:
             @{ @"viewCustomization":
                @[ @{ @"view": kLabelRole,
                      @"requirements": @{ @"type": [UILabel class] },
                      @"properties":
                      @{ @"font": [UIFont systemFontOfSize:12.0],
                         @"textColor": [UIColor grayColor],
                         @"numberOfLines": @(1),
                         @"lineBreakMode": @(NSLineBreakByTruncatingTail) }
                   },
                   @{ @"view": kEditorRole,
                      @"requirements": @{ @"type": [UITextField class] },
                      @"properties":
                      @{ @"font": [UIFont systemFontOfSize:18.0],
                         @"backgroundColor": [UIColor colorWithWhite:1
                                                               alpha:0],
                         @"borderStyle": @(UITextBorderStyleNone) }
                   },
                   @{ @"view": kMessageRole,
                      @"requirements": @{ @"type": [UILabel class] },
                      @"properties":
                      @{ @"font": [UIFont systemFontOfSize:10.0
                                                    weight:UIFontWeightLight],
                         @"textColor": [UIColor redColor],
                         @"numberOfLines": @(0),
                         @"lineBreakMode": @(NSLineBreakByWordWrapping) }
                   },
                ],
                @"metrics": @{ @"pl": @(0), @"pr": @(0), @"pt": @(4), @"pb": @(4),
                               @"vs12": @(2), @"vs23": @(0),
                               @"hs": @(4) },
                @"layouts":
                @[ @{ @"viewRequirements":
                      @{ kLabelRole:   @YES,
                         kEditorRole:  @{ @"type": [UISwitch class] },
                         kMessageRole: @YES },
                      @"constraints":
                      @[ @{ @"format": @"H:|-(pl)-[label]-(>=hs)-[editor]-(pr)-|",
                            @"options": @(NSLayoutFormatAlignAllTop) },
                         @{ @"format": @"H:|-(pl)-[message]-(>=hs)-[editor]-(pr)-|",
                            @"options": @(NSLayoutFormatAlignAllBottom) },
                         @{ @"format": @"V:[label]-(vs12)-[message]" },
                         @{ @"format": @"V:|-(>=pt)-[editor]-(>=pb)-|" },
                         @{ @"format": @"V:|-(pt@249)-[editor]-(pb@249)-|" },
                         @{ @"firstItem": kEditorRole,
                            @"firstAttribute": @(NSLayoutAttributeCenterY),
                            @"secondItem": @"self",
                            @"secondAttribute": @(NSLayoutAttributeCenterY) }
                      ] },
                   @{ @"viewRequirements":
                      @{ kLabelRole:   @YES,                 // short for @{@"present": @YES}
                         kEditorRole:  @{ @"type": [UISwitch class] },
                         kMessageRole: @NO },                // short for @{@"absent": @YES}
                      @"constraints":
                      @[ @{ @"format": @"H:|-(pl)-[label]-(>=hs)-[editor]-(pr)-|",
                            @"options": @(NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom) },
                         @{ @"format": @"V:|-(pt)-[editor]-(pb)-|" },
                         @{ @"firstItem": kEditorRole,
                            @"firstAttribute": @(NSLayoutAttributeCenterY),
                            @"secondItem": @"self",
                            @"secondAttribute": @(NSLayoutAttributeCenterY) }
                      ] },
                   @{ @"viewRequirements":
                      @{ kEditorRole:  @{ @"type": [UISwitch class] }
                      },
                      @"viewCustomization":
                      @[ @{ @"view": kLabelRole,
                            @"requirements": @{ @"type": [UILabel class] },
                            @"properties":
                            @{ @"font": [UIFont systemFontOfSize:14.0] }
                         } ] },

                   @{ @"viewRequirements":
                      @{ kLabelRole:   @YES,
                         kEditorRole:  @{ @"notType": [UISwitch class] },
                         kMessageRole: @YES },
                      @"constraints":
                      @[ @{ @"format": @"H:|-(pl)-[label]-(pr)-|" },
                         @{ @"format": @"V:|-(pt)-[label]-(vs12)-[editor]-(>=vs23)-[message]-(pb)-|",
                            @"options": @(NSLayoutFormatAlignAllLeading | NSLayoutFormatAlignAllTrailing) },
                         @{ @"format": @"V:[editor]-(vs23@249)-[message]" },
                      ] },
                   @{ @"viewRequirements":
                      @{ kLabelRole:   @YES,
                         kEditorRole:  @{ @"notType": [UISwitch class] },
                         kMessageRole: @NO },

                      @"constraints":
                      @[ @{ @"format": @"H:|-(pl)-[label]-(pr)-|" },
                         @{ @"format": @"V:|-(pt)-[label]-(vs12)-[editor]-(pb)-|",
                            @"options": @(NSLayoutFormatAlignAllLeading | NSLayoutFormatAlignAllTrailing) }
                      ] }
                ] }];
    });

    return result;
}

#pragma mark - Interface Builder Properties

@synthesize labelTextBinding = _labelTextBinding;

- (NSString*)labelTextBinding
{
    return _labelTextBinding;
}

- (void)setLabelTextBinding:(NSString*)labelTextBinding
{
    _labelTextBinding = labelTextBinding;
}

#pragma mark - Automatic View Creation

- (BOOL)subviewSpecificationItem:(AKASubviewsSpecificationItem*)specification
         subviewNotFoundInTarget:(UIView*)containerView
                     createdView:(out UIView* __autoreleasing*)createdView
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
            }
            else if ([kEditorRole isEqualToString:specification.name])
            {
                result = [self autocreateEditor:&newView];
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
                UIView<AKAControlViewProtocol>* controlView = (UIView<AKAControlViewProtocol>*)newView;
                [controlView aka_setControlConfigurationValue:specification.name
                                                       forKey:kAKAControlRoleKey];
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

- (BOOL)autocreateLabel:(out UIView* __autoreleasing*)createdView
{
    BOOL result;
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];

    result = label != nil;

    if (result)
    {
        *createdView = label;
    }

    return result;
}

- (BOOL)autocreateEditor:(out UIView* __autoreleasing*)createdView
{
    (void)createdView;
    AKALogError(@"Attempt to automatically create an editor view. %@ requires an editor view to be present. You can add an editor view on the storyboard and connect it to the editor outlet. Alternatively, you can use a subclass of AKAEditorControlView which can create its editor view automatically.", self);

    return NO;
}

- (BOOL)autocreateMessage:(out UIView* __autoreleasing*)createdView
{
    BOOL result;
    UILabel* errorMessageLabel = [[UILabel alloc] initWithFrame:CGRectZero];

    result = errorMessageLabel != nil;

    if (result)
    {
        //errorMessageLabel.valueKeyPath = @"messageText";
        *createdView = errorMessageLabel;
    }

    return result;
}

@end
