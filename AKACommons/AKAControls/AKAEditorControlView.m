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
        [self initializeDefaultValues];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initializeDefaultValues];
    }
    return self;
}

- (void)initializeDefaultValues
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

#pragma mark - Analyze Subview Structure

- (NSDictionary*)roleMapping
{
    NSDictionary* roleMapping = @{ @"label":
                                       @{ @"required":      @(YES),
                                          @"autoCreate":    ^UIView*() {
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
                                          },
                                          @"outlet":        [AKAProperty propertyOfKeyValueTarget:self keyPath:@"label" changeObserver:nil],
                                          @"validTypes":    @[ [UILabel class] ],
                                          @"viewTag":       @(10) },
                                   @"editor":
                                       @{ @"required":      @(YES),
                                          @"autoCreate":    ^UIView*() {
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
                                          },
                                          @"outlet":        [AKAProperty propertyOfKeyValueTarget:self keyPath:@"editor" changeObserver:nil],
                                          @"viewTag":       @(20) },
                                   @"errorMessageLabel":
                                       @{ @"required":      @(NO),
                                          @"autoCreate":    ^UIView*() {
                                              UILabel* errorMessageLabel = [[UILabel alloc] init];
                                              errorMessageLabel.text = self.errorText;
                                              if (self.errorTextColor)
                                              {
                                                  errorMessageLabel.textColor = self.errorTextColor;
                                              }
                                              if (self.errorFont)
                                              {
                                                  errorMessageLabel.font = self.errorFont;
                                              }
                                              else
                                              {
                                                  errorMessageLabel.font = [UIFont systemFontOfSize:10.0 weight:UIFontWeightLight];
                                              }
                                              errorMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
                                              [errorMessageLabel sizeToFit];
                                              return errorMessageLabel;
                                          },
                                          @"outlet":        [AKAProperty propertyOfKeyValueTarget:self keyPath:@"errorMessageLabel" changeObserver:nil],
                                          @"validTypes":    @[ [UILabel class] ],
                                          @"viewTag":       @(30) },
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

- (NSDictionary*)analyzeSubviewStructure
{
    NSDictionary* roleMapping = [self roleMapping];
    NSDictionary* viewTagToRoleMapping = [self viewTagToRoleMapping:roleMapping];

    return [self analyzeSubviewStrunctureWithRoleMapping:roleMapping
                                    viewTagToRoleMapping:viewTagToRoleMapping];
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
        [subview enumerateSelfAndSubviewsUsingBlock:^(UIView *view, BOOL *stop, BOOL *doNotDescend) {
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
    [self createMissingSubviews:analysisResults];
    return YES;
}

- (void)createMissingSubviews:(NSDictionary*)analysisResults
{
    NSLog(@"%@", analysisResults.description);

    NSMutableDictionary* vacantRoles = analysisResults[@"vacantRoles"];
    NSMutableDictionary* assignments = analysisResults[@"assignments"];

    for (NSString* role in vacantRoles.allKeys)
    {
        NSDictionary* roleSpec = vacantRoles[role];
        UIView*(^autoCreate)() = roleSpec[@"autoCreate"];
        AKAProperty* outlet = roleSpec[@"outlet"];
        if (autoCreate)
        {
            UIView* view = autoCreate();
            if (view)
            {
                BOOL added = NO;
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
    [self setupConstraintsWithRoleAssignment:analysisResults[@"assignments"]];
    [super updateConstraints];
}

- (void)setupConstraintsWithRoleAssignment:(NSDictionary*)assignments
{
    self.translatesAutoresizingMaskIntoConstraints = NO;

    NSArray* layouts =
    @[ @{ @"requiredRoles": @[ @"editor", @"label", @"errorMessageLabel" ],
          @"metrics":
              @{ @"padTop": @(4),
                 @"padRight": @(4),
                 @"padBottom": @(4),
                 @"padLeft": @(4),
                 @"vSpace": @(2),
                 @"hSpace": @(8),
                 @"labelWidth": @(60)
                 },
          @"constraints":
              @[  @{ @"format": @"V:|-(>=padTop)-[label]-(>=padBottom)-|" },
                  @{ @"format": @"H:|-(padLeft)-[label(labelWidth)]-(hSpace)-[editor]-(padRight@750)-|", @"options": @(NSLayoutFormatAlignAllBaseline) },
                  @{ @"format": @"V:|-(padTop)-[editor]-(vSpace)-[errorMessageLabel]-(padBottom)-|", @"options": @(NSLayoutFormatAlignAllLeft|NSLayoutFormatAlignAllRight) },
                 /*
                 @{ @"custom":
                        @{ @"item": @"editor",
                           @"attribute":  @(NSLayoutAttributeFirstBaseline),
                           @"relatedBy":  @(NSLayoutRelationEqual),
                           @"multiplier": @(1),
                           @"constant":   @(0),
                           @"priority":   @(1000)
                           },
                    @"items":
                        @[ @{ @"item": @"label",
                              @"attribute": @(NSLayoutAttributeFirstBaseline)
                              }
                           ]
                    }*/
                 ]
          },/*
       @{ @"requiredRoles": @[ @"editor", @"label" ],
          @"metrics":
              @{ @"padTop": @(0),
                 @"padRight": @(0),
                 @"padBottom": @(0),
                 @"padLeft": @(0),
                 @"vSpace": @(2),
                 @"hSpace": @(8),
                 },
          @"constraints":
              @[ @{ @"format": @"V:|-(padTop)-[editor]-(padBottom)-|"  },
                 @{ @"format": @"V:[label]-(>=padBottom)-|" },
                 @{ @"format": @"H:|-(padLeft)-[label]-(hSpace)-[editor]-(padRight)-|" }
                 ]
          },*/
      ];

    for (NSDictionary* layout in layouts)
    {
        NSMutableDictionary* views = NSMutableDictionary.new;
        NSArray* requiredRoles = layout[@"requiredRoles"];
        BOOL applicable = requiredRoles.count > 0;
        for (NSString* role in requiredRoles)
        {
            NSDictionary* assignment = assignments[role];
            if (assignment)
            {
                // layout uses the roles toplevel view
                id view = assignment[@"toplevelView"];
                if (view && view != [NSNull null])
                {
                    views[role] = view;
                }
                else
                {
                    applicable = NO;
                    break;
                }
            }
            else
            {
                applicable = NO;
                break;
            }
        }
        if (applicable)
        {
            for (UIView* view in views.objectEnumerator)
            {
                [self removeConstraintsAffecting:view];
                [view removeConstraintsAffecting:self];
            }
            NSDictionary* metrics = layout[@"metrics"];
            for (NSDictionary* constraintSpec in layout[@"constraints"])
            {
                NSString* visualFormat = constraintSpec[@"format"];
                NSDictionary* custom = constraintSpec[@"custom"];
                if (visualFormat)
                {
                    NSLayoutFormatOptions options = ((NSNumber*)constraintSpec[@"options"]).unsignedIntegerValue;

                    NSArray* constraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                                                   options:options
                                                                                   metrics:metrics
                                                                                     views:views];
                    [self addConstraints:constraints];
                }
                else if (custom)
                {
                    UIView* item = custom[@"item"] ? views[custom[@"item"]] : nil;
                    int attribute = ((NSNumber*)(custom[@"attribute"])).intValue;
                    int relatedBy = ((NSNumber*)custom[@"relatedBy"]).intValue;
                    CGFloat multiplier = ((NSNumber*)custom[@"multiplier"]).doubleValue;
                    CGFloat constant = ((NSNumber*)custom[@"constant"]).doubleValue;
                    UILayoutPriority priority = UILayoutPriorityDefaultHigh;
                    if (custom[@"priority"] != nil)
                    {
                        priority = ((NSNumber*)custom[@"priority"]).intValue;
                    }
                    for (NSDictionary* itemSpec in constraintSpec[@"items"])
                    {
                        UIView* item2 = itemSpec[@"item"] ? views[itemSpec[@"item"]] : nil;
                        int attribute2 = ((NSNumber*)custom[@"attribute"]).intValue;
                        if (item && item2)
                        {
                            NSAssert(item.superview == item2.superview, @"%@ != %@", item.superview, item2.superview);
                            NSLayoutConstraint* constraint =
                                [NSLayoutConstraint constraintWithItem:item
                                                             attribute:attribute
                                                             relatedBy:relatedBy
                                                                toItem:item2
                                                         attribute:attribute2
                                                        multiplier:multiplier
                                                          constant:constant];
                            constraint.priority = priority;
                            [self addConstraint:constraint];
                        }
                    }
                }
            }

            [self setNeedsLayout];
            //[self layoutIfNeeded];
            break;
        }
    }
}

#pragma mark - Outlets

#pragma mark Validation

- (BOOL)value:(inout __autoreleasing id*)ioValue isKindOfType:(Class)type error:(out NSError *__autoreleasing *)error
{
    BOOL result = [*ioValue isKindOfClass:type];
    if (!result && error != nil)
    {
        // TODO: error handling
        *error = [NSError errorWithDomain:@"com.aka-labs.com.AKAControls"
                                     code:123
                                 userInfo:@{}];
    }
    return result;
}

- (BOOL)validateLabel:(inout __autoreleasing id *)ioValue error:(out NSError *__autoreleasing *)error
{
    return [self value:ioValue isKindOfType:[UILabel class] error:error];
}

- (BOOL)validateEditor:(inout __autoreleasing id *)ioValue error:(out NSError *__autoreleasing *)error
{
    return [self value:ioValue isKindOfType:[UIView class] error:error];
}

- (BOOL)validateErrorMessageLabel:(inout __autoreleasing id *)ioValue error:(out NSError *__autoreleasing *)error
{
    return [self value:ioValue isKindOfType:[UILabel class] error:error];
}

@end
