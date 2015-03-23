//
//  AKATestView.m
//  AKAControlsDemo
//
//  Created by Michael Utech on 20.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATestView.h"

@interface AKATestView()

@property(nonatomic)BOOL subviewsCreated;
@property(nonatomic)BOOL subviewConstraintsCreated;
@property(nonatomic)NSDictionary* views;

@end

@implementation AKATestView

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setupAfterInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupAfterInit];
    }
    return self;
}

- (void)setupAfterInit
{
    self.autoresizesSubviews = NO;
    self.autoresizingMask = UIViewAutoresizingNone;
    [self createSubviews];
}

- (CGSize)intrinsicContentSize
{
    CGSize result = [super intrinsicContentSize];
    return result;
}

#if 0
- (void)createSubviews
{
    if (!self.subviewsCreated)
    {
        self.translatesAutoresizingMaskIntoConstraints = NO;

        UITextField* textField = [[UITextField alloc] initWithFrame:CGRectZero];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.placeholder = @"Enter some text";
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        self.autoresizingMask = UIViewAutoresizingNone;
        [self addSubview:textField];

        self.views = @{ @"editor": textField };
        self.subviewsCreated = YES;

        [self setNeedsUpdateConstraints];
    }
}

- (void)updateConstraints
{
    if (!self.subviewConstraintsCreated)
    {
        NSDictionary* metrics =
        @{ @"pt": @(4), @"pr": @(4), @"pb": @(4), @"pl": @(4),
           @"labelWidth": @(100),
           @"hsLabelEditor": @(4)
           };
        NSArray* specs =
        @[ @{ @"format": @"H:|-(pl)-[editor]-(pr)-|",
              @"options": @(0) },
           @{ @"format": @"V:|-(pt)-[editor]-(pb)-|",
              @"options": @(0) }
           ];
        for (NSDictionary* spec in specs)
        {
            NSString* format = spec[@"format"];
            NSUInteger options = ((NSNumber*)spec[@"options"]).unsignedIntegerValue;
            NSArray* constraints = [NSLayoutConstraint constraintsWithVisualFormat:format
                                                                           options:options
                                                                           metrics:metrics
                                                                             views:self.views];
            [self addConstraints:constraints];
        }

        self.subviewConstraintsCreated = YES;
    }
    [super updateConstraints];
}
#else
- (void)createSubviews
{
    if (!self.subviewsCreated)
    {
        self.translatesAutoresizingMaskIntoConstraints = NO;

        UILabel* labelView = [[UILabel alloc] initWithFrame:CGRectZero];
        labelView.text = @"Name";
        labelView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:labelView];

        UITextField* textField = [[UITextField alloc] initWithFrame:CGRectZero];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.placeholder = @"Enter some text";
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:textField];

        UILabel* errorMessageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        errorMessageLabel.text = @"Error message";
        errorMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:errorMessageLabel];

        self.views = @{ @"label": labelView, @"editor": textField, @"errorMessageLabel": errorMessageLabel };
        self.subviewsCreated = YES;

        [self setNeedsUpdateConstraints];
    }
}

- (void)updateConstraints
{
    if (!self.subviewConstraintsCreated)
    {
        NSDictionary* metrics =
        @{ @"pt": @(4), @"pr": @(4), @"pb": @(4), @"pl": @(4),
           @"labelWidth": @(100),
           @"errorPl": @(4 + 100 + 4),
           @"hsLabelEditor": @(4), @"vsEditorError": @(2)
           };
        NSArray* specs =
        @[ @{ @"format": @"H:|-(pl)-[label(labelWidth)]-(hsLabelEditor)-[editor]-(pr)-|",
              @"options": @(NSLayoutFormatAlignAllFirstBaseline) },
           @{ @"format": @"V:|-(pt)-[editor]-(vsEditorError)-[errorMessageLabel]-(pb)-|",
              @"options": @(NSLayoutFormatAlignAllLeading|NSLayoutFormatAlignAllTrailing) }
           ];
        for (NSDictionary* spec in specs)
        {
            NSString* format = spec[@"format"];
            NSUInteger options = ((NSNumber*)spec[@"options"]).unsignedIntegerValue;
            NSArray* constraints = [NSLayoutConstraint constraintsWithVisualFormat:format
                                                                           options:options
                                                                           metrics:metrics
                                                                             views:self.views];
            [self addConstraints:constraints];
        }

        self.subviewConstraintsCreated = YES;
    }
    [super updateConstraints];
}
#endif

- (void)layoutSubviews
{
    [super layoutSubviews];
    for (UIView* view in self.views.objectEnumerator)
    {
        [view setNeedsUpdateConstraints];
    }
}

@end
