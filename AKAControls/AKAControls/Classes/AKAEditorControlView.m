//
//  AKAEditorControlView.m
//  AKACommons
//
//  Created by Michael Utech on 15.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAEditorControlView.h"
#import "AKAControlViewProtocol.h"
#import "AKAProperty.h"
#import "AKAControlsErrors.h"

#import "UIView+AKAHierarchyVisitor.h"
#import "UIView+AKAConstraintTools.h"

@interface AKAEditorControlView()

@property(nonatomic)BOOL constraintsConfigured;
@property(nonatomic)UIView* editorContainer;

@property(nonatomic, assign) IBInspectable BOOL enablePreview;

@property(nonatomic, assign) BOOL setupActive;

@end

@implementation AKAEditorControlView

#pragma mark - initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
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

- (void)setupDefaultValues
{
    self.labelText = @"Please change";
    self.errorText = @"-";
    self.errorTextColor = [UIColor redColor];

#if TARGET_INTERFACE_BUILDER
    self.enablePreview = YES;
#endif
}

- (void)awakeFromNib
{
    [self setNeedsUpdateConstraints];
}

- (void)prepareForInterfaceBuilder
{
    if (self.enablePreview)
    {
        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
    }
}

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

#pragma mark - Configuration

- (Class)preferredBindingType
{
    return nil;
}

- (NSDictionary*)roleMapping
{
    NSDictionary* roleMapping = @{ @"label":
                                       @{ @"required":      @(YES),
                                          @"outletKeyPath": @"label",
                                          @"validTypes":    @[ [UILabel class] ],
                                          @"viewTag":       @(10)
                                          },
                                   @"editor":
                                       @{ @"required":      @(YES),
                                          @"outletKeyPath": @"editor",
                                          @"viewTag":       @(20)
                                          },
                                   @"errorMessageLabel":
                                       @{ @"required":      @(NO),
                                          @"outletKeyPath": @"errorMessageLabel",
                                          @"validTypes":    @[ [UILabel class] ],
                                          @"viewTag":       @(30)
                                          },
                                   };
    return roleMapping;
}

- (NSDictionary*)viewTagToRoleMapping:(NSDictionary*)roleMapping
{
    NSMutableDictionary* result = NSMutableDictionary.new;
    for (NSString* role in roleMapping.keyEnumerator)
    {
        NSDictionary* entry = roleMapping[role];
        NSNumber* viewTag = entry[@"viewTag"];
        if (viewTag)
        {
            result[viewTag] = role;
        }
    }
    return result;
}

- (NSDictionary*)themeSpecification
{
    return
    @{ @"metrics": @{ @"padTop": @(4),
                      @"padRight": @(4),
                      @"padBottom": @(4),
                      @"padLeft": @(4),
                      @"vSpace": @(2),
                      @"hSpace": @(8),
                      @"labelWidth": @(60)
                      },
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
                      @[  @{ @"format": @"V:|-(>=padTop)-[label]-(>=padBottom)-|" },
                          @{ @"format": @"H:|-(padLeft)-[label(labelWidth)]-(hSpace)-[editor]-(padRight@750)-|", @"options": @(NSLayoutFormatAlignAllFirstBaseline) },
                          @{ @"format": @"V:|-(padTop)-[editor]-(padBottom)-|" },
                          ]
                  },
               @{ @"requiredViews": @[ @"editor", @"label", @"errorMessageLabel" ],
                 @"constraints":
                     @[
                         @{ @"format": @"H:|-(4)-[label(60)]-(4)-[editor]-(4)-|",
                            @"options": @(NSLayoutFormatAlignAllFirstBaseline) },
                         @{ @"format": @"V:|-(4)-[editor]-(4)-[errorMessageLabel]-(4)-|",
                            @"options": @(NSLayoutFormatAlignAllLeft|NSLayoutFormatAlignAllRight) },
                         @{ @"format": @"V:|-(>=padTop)-[label]-(>=padBottom)-|" },
                         ]
                 },
              ]
      };
}

#pragma mark - Analyze Subview Structure

- (NSDictionary*)analyzeSubviewStructure
{
    NSDictionary* roleMapping = [self roleMapping];
    NSDictionary* viewTagToRoleMapping = [self viewTagToRoleMapping:roleMapping];

    return [self analyzeSubviewStrunctureWithRoleMapping:roleMapping
                                    viewTagToRoleMapping:viewTagToRoleMapping];
}

- (NSDictionary*)analyzeSubviewStrunctureWithRoleMapping:(NSDictionary*)roleMapping
                                    viewTagToRoleMapping:(NSDictionary*)viewTagToRoleMapping
{
    NSMutableDictionary* assignments = NSMutableDictionary.new;
    NSMutableDictionary* conflictingAssignments = NSMutableDictionary.new;
    NSMutableDictionary* orphanedOutlets = NSMutableDictionary.new;
    NSMutableDictionary* unassignedOutlets = NSMutableDictionary.new;
    NSMutableDictionary* vacantRoles = NSMutableDictionary.new;
    NSMutableArray* unidentifiedSubviews = NSMutableArray.new;

    for (UIView* subview in self.subviews)
    {
        BOOL __block subviewIdentified = NO;
        [subview aka_enumerateSelfAndSubviewsUsingBlock:^(UIView *view, BOOL *stop, BOOL *doNotDescend) {
            (void)stop; // not used
            BOOL identified = NO;
            NSDictionary* identifiedBy = nil;
            NSString* role = nil;

            // If the view is a control view, use its role property.
            if (role.length == 0 && [view conformsToProtocol:@protocol(AKAControlViewProtocol)])
            {
                UIView<AKAControlViewProtocol>* controlView = (UIView<AKAControlViewProtocol>*)view;
                role = controlView.role;
                if (role.length)
                {
                    identifiedBy = @{ @"method": @"roleName", @"value": role };
                }
            }

            // Otherwise, try to identify the role using the views tag
            if (role.length == 0)
            {
                role = viewTagToRoleMapping[@(view.tag)];
                if (role.length > 0)
                {
                    identifiedBy = @{ @"method": @"viewTag", @"value": @(view.tag) };
                }
            }

            // If a role name was found:
            if (role.length > 0)
            {
                NSDictionary* roleSpec = roleMapping[role];
                identified = roleSpec != nil;
                subviewIdentified |= identified;

                // If the the role name is used (mapping exists):
                if (identified)
                {
                    // Ignore the subviews of the
                    *doNotDescend = YES;
                    NSDictionary* entry = @{ @"assignee": view,
                                             @"roleSpecification": roleSpec,
                                             @"toplevelView": subview,
                                             @"identifiedBy": identifiedBy };

                    if (assignments[role] != nil)
                    {
                        if (conflictingAssignments[role] == nil)
                        {
                            conflictingAssignments[role] = [NSMutableArray arrayWithObjects:assignments[role], entry, nil];
                        }
                        else
                        {
                            [((NSMutableArray*)conflictingAssignments[role]) addObject:entry];
                        }
                    }
                    else
                    {
                        NSDictionary* mappingEntry = roleMapping[role];
                        if (mappingEntry != nil)
                        {
                            assignments[role] = entry;
                        }
                    }
                }
            }
        }];
        if (!subviewIdentified)
        {
            [unidentifiedSubviews addObject:subview];
        }
    }

    for (NSString* role in roleMapping.keyEnumerator)
    {
        NSDictionary* roleSpec = roleMapping[role];

        AKAProperty* outlet = roleSpec[@"outlet"];
        UIView* viewFromOutlet = outlet.value;
        if (viewFromOutlet != nil)
        {
            id toplevelView = [self subviewContainingOrEqualTo:viewFromOutlet];
            if (toplevelView == nil)
            {
                toplevelView = [NSNull null];
            }
            NSDictionary* entry = @{ @"assignee": viewFromOutlet,
                                     @"roleSpecification": roleSpec,
                                     @"toplevelView": toplevelView,
                                     @"identifiedBy": @{ @"method": @"outlet", @"value": viewFromOutlet } };
            if (toplevelView == [NSNull null])
            {
                // If the view is not a transitive subview, we can either add it or fail.
                orphanedOutlets[role] = entry;
            }
            else
            {
                // This is probably a problem, since the only way I see this can happen is if the
                // view is nested in another view assigned to a role, like for example a label nested
                // in an editor. This will probably break autolayout.
            }

            NSDictionary* assignment = assignments[role];
            if (assignment == nil)
            {
                assignments[role] = entry;
            }
            else
            {
                if (assignment[@"assignee"] != viewFromOutlet)
                {
                    if (conflictingAssignments[role] != nil)
                    {
                        [conflictingAssignments[role] addObject:entry];
                    }
                    else
                    {
                        conflictingAssignments[role] = [NSMutableArray arrayWithObjects:assignments[role], entry, nil];
                    }
                }
            }
        }
        else if (outlet != nil && assignments[role] != nil)
        {
            unassignedOutlets[role] = roleMapping[role];
        }

        if (assignments[role] == nil)
        {
            [vacantRoles setObject:roleMapping[role] forKey:role];
        }

    }

    return NSDictionaryOfVariableBindings(assignments,
                                          conflictingAssignments,
                                          unidentifiedSubviews,
                                          vacantRoles,
                                          roleMapping,
                                          viewTagToRoleMapping);
}

- (UIView*)subviewContainingOrEqualTo:(UIView*)view
{
    UIView* result = nil;
    UIView* previous = view;
    UIView* v = view.superview;
    for (; v != nil && v != self; v = v.superview)
    {
        previous = v;
    }
    if (v == self)
    {
        result = previous;
    }
    return result;
}

#pragma mark - Setup Subviews

- (void)modifyViewHierarchy:(void(^)())block
{
    // Prevent calls to setNeedsUpdateConstraints in didAdd/willRemoveSubview:
    BOOL setupWasActive = self.setupActive;
    self.setupActive = YES;
    block();
    self.setupActive = setupWasActive;
}

- (BOOL)setupSubviewsForAnalysisResults:(NSDictionary*)analysisResults
                                 errors:(NSMutableArray*)errors
{
    (void)errors; // not used. TODO: error handling if nonrecoverable error was found
    [self createMissingSubviews:analysisResults[@"vacantRoles"]
           andUpdateAssignments:analysisResults[@"assignments"]];
    return YES;
}

- (void)createMissingSubviews:(NSMutableDictionary*)vacantRoles
         andUpdateAssignments:(NSMutableDictionary*)assignments
{
    for (NSString* role in vacantRoles.allKeys)
    {
        NSDictionary* roleSpec = vacantRoles[role];
        SEL autoCreateSelector = NSSelectorFromString([NSString stringWithFormat:@"autoCreateViewForRole_%@", role]);
        if ([self respondsToSelector:autoCreateSelector])
        {
            IMP imp = [self methodForSelector:autoCreateSelector];
            UIView*(*autoCreateFunction)(id, SEL) = (void*)imp;
            UIView* view = autoCreateFunction(self, autoCreateSelector);
            if (view)
            {
                BOOL added = NO;
                AKAProperty* outlet = nil;
                if (roleSpec[@"outletKeyPath"])
                {
                    outlet = [AKAProperty propertyOfKeyValueTarget:self keyPath:roleSpec[@"outletKeyPath"] changeObserver:nil];
                }
                if (outlet)
                {
                    UIView* viewOrReplacement = view;
                    if ([outlet validateValue:&viewOrReplacement error:nil])
                    {
                        [self modifyViewHierarchy:^{
                            [self addSubview:viewOrReplacement];
                            outlet.value = viewOrReplacement;
                        }];
                        added = YES;
                        view = viewOrReplacement;
                    }
                }
                else
                {
                    [self modifyViewHierarchy:^{
                        [self addSubview:view];
                    }];
                }
                if (added)
                {
                    NSDictionary* entry = @{ @"assignee": view,
                                             @"roleSpecification": roleSpec,
                                             @"toplevelView": view,
                                             @"identifiedBy": @{ @"method": @"autoCreate", @"value": @(YES) } };
                    assignments[role] = entry;
                    [vacantRoles removeObjectForKey:role];
                }
            }
        }
    }
}

#pragma mark - Setup constraints

- (void)updateConstraints
{
    NSDictionary* analysisResults = [self analyzeSubviewStructure];
    [self setupSubviewsForAnalysisResults:analysisResults errors:nil];
    [self setupConstraintsWithRoleAssignments:analysisResults[@"assignments"]];
    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setupConstraintsWithRoleAssignments:(NSDictionary*)assignments
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    //self.autoresizingMask = UIViewAutoresizingNone;

    NSMutableDictionary* views = NSMutableDictionary.new;
    for (NSString* role in assignments)
    {
        NSDictionary* assignment = assignments[role];
        UIView* view = assignment[@"toplevelView"];
        if (view)
        {
            views[role] = view;
        }
    }

    NSDictionary* theme = [self themeSpecification];
    [self aka_applyTheme:theme toViews:views];

    [self setNeedsLayout];
}

#pragma mark - Outlets

#pragma mark Auto Creation

- (UILabel*)autoCreateViewForRole_label
{
    UILabel* label = UILabel.new;
    label.text = self.labelText;
    if (self.labelFont)
    {
        label.font = self.labelFont;
    }
    else
    {
        label.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightLight];
    }
    if (self.labelTextColor)
    {
        label.textColor = self.labelTextColor;
    }
    label.translatesAutoresizingMaskIntoConstraints = NO;
    return label;
}

- (UILabel*)autoCreateViewForRole_errorMessageLabel
{
    UILabel* errorMessageLabel = [[UILabel alloc] init];
    errorMessageLabel.text = self.errorText;
    errorMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    //[errorMessageLabel sizeToFit];
    return errorMessageLabel;
}

- (UIView*)autoCreateViewForRole_editor
{
    UILabel* editor;
    if (self.enablePreview)
    {
        editor = UILabel.new;
        editor.text = @"Please add an editor view. For AKA control views, set role to \"editor\", for other views set tag to 20. Positioning and constraints do not matter.";
        editor.lineBreakMode = NSLineBreakByWordWrapping;
        editor.numberOfLines = 5;
        //editor.preferredMaxLayoutWidth = 200.0;
        editor.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular];
        editor.textColor = [UIColor whiteColor];
        editor.backgroundColor = [UIColor lightGrayColor];
        //editor.textAlignment = NSTextAlignmentCenter;
        editor.translatesAutoresizingMaskIntoConstraints = NO;
        //[editor sizeToFit];

    }
    return editor;
}

#pragma mark Outlet Validation


- (BOOL)validateLabel:(inout __autoreleasing id *)ioValue error:(out NSError *__autoreleasing *)error
{
    return [self validateView:ioValue forRole:@"label" isKindOfType:[UILabel class] error:error];
}

- (BOOL)validateEditor:(inout __autoreleasing id *)ioValue error:(out NSError *__autoreleasing *)error
{
    return [self validateView:ioValue forRole:@"editor" isKindOfType:[UIView class] error:error];
}

- (BOOL)validateErrorMessageLabel:(inout __autoreleasing id *)ioValue error:(out NSError *__autoreleasing *)error
{
    return [self validateView:ioValue forRole:@"errorMessageLabel" isKindOfType:[UILabel class] error:error];
}

- (BOOL)validateView:(inout __autoreleasing id*)ioValue
             forRole:(NSString*)role
        isKindOfType:(Class)type
               error:(out NSError *__autoreleasing *)error
{
    BOOL result = [*ioValue isKindOfClass:type];
    if (!result && error != nil)
    {
        *error = [AKAControlsErrors errorForTextEditorControlView:self
                                                      invalidView:*ioValue
                                                          forRole:@"editor"
                                                     expectedType:[UITextField class]];
    }
    return result;
}

@end
