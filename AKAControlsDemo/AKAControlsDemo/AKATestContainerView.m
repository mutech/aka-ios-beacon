//
//  AKATestContainerView.m
//  AKAControlsDemo
//
//  Created by Michael Utech on 20.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATestContainerView.h"
#import <AKAControls/AKAThemableContainerView_Protected.h>

#import <AKACommons/UIView+AKAConstraintTools.h>

@interface AKATestContainerView()

@end

@implementation AKATestContainerView

#pragma mark - Initialization

#pragma mark - Configuration

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
                       @"errorMessageLabel":
                           @{ @"outlet": [NSString stringWithUTF8String:sel_getName(@selector(errorMessageLabel))],
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
                            @{ @"view": @"errorMessageLabel",
                               @"requirements": @{ @"type": [UILabel class] },
                               @"font": [UIFont systemFontOfSize:10.0 weight:UIFontWeightLight],
                               @"textColor": [UIColor redColor]
                               },
                            ],

                     @"metrics": @{ @"pl":@(0), @"pr":@(0), @"pt":@(0), @"pb":@(0),
                                    @"vs":@(0), @"hs":@(4),
                                    @"labelWidth":@(80)},
                     @"layouts":
                         @[ @{ @"viewRequirements": // Common constraints:
                               @{ @"label": @YES, @"editor": @YES, @"errorMessageLabel": @YES
                                  },
                               @"constraints":
                                   @[ @{ @"format": @"H:|-(pl)-[label(labelWidth)]-(hs)-[editor]-(pr)-|"
                                         },
                                      @{ @"format": @"V:|-(pt)-[editor]-(vs)-[errorMessageLabel]-(>=pb)-|",
                                         @"options": @(NSLayoutFormatAlignAllLeading|NSLayoutFormatAlignAllTrailing)
                                         },
                                      @{ @"format": @"V:|-(>=pt)-[label]-(>=pb)-|" }, // keep multiline label inside container view
                                      @{ @"format": @"V:[errorMessageLabel]-(pb@250)-|" }, // maintain vertical constraint chain (>=pb above creates warnings in IB)
                                      ]
                               },
                            @{ @"viewRequirements": // First baseline alignment if editor has baseline
                               @{ @"label": @YES,
                                  @"editor": @{ @"type": @[ [UITextField class], [UILabel class], [UIButton class] ] },
                                  @"errorMessageLabel": @YES
                                  },
                               @"constraints":
                                   @[ @{  @"firstItem": @"editor",
                                          @"firstAttribute": @(NSLayoutAttributeFirstBaseline),
                                          @"secondItem": @"label",
                                          @"secondAttribute": @(NSLayoutAttributeFirstBaseline) },
                                      ]
                               },
                            @{ @"viewRequirements": // Center alignment if editor may not have baseline
                               @{ @"label": @YES,
                                  @"editor": @{ @"notType": @[ [UITextField class], [UILabel class] ] },
                                  @"errorMessageLabel": @YES
                                  },
                               @"constraints":
                                   @[ @{  @"firstItem": @"editor",
                                          @"firstAttribute": @(NSLayoutAttributeCenterY),
                                          @"secondItem": @"label",
                                          @"secondAttribute": @(NSLayoutAttributeCenterY) },
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
                            @{ @"view": @"errorMessageLabel",
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
                                                       @"errorMessageLabel": @{ @"type": [UIView class] } },
                               @"constraints":
                                   @[ @{ @"format": @"H:|-(pl)-[label]-(pr)-|" },
                                      @{ @"format": @"V:|-(pt)-[label]-(vs12)-[editor]-(vs23)-[errorMessageLabel]-(pb)-|",
                                         @"options": @(NSLayoutFormatAlignAllLeading|NSLayoutFormatAlignAllTrailing)
                                         }
                                      ]
                               },
                            @{ @"viewRequirements": @{ @"label": @{ @"type": [UIView class] },
                                                       @"editor": @{ @"type": [UIView class] },
                                                       @"errorMessageLabel": @{ @"notType": [UIView class] } },
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

#pragma mark - Subviews Setup

- (BOOL)subviewSpecificationItem:(AKASubviewsSpecificationItem *)specification
         subviewNotFoundInTarget:(UIView *)containerView
                     createdView:(out UIView *__autoreleasing *)createdView
{
    BOOL result = NO;
    if (containerView == self)
    {
        if ([@"label" isEqualToString:specification.name])
        {
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.text = @"autocreated";
            label.translatesAutoresizingMaskIntoConstraints = NO;
            *createdView = label;
            result = YES;
        }
        else if ([@"editor" isEqualToString:specification.name])
        {
            UITextField* editor = [[UITextField alloc] initWithFrame:CGRectZero];
            editor.text = @"autocreated";
            editor.translatesAutoresizingMaskIntoConstraints = NO;
            *createdView = editor;
            result = YES;
        }
        else if ([@"errorMessageLabel" isEqualToString:specification.name])
        {
            UILabel* errorMessageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            errorMessageLabel.text = @"autocreated";
            errorMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
            *createdView = errorMessageLabel;
            result = YES;
        }
    }
    return result;
}

@end
