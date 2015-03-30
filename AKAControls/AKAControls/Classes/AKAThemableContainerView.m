//
//  AKAThemableContainerView.m
//  AKAControls
//
//  Created by Michael Utech on 27.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAThemableContainerView_Protected.h"
#import "AKATheme.h"
#import "AKASubviewsSpecification.h"

#import <AKACommons/AKAErrors.h>

@interface AKAThemableContainerView()

@property(nonatomic) AKATheme* restorationTheme;
@property(nonatomic) BOOL needsApplySelectedTheme;
@property(nonatomic) NSMutableSet* subviewsNeedingUpdateConstraintsFromLayoutSubviews;

@end

@implementation AKAThemableContainerView

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setupDefaultValues];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupDefaultValues];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setupDefaultValues];
    }
    return self;
}

- (void)awakeFromNib
{
    // awakeFromNib is called when outlets are set. If at that point
    // the outlets are nil, default controls will be created here.
    [self valdiateAndSetupSubviews];
}

- (void)prepareForInterfaceBuilder
{
    if (self.IBEnablePreview)
    {
        [self valdiateAndSetupSubviews];
    }
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

/*
- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
    if (!self.setupActive)
    {
        [self setNeedsUpdateConstraints];
    }
}

- (void)willRemoveSubview:(UIView *)subview
{
    [super willRemoveSubview:subview];
    if (!self.setupActive)
    {
        [self setNeedsUpdateConstraints];
    }
}
 

- (void)modifyViewHierarchy:(void(^)())block
{
    // Prevent calls to setNeedsUpdateConstraints in didAdd/willRemoveSubview:
    BOOL setupWasActive = self.setupActive;
    self.setupActive = YES;
    block();
    self.setupActive = setupWasActive;
}
*/

- (void)setupDefaultValues
{
    self.subviewsNeedingUpdateConstraintsFromLayoutSubviews = NSMutableSet.new;
    if (self.themeName == nil)
    {
        self.themeName = AKAThemeNameNone;
    }
    self.IBEnablePreview = NO;
}

#pragma mark - Configuration

+ (AKASubviewsSpecification*)subviewsSpecification
{
    AKAErrorAbstractMethodImplementationMissing();
}

+ (NSDictionary*)builtinThemes
{
    AKAErrorAbstractMethodImplementationMissing();
}

#pragma mark -

- (NSDictionary*)viewsParticipatingInTheme
{
    return [[self.class subviewsSpecification] viewsDictionaryForTarget:self];
}

- (BOOL)valdiateAndSetupSubviews
{
    return [[self.class subviewsSpecification] validateTarget:self
                                                 withDelegate:self
                                                  fixProblems:YES];
}

- (void)setThemeName:(NSString *)themeName
{
    if (themeName != _themeName && (themeName == nil || ![themeName isEqualToString:_themeName]))
    {
        _themeName = themeName;
        if (self.restorationTheme || ![AKAThemeNameNone isEqualToString:themeName])
        {
            // Apply needed unless none is selected and there is no restoration theme.
            [self setNeedsApplySelectedTheme];
        }
    }
}

- (AKATheme*)selectedTheme
{
    AKATheme* result = nil;
    NSString* theme = self.themeName;
    if (theme.length == 0 || [AKAThemeNameNone isEqualToString:theme])
    {
        // This is nil if no other theme has been applied before, leaving the
        // state of the view hierarchy unchanged. Otherwise the old state can
        // be restored using the saved restoration theme.
        result = self.restorationTheme;
    }
    else
    {
        result = ([self.class builtinThemes])[theme];
    }
    return result;
}

- (void)setNeedsApplySelectedTheme
{
    self.needsApplySelectedTheme = YES;
    [self setNeedsUpdateConstraints];
}

- (void)applySelectedThemeIfNeeded
{
    if (self.needsApplySelectedTheme)
    {
        self.needsApplySelectedTheme = NO;
        AKATheme* theme = [self selectedTheme];
        if (theme != nil)
        {
            NSDictionary* views = [self viewsParticipatingInTheme];
            if (self.restorationTheme != nil)
            {
                [theme applyToTarget:self
                           withViews:views
                            delegate:self];
            }
            else
            {
                AKAThemeChangeRecorderDelegate* delegate = [[AKAThemeChangeRecorderDelegate alloc] initWithDelegate:self];
                [theme applyToTarget:self
                           withViews:views
                            delegate:delegate];
                self.restorationTheme = delegate.recordedTheme;
            }
        }
    }
}

- (void)subviewNeedsUpdateConstraintsInLayoutSubviews:(UIView*)view
{
    [self.subviewsNeedingUpdateConstraintsFromLayoutSubviews addObject:view];
}

- (void)constraintSpecification:(AKALayoutConstraintSpecification *)constraintSpecification
          didInstallConstraints:(NSArray *)nsLayoutConstraints
                       inTarget:(UIView *)target
{
    if (target == self)
    {
        [nsLayoutConstraints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSLayoutConstraint* constraint = obj;
            switch (constraint.firstAttribute)
            {
                case NSLayoutAttributeFirstBaseline:
                case NSLayoutAttributeLastBaseline:
                    if ([constraint.firstItem isKindOfClass:[UITextField class]])
                    {
                        [self subviewNeedsUpdateConstraintsInLayoutSubviews:constraint.firstItem];
                    }
                    break;
                default:
                    // Nothing to do.
                    break;
            }
            switch (constraint.secondAttribute)
            {
                case NSLayoutAttributeFirstBaseline:
                case NSLayoutAttributeLastBaseline:
                    if ([constraint.secondItem isKindOfClass:[UITextField class]])
                    {
                        [self subviewNeedsUpdateConstraintsInLayoutSubviews:constraint.secondItem];
                    }
                    break;
                default:
                    // Nothing to do.
                    break;
            }
        }];
    }
}

- (void)updateConstraints
{
    [self applySelectedThemeIfNeeded];
    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    /*
    NSSet* needySubviews = [NSSet setWithSet:self.subviewsNeedingUpdateConstraintsFromLayoutSubviews];
    [self.subviewsNeedingUpdateConstraintsFromLayoutSubviews removeAllObjects];
    for (UIView* view in needySubviews)
    {
        //[view setNeedsUpdateConstraints];
        //[view updateConstraintsIfNeeded];
    }
     */
}

@end
