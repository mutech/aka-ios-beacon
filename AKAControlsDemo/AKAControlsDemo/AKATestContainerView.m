//
//  AKATestContainerView.m
//  AKAControlsDemo
//
//  Created by Michael Utech on 20.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <AKACommons/UIView+AKAConstraintTools.h>
#import <AKAControls/AKATheme.h>
#import "AKATestContainerView.h"

@interface AKATestContainerView()

@end

@implementation AKATestContainerView

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)awakeFromNib
{
    // awakeFromNib is called when outlets are set. If at that point
    // the outlets are nil, default controls will be created here.
    [self autocreateMissingViews];
}

- (void)prepareForInterfaceBuilder
{
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

#pragma mark - Theme support

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

                     @"metrics": @{ @"pl":@(4), @"pr":@(4), @"pt":@(4), @"pb":@(4),
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
                               }
                            ]
                     }];
    });
    return result;
}

+ (NSDictionary*)builtinThemes
{
    return
    @{ @"default": [AKATestContainerView builtinDefaultTheme],
       @"tableview": [AKATestContainerView builtinTableViewTheme]
       };
}

- (void)autocreateMissingViews
{
    if (self.label == nil)
    {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = @"autocreated";
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:label];
        self.label = label;
    }
    if (self.editor == nil)
    {
        UITextField* editor = [[UITextField alloc] initWithFrame:CGRectZero];
        editor.text = @"autocreated";
        editor.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:editor];
        self.editor = editor;
    }
    if (self.errorMessageLabel == nil)
    {
        UILabel* errorMessageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        errorMessageLabel.text = @"autocreated";
        errorMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:errorMessageLabel];
        self.errorMessageLabel = errorMessageLabel;
    }
}

- (NSDictionary*)viewsParticipatingInTheme
{
    NSMutableDictionary* views = NSMutableDictionary.new;
    if (self.label) { views[@"label"] = self.label; }
    if (self.editor) { views[@"editor"] = self.editor; }
    if (self.errorMessageLabel) { views[@"errorMessageLabel"] = self.errorMessageLabel; }
    return views;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // Without this, baseline alignments with UITextField's will not work reliably.
    NSDictionary* views = [self viewsParticipatingInTheme];
    for (UIView* view in views.objectEnumerator)
    {
        // We could restrict update constraints to text fields, but we'll do this for
        // all views, just in case another view type also needs this:
        //if ([view isKindOfClass:[UITextField class]])
        //{
        [view setNeedsUpdateConstraints];
        [view updateConstraintsIfNeeded];
        //}
    }
}

@end
