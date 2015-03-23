//
//  AKATestContainerView.m
//  AKAControlsDemo
//
//  Created by Michael Utech on 20.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATestContainerView.h"
#import "UIView+AKAConstraintTools.h"

@interface AKATestContainerView()
@property(nonatomic) NSDictionary* themeChanges;
@end

@implementation AKATestContainerView

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

- (void)prepareForInterfaceBuilder
{
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

- (void)setTheme:(NSString *)theme
{
    if (theme != _theme && (theme == nil || ![theme isEqualToString:_theme]))
    {
        _theme = theme;
        // TODO: Testing, preserve original state:
        self.themeChanges = nil;
        [self setNeedsUpdateConstraints];
    }
}

- (NSDictionary*)selectedTheme
{
    NSDictionary* result = nil;
    NSString* theme = self.theme;
    if (theme.length > 0)
    {
        if ([@"none" isEqualToString:theme])
        {
            result = nil;
        }
        else
        {
            result = [self themes][theme];
        }
    }
    else
    {
        result = [self themes][@"default"];
    }
    return result;
}

- (NSDictionary*)themes
{
    return
    @{ @"default":
           @{ @"viewCustomization":
                  @{ @"label":
                         @{ @"font": [UIFont systemFontOfSize:14.0 weight:UIFontWeightLight],
                            @"textColor": [UIColor grayColor] },
                     @"editor":
                         @{ @"font": [UIFont systemFontOfSize:14.0],
                            @"borderStyle": @(UITextBorderStyleRoundedRect) },
                     @"errorMessageLabel":
                         @{ @"font": [UIFont systemFontOfSize:10.0 weight:UIFontWeightLight],
                            @"textColor": [UIColor redColor] },
                     },
              @"metrics": @{ @"pl":@(4), @"pr":@(4), @"pt":@(4), @"pb":@(4),
                             @"vs":@(0), @"hs":@(4),
                             @"labelWidth":@(60)},
              @"layouts":
                  @[ @{ @"requiredViews": @[ @"label", @"editor", @"errorMessageLabel" ],
                        @"constraints":
                            @[ @{ @"format": @"H:|-(pl)-[label(labelWidth)]-(hs)-[editor]-(pr)-|",
                                  @"options": @(NSLayoutFormatAlignAllFirstBaseline)
                                  },
                               @{ @"format": @"V:|-(pt)-[editor]-(vs)-[errorMessageLabel]-(>=pb)-|",
                                  @"options": @(NSLayoutFormatAlignAllLeading|NSLayoutFormatAlignAllTrailing)
                                  },
                               @{ @"format": @"V:|-(>=pt)-[label]-(>=pb)-|" }, // keep multiline label inside control
                               @{ @"format": @"V:[errorMessageLabel]-(pb@250)-|" }, // maintain vertical constraint chain (>=4 above creates warnings in IB)
                               ]
                        }
                     ]
              },
       @"tableview":
           @{ @"viewCustomization":
                  @{ @"label":
                         @{ @"font": [UIFont systemFontOfSize:10.0],
                            @"textColor": [UIColor grayColor] },
                     @"editor":
                         @{ @"font": [UIFont systemFontOfSize:16.0],
                            @"borderStyle": @(UITextBorderStyleNone)
                            },
                     @"errorMessageLabel":
                         @{ @"font": [UIFont systemFontOfSize:9.0 weight:UIFontWeightLight],
                            @"textColor": [UIColor redColor] },
                     },
              @"metrics": @{ @"pl":@(0), @"pr":@(0), @"pt":@(0), @"pb":@(0),
                             @"vs12":@(0), @"vs23":@(0),
                             @"hs":@(4) },
              @"layouts":
                  @[ @{ @"requiredViews": @[ @"label", @"editor", @"errorMessageLabel" ],
                        @"constraints":
                            @[ @{ @"format": @"H:|-(pl)-[label]-(pr)-|" },
                               @{ @"format": @"V:|-(pt)-[label]-(vs12)-[editor]-(vs23)-[errorMessageLabel]-(pb)-|",
                                  @"options": @(NSLayoutFormatAlignAllLeading|NSLayoutFormatAlignAllTrailing)
                                  }
                               ]
                        }
                     ]
              },
       @"old":
           @{ @"metrics": @{ @"pl":@(0), @"pr":@(0), @"pt":@(0), @"pb":@(0),
                             @"vs12":@(0), @"vs23":@(0),
                             @"hs":@(4),
                             @"labelWidth":@(60) },
              @"viewCustomization":
                  @{ @"label":
                         @{ @"font": [UIFont systemFontOfSize:14.0 weight:UIFontWeightLight],
                            //@"numberOfLines": @(0),
                            //@"lineBreakMode": @(NSLineBreakByWordWrapping)
                            },
                     @"editor":
                         @{ @"font": [UIFont systemFontOfSize:14.0 weight:UIFontWeightLight]
                            },
                     @"errorMessageLabel":
                         @{ @"font": [UIFont systemFontOfSize:10.0 weight:UIFontWeightLight],
                            @"textColor": [UIColor redColor]
                            }
                     },
              @"layouts":
                  @[
                      @{ @"requiredViews": @[ @"editor", @"label" ],
                         @"constraints":
                             @[  @{ @"format": @"V:|-(>=pt)-[label]-(>=pb)-|" },
                                 @{ @"format": @"H:|-(pl)-[label(labelWidth)]-(hs)-[editor]-(pr@750)-|", @"options": @(NSLayoutFormatAlignAllFirstBaseline) },
                                 @{ @"format": @"V:|-(pt)-[editor]-(pb)-|" },
                                 ]
                         },
                      @{ @"requiredViews": @[ @"editor", @"label", @"errorMessageLabel" ],
                         @"constraints":
                             @[
                                 @{ @"format": @"H:|-(pl)-[label(labelWidth)]-(hs)-[editor]-(pr)-|",
                                    @"options": @(NSLayoutFormatAlignAllFirstBaseline) },
                                 @{ @"format": @"V:|-(pt)-[editor]-(va)-[errorMessageLabel]-(pb)-|",
                                    @"options": @(NSLayoutFormatAlignAllLeft|NSLayoutFormatAlignAllRight) },
                                 @{ @"format": @"V:|-(>=pt)-[label]-(>=pb)-|" },
                                 ]
                         },
                      ]
              },
       };
}

- (NSDictionary*)viewsForConstraints
{
    NSMutableDictionary* views = NSMutableDictionary.new;
    if (self.label) { views[@"label"] = self.label; }
    if (self.editor) { views[@"editor"] = self.editor; }
    if (self.errorMessageLabel) { views[@"errorMessageLabel"] = self.errorMessageLabel; }
    return views;
}

- (void)updateConstraints
{
    if (self.customLayout && self.themeChanges == nil)
    {
        NSDictionary* theme = [self selectedTheme];
        if (theme != nil)
        {
            NSDictionary* views = [self viewsForConstraints];

            self.themeChanges = [self aka_applyTheme:theme toViews:views];
        }
    }

    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // Without this, baseline alignments with UITextField's will not work reliably.
    NSDictionary* views = [self viewsForConstraints];
    for (UIView* view in views.objectEnumerator)
    {
        // We could restrict update constraints to text fields, but we'll do this for
        // all views, just in case another view type also needs this:
        //if ([view isKindOfClass:[UITextField class]])
        //{
        [view setNeedsUpdateConstraints];
        //}
    }
}

@end
