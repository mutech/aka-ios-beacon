//
//  AKAEditorControlView.m
//  AKACommons
//
//  Created by Michael Utech on 15.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAEditorControlView.h"
#import "AKAControlViewProtocol.h"
#import "AKACompositeControlViewBinding.h"
#import "AKALabel.h"

#import "AKAControlsErrors.h"
#import "AKAProperty.h"

#import <AKACommons/AKALog.h>

@interface AKAEditorControlView()

@property(nonatomic, assign) BOOL setupActive;

@end

@implementation AKAEditorControlView

#pragma mark - Configuration

- (Class)preferredBindingType
{
    return [AKACompositeControlViewBinding class];
}

+ (AKASubviewsSpecification *)subviewsSpecification
{
    static dispatch_once_t token;
    static AKASubviewsSpecification* instance = nil;
    dispatch_once(&token, ^{
        instance = [[AKASubviewsSpecification alloc] initWithDictionary:
                    @{ @"label":
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
                              @"requirements": @{ @"type": [UILabel class] }
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
                                   @{ @"font": [UIFont systemFontOfSize:14.0 weight:UIFontWeightLight],
                                      @"textColor": [UIColor grayColor],
                                      @"numberOfLines": @(1),
                                      @"lineBreakMode": @(NSLineBreakByTruncatingTail)
                                      }
                               },
                            @{ @"view": @"editor",
                               @"requirements": @{ @"type": [UITextField class] },
                               @"properties":
                                   @{ @"font": [UIFont systemFontOfSize:14.0],
                                      @"backgroundColor": [UIColor whiteColor],
                                      @"borderStyle": @(UITextBorderStyleRoundedRect) }
                               },
                            @{ @"view": @"message",
                               @"requirements": @{ @"type": [UILabel class] },
                               @"font": [UIFont systemFontOfSize:10.0 weight:UIFontWeightLight],
                               @"textColor": [UIColor redColor]
                               },
                            ],

                     @"metrics": @{ @"pl":@(0), @"pr":@(0), @"pt":@(0), @"pb":@(0),
                                    @"vs":@(0), @"hs":@(4),
                                    @"labelWidth":@(80)},
                     @"layouts":
                         @[ @{ @"viewRequirements": @{ @"label": @YES, @"editor": @YES },
                               @"constraints":
                                   @[ @{ @"format": @"H:|-(pl)-[label(labelWidth)]-(hs)-[editor]-(pr)-|"
                                         },
                                      @{ @"format": @"V:|-(>=pt)-[label]-(>=pb)-|" }, // keep multiline label inside container view
                                      ]
                               },

                            // First baseline alignment if editor has baseline
                            @{ @"viewRequirements": @{ @"label": @YES,
                                                       @"editor": @{ @"type": @[ [UITextField class],
                                                                                 [UILabel class],
                                                                                 [UIButton class] ] } },
                               @"constraints":
                                   @[ @{  @"firstItem": @"editor",
                                          @"firstAttribute": @(NSLayoutAttributeFirstBaseline),
                                          @"secondItem": @"label",
                                          @"secondAttribute": @(NSLayoutAttributeFirstBaseline) },
                                      ]
                               },

                            // Center alignment if editor may not have baseline
                            @{ @"viewRequirements": @{ @"label": @YES,
                                                       @"editor": @{ @"notType": @[ [UITextField class],
                                                                                    [UILabel class] ] } },
                               @"constraints":
                                   @[ @{  @"firstItem": @"editor",
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
                                      @{ @"format": @"V:[message]-(pb@250)-|" },
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
                                   @{ @"font": [UIFont systemFontOfSize:16.0],
                                      @"backgroundColor": [UIColor colorWithWhite:1 alpha:0],
                                      @"borderStyle": @(UITextBorderStyleNone) }
                               },
                            @{ @"view": @"message",
                               @"requirements": @{ @"type": [UILabel class] },
                               @"properties":
                                   @{ @"font": [UIFont systemFontOfSize:9.0 weight:UIFontWeightLight],
                                      @"textColor": [UIColor redColor]
                                      }
                               },
                            ],
                     @"metrics": @{ @"pl":@(0), @"pr":@(0), @"pt":@(0), @"pb":@(0),
                                    @"vs12":@(0), @"vs23":@(0),
                                    @"hs":@(4) },
                     @"layouts":
                         @[ @{ @"viewRequirements": @{ @"label": @{ @"type": [UIView class] },
                                                       @"editor": @{ @"type": [UIView class] },
                                                       @"message": @{ @"type": [UIView class] } },
                               @"constraints":
                                   @[ @{ @"format": @"H:|-(pl)-[label]-(pr)-|" },
                                      @{ @"format": @"V:|-(pt)-[label]-(vs12)-[editor]-(vs23)-[message]-(pb)-|",
                                         @"options": @(NSLayoutFormatAlignAllLeading|NSLayoutFormatAlignAllTrailing)
                                         }
                                      ]
                               },
                            @{ @"viewRequirements": @{ @"label": @{ @"type": [UIView class] },
                                                       @"editor": @{ @"type": [UIView class] },
                                                       @"message": @{ @"notType": [UIView class] } },
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
                UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
                label.text = self.labelText;
                *createdView = label;
                result = YES;
            }
            else if ([@"editor" isEqualToString:specification.name])
            {
                AKALabel* editor = [[AKALabel alloc] initWithFrame:CGRectZero];
                editor.role = specification.name;
                editor.text = @"(Please add a subview and connect it to the editor outlet or choose a more specific implementation of AKAEditorControlView)";
            
                editor.numberOfLines = 0;
                editor.lineBreakMode = NSLineBreakByWordWrapping;
                editor.backgroundColor = [UIColor redColor];
                editor.textColor = [UIColor whiteColor];
                editor.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
                editor.textAlignment = NSTextAlignmentCenter;

                *createdView = editor;
                result = YES;
            }
            else if ([@"message" isEqualToString:specification.name])
            {
                AKALabel* errorMessageLabel = [[AKALabel alloc] initWithFrame:CGRectZero];
                errorMessageLabel.role = specification.name;

                //errorMessageLabel.valueKeyPath = @"messageText";

                *createdView = errorMessageLabel;
                result = YES;
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
        AKALogDebug(@"Created missing subview %@ in %@", specification.name, containerView);
    }
    return result;
}

@end
