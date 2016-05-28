//
//  AKAFontPropertyBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 17.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAFontPropertyBinding.h"
#import "AKABinding_Protected.h"
#import "AKANSEnumerations.h"

@interface AKAFontDescriptorAttributes: NSObject

@property(nonatomic) NSMutableDictionary<NSString*, id>* storage;

@property(nonatomic) NSString* family;
@property(nonatomic) NSString* name;
@property(nonatomic) NSString* face;
@property(nonatomic) NSString* visibleName;
@property(nonatomic) CGFloat size;
@property(nonatomic) NSNumber* fixedAdvance;
@property(nonatomic) NSString* textStyle;
@property(nonatomic) NSNumber* weightTrait;
@property(nonatomic) NSNumber* widthTrait;
@property(nonatomic) NSNumber* slantTrait;
@property(nonatomic) UIFontDescriptorSymbolicTraits symbolicTraits;

@end

@implementation AKAFontDescriptorAttributes

- (instancetype)init
{
    if (self = [super init])
    {
        self.storage = [NSMutableDictionary new];
        self.storage[UIFontDescriptorTraitsAttribute] = [NSMutableDictionary new];
    }
    return self;
}

- (void)setFontDescriptorAttributeValue:(id)value forKey:(NSString*)key
{
    if (value == nil)
    {
        [self.storage removeObjectForKey:key];
    }
    else
    {
        self.storage[key] = value;
    }
}

- (NSString *)name
{
    return self.storage[UIFontDescriptorNameAttribute];
}

- (void)setName:(NSString *)name
{
    [self setFontDescriptorAttributeValue:name forKey:UIFontDescriptorNameAttribute];
}

- (NSString *)family
{
    return self.storage[UIFontDescriptorFamilyAttribute];
}

- (void)setFamily:(NSString *)family
{
    [self setFontDescriptorAttributeValue:family forKey:UIFontDescriptorFamilyAttribute];
}

- (NSString *)face
{
    return self.storage[UIFontDescriptorFaceAttribute];
}

- (void)setFace:(NSString *)face
{
    [self setFontDescriptorAttributeValue:face forKey:UIFontDescriptorFaceAttribute];
}

- (NSString *)visibleName
{
    return self.storage[UIFontDescriptorVisibleNameAttribute];
}

- (void)setVisibleName:(NSString *)visibleName
{
    [self setFontDescriptorAttributeValue:visibleName forKey:UIFontDescriptorVisibleNameAttribute];
}

- (CGFloat)size
{
    NSNumber* size = self.storage[UIFontDescriptorSizeAttribute];
    return size == nil ? 0.0 : size.floatValue;
}

- (void)setSize:(CGFloat)size
{
    [self setFontDescriptorAttributeValue:size > 0.0 ? @(size) : nil
                                   forKey:UIFontDescriptorSizeAttribute];
}

- (void)setFontDescriptorTrait:(NSString*)traitKey value:(id)value
{
    if (value == nil)
    {
        [self.storage[UIFontDescriptorTraitsAttribute] removeObjectForKey:traitKey];
    }
    else
    {
        ((NSMutableDictionary*)self.storage[UIFontDescriptorTraitsAttribute])[traitKey] = value;
    }
}

- (id)fontDescriptorTrait:(NSString*)traitKey
{
    return ((NSDictionary*)self.storage[UIFontDescriptorTraitsAttribute])[traitKey];
}

- (NSNumber *)weightTrait
{
    return [self fontDescriptorTrait:UIFontWeightTrait];
}

- (void)setWeightTrait:(NSNumber *)weightTrait
{
    NSAssert(weightTrait == nil ||
             (weightTrait.floatValue >= -1.0 && weightTrait.floatValue <= 1.0),
             @"Weight trait value %@ out of range -1.0 .. 1.0", weightTrait);

    [self setFontDescriptorTrait:UIFontWeightTrait value:weightTrait];
}

- (NSNumber *)slantTrait
{
    return [self fontDescriptorTrait:UIFontSlantTrait];
}

- (void)setSlantTrait:(NSNumber *)slantTrait
{
    NSAssert(slantTrait == nil ||
             (slantTrait.floatValue >= -1.0 && slantTrait.floatValue <= 1.0),
             @"Slant trait value %@ out of range -1.0 .. 1.0", slantTrait);

    [self setFontDescriptorTrait:UIFontSlantTrait value:slantTrait];
}

- (NSNumber *)widthTrait
{
    return [self fontDescriptorTrait:UIFontWidthTrait];
}

- (void)setWidthTrait:(NSNumber *)widthTrait
{
    NSAssert(widthTrait == nil ||
             (widthTrait.floatValue >= -1.0 && widthTrait.floatValue <= 1.0),
             @"Width trait value %@ out of range -1.0 .. 1.0", widthTrait);

    [self setFontDescriptorTrait:UIFontWidthTrait value:widthTrait];
}

- (UIFontDescriptorSymbolicTraits)symbolicTraits
{
    NSNumber* result = [self fontDescriptorTrait:UIFontSymbolicTrait];

    return result ? result.unsignedIntValue : 0;
}

- (void)setSymbolicTraits:(UIFontDescriptorSymbolicTraits)symbolicTraits
{
    [self setFontDescriptorTrait:UIFontSymbolicTrait
                           value:symbolicTraits ? @(symbolicTraits) : nil];
}

@end


@interface AKAFontPropertyBinding()

@property(nonatomic, readonly) AKAFontDescriptorAttributes* fontDescriptorAttributes;
@property(nonatomic) UIFont* targetFont;
@property(nonatomic) UIFont* originalTargetFont;
@property(nonatomic, readonly) UIFontDescriptor* baseFontDescriptor;
@property(nonatomic) NSLayoutConstraint* textFieldMinHeightConstraint;

@property(nonatomic) BOOL isObserving;

@property(nonatomic) BOOL isCustomizationBinding;

@end


@implementation AKAFontPropertyBinding

+ (AKABindingSpecification*)                         specification
{
    [self registerEnumerationAndOptionTypes];

    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    [self registerEnumerationAndOptionTypes];

    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":      [AKAFontPropertyBinding class],
           @"targetType":       [AKAProperty class],
           @"expressionType":   @((AKABindingExpressionTypeAnyKeyPath       |
                                   AKABindingExpressionTypeNone) ),
           @"attributes":       @{
                   @"family":       @{
                           @"expressionType":   @((AKABindingExpressionTypeStringConstant |
                                                   AKABindingExpressionTypeAnyKeyPath)),
                           @"use":              @(AKABindingAttributeUseBindToBindingProperty),
                           @"bindingProperty":  @"fontDescriptorAttributes.family"
                           },
                   @"name":         @{
                           @"expressionType":   @((AKABindingExpressionTypeStringConstant |
                                                   AKABindingExpressionTypeAnyKeyPath)),
                           @"use":              @(AKABindingAttributeUseBindToBindingProperty),
                           @"bindingProperty":  @"fontDescriptorAttributes.name"
                           },
                   @"face":         @{
                           @"expressionType":   @((AKABindingExpressionTypeStringConstant |
                                                   AKABindingExpressionTypeAnyKeyPath)),
                           @"use":              @(AKABindingAttributeUseBindToBindingProperty),
                           @"bindingProperty":  @"fontDescriptorAttributes.face"

                           },
                   @"visibleName":  @{
                           @"expressionType":   @((AKABindingExpressionTypeStringConstant |
                                                   AKABindingExpressionTypeAnyKeyPath)),
                           @"use":              @(AKABindingAttributeUseBindToBindingProperty),
                           @"bindingProperty":  @"fontDescriptorAttributes.visibleName"
                           },
                   @"size":         @{
                           @"expressionType":   @((AKABindingExpressionTypeNumber)),
                           @"use":              @(AKABindingAttributeUseBindToBindingProperty),
                           @"bindingProperty":  @"fontDescriptorAttributes.size"
                           },
                   @"fixedAdvance": @{
                           @"expressionType":   @((AKABindingExpressionTypeNumber |
                                                   AKABindingExpressionTypeAnyKeyPath)),
                           @"use":              @(AKABindingAttributeUseBindToBindingProperty),
                           @"bindingProperty":  @"fontDescriptorAttributes.fixedAdvance"
                           },
                   @"textStyle":    @{
                           @"expressionType":   @((AKABindingExpressionTypeEnumConstant)),
                           @"enumerationType":  @"UIFontTextStyle",
                           @"use":              @(AKABindingAttributeUseBindToBindingProperty),
                           @"bindingProperty":  @"fontDescriptorAttributes.textStyle"
                           },


                   @"traits":       @{
                           @"expressionType":   @((AKABindingExpressionTypeOptionsConstant |
                                                   AKABindingExpressionTypeAnyKeyPath)),
                           @"optionsType":      @"UIFontDescriptorSymbolicTraits",
                           @"use":              @(AKABindingAttributeUseBindToBindingProperty),
                           @"bindingProperty":  @"fontDescriptorAttributes.symbolicTraits"
                           },
                   @"weight":         @{
                           @"expressionType":   @((AKABindingExpressionTypeNumber |
                                                   AKABindingExpressionTypeEnumConstant |
                                                   AKABindingExpressionTypeAnyKeyPath)),
                           @"enumerationType":  @"UIFontWeight",
                           @"use":              @(AKABindingAttributeUseBindToBindingProperty),
                           @"bindingProperty":  @"fontDescriptorAttributes.weightTrait"
                           },
                   @"width":         @{
                           @"expressionType":   @((AKABindingExpressionTypeNumber |
                                                   AKABindingExpressionTypeAnyKeyPath)),
                           @"use":              @(AKABindingAttributeUseBindToBindingProperty),
                           @"bindingProperty":  @"fontDescriptorAttributes.widthTrait"
                           },
                   @"slant":         @{
                           @"expressionType":   @((AKABindingExpressionTypeNumber |
                                                   AKABindingExpressionTypeAnyKeyPath)),
                           @"use":              @(AKABindingAttributeUseBindToBindingProperty),
                           @"bindingProperty":  @"fontDescriptorAttributes.slantTrait"
                           },
                   },
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

+ (void)registerEnumerationAndOptionTypes
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AKABindingExpressionSpecification registerEnumerationType:@"UIFontTextStyle"
                                                  withValuesByName:[AKANSEnumerations
                                                                    uifontTextStylesByName]];
        [AKABindingExpressionSpecification registerOptionsType:@"UIFontDescriptorSymbolicTraits"
                                              withValuesByName:[AKANSEnumerations uifontDescriptorTraitsByName]];
        [AKABindingExpressionSpecification registerEnumerationType:@"UIFontWeight"
                                                  withValuesByName:[AKANSEnumerations
                                                                    uifontWeightsByName]];
    });
}

- (instancetype)init
{
    if (self = [super init])
    {
        _fontDescriptorAttributes = [AKAFontDescriptorAttributes new];
    }
    return self;
}

- (UIFont*)targetFont
{
    return [self.view valueForKey:@"font"];
}

- (void)setTargetFont:(UIFont*)targetFont
{
    // TODO: refactor this: not updating target font if not observing, because new target value
    // is based on original target value, which is set in observation starter. So this binding is
    // semantically not replacing but customizing the font (in a manner of speaking).
    // Think about a clean way to do that.
    if (self.isObserving)
    {
        UIView* view = self.view;
        [view setValue:targetFont forKey:@"font"];

        // Sigh: Text fields get an implicit height constraint which uses a font independ height of 30
        // so we hack our way by overriding this constraint with a constraint that is aware of the font
        // size. We try to minimize problems by assigning a low priority and using a greater-equal relation
        if ([view isKindOfClass:[UITextField class]])
        {
            if (targetFont.pointSize > 30)
            {
                if (!self.textFieldMinHeightConstraint)
                {
                    self.textFieldMinHeightConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                                     attribute:NSLayoutAttributeHeight
                                                                                     relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                                        toItem:nil
                                                                                     attribute:NSLayoutAttributeHeight
                                                                                    multiplier:1.0
                                                                                      constant:targetFont.pointSize];
                    self.textFieldMinHeightConstraint.priority = 500;
                    [view addConstraint:self.textFieldMinHeightConstraint];
                    [view setNeedsLayout];
                }
            }
            else
            {
                if (self.textFieldMinHeightConstraint)
                {
                    [view removeConstraint:self.textFieldMinHeightConstraint];
                    self.textFieldMinHeightConstraint = nil;
                }
            }
        }
    }
}

- (AKAProperty *)createBindingTargetPropertyForTarget:(req_id __unused)targetView
{
    AKAProperty* result = [AKAProperty propertyOfWeakTarget:self
                                                     getter:
                           ^id _Nullable(id  _Nonnull target)
                           {
                               AKAFontPropertyBinding* binding = target;

                               return binding.targetFont;
                           }
                                                     setter:
                           ^(id  _Nonnull target, id  _Nullable value)
                           {
                               AKAFontPropertyBinding* binding = target;

                               binding.targetFont = value;
                           }
                                         observationStarter:
                           ^BOOL(id  _Nonnull target)
                           {
                               AKAFontPropertyBinding* binding = target;

                               binding.originalTargetFont = binding.targetFont;
                               binding.isObserving = YES;

                               return binding.isObserving;
                           }
                                         observationStopper:
                           ^BOOL(id  _Nonnull target)
                           {
                               AKAFontPropertyBinding* binding = target;

                               if (binding.isObserving)
                               {
                                   binding.isObserving = NO;
                                   binding.targetFont = binding.originalTargetFont;
                               }

                               if (self.textFieldMinHeightConstraint)
                               {
                                   [self.view removeConstraint:self.textFieldMinHeightConstraint];
                                   self.textFieldMinHeightConstraint = nil;
                               }

                               return !binding.isObserving;
                           }];
    return result;
}

- (AKAProperty *)defaultBindingSourceForExpression:(req_AKABindingExpression __unused)bindingExpression
                                           context:(req_AKABindingContext __unused)bindingContext
                                    changeObserver:(AKAPropertyChangeObserver)changeObserver
                                             error:(out_NSError __unused)error
{
    return [AKAProperty propertyOfWeakKeyValueTarget:self
                                             keyPath:@"originalTargetFont"
                                      changeObserver:changeObserver];
}

- (BOOL)isCustomizationBinding
{
    return !self.fontDescriptorAttributes.textStyle.length;
}

- (BOOL)convertSourceValue:(id)sourceValue
             toTargetValue:(id  _Nullable __autoreleasing *)targetValueStore
                     error:(out_NSError __unused)error
{
    BOOL result = YES;

    UIFontDescriptor* baseDescriptor = nil;
    UIFontDescriptor* descriptor = nil;
    UIFont* font = nil;

    if (self.isCustomizationBinding)
    {
        if ([sourceValue isKindOfClass:[UIFontDescriptor class]])
        {
            baseDescriptor = sourceValue;
        }
        else if ([sourceValue isKindOfClass:[UIFont class]])
        {
            font = sourceValue;
            baseDescriptor = font.fontDescriptor;

            NSString* textStyle = baseDescriptor.fontAttributes[UIFontDescriptorTextStyleAttribute];
            if (textStyle)
            {
                UIFont* updatedFont = [UIFont preferredFontForTextStyle:textStyle];
                baseDescriptor = updatedFont.fontDescriptor;
            }

            if (self.fontDescriptorAttributes.symbolicTraits != 0)
            {
                NSString* fontName = baseDescriptor.fontAttributes[UIFontDescriptorNameAttribute];
                if (fontName.length > 0)
                {
                    UIFontDescriptor* modifiedBaseDescriptor = [baseDescriptor fontDescriptorWithFamily:font.familyName];
                    baseDescriptor = modifiedBaseDescriptor;
                }
            }
        }
        else if ([sourceValue isKindOfClass:[NSDictionary class]])
        {
            baseDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:sourceValue];
        }
    }

    if (baseDescriptor)
    {
        descriptor = [baseDescriptor fontDescriptorByAddingAttributes:self.fontDescriptorAttributes.storage];
    }
    else
    {
        descriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:self.fontDescriptorAttributes.storage];
    }

    if (descriptor)
    {
        CGFloat size = 0.0;
        if (self.fontDescriptorAttributes.symbolicTraits != 0 &&
            self.fontDescriptorAttributes.size != 0.0 &&
            baseDescriptor.fontAttributes[UIFontDescriptorTextStyleAttribute])
        {
            // size attribute will not make it through in this case unless it's specified
            size = self.fontDescriptorAttributes.size;
        }
        font = [UIFont fontWithDescriptor:descriptor size:size];
    }

    *targetValueStore = font;

    return result;
}

- (void)binding:(AKABinding *)binding didUpdateTargetValue:(id)oldTargetValue to:(id)newTargetValue
{
    if (oldTargetValue != newTargetValue)
    {
        if ([self.bindingPropertyBindings containsObject:binding])
        {
            [self updateTargetValue];
        }
    }

    id<AKABindingDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(binding:didUpdateTargetValue:to:)])
    {
        [delegate binding:binding didUpdateTargetValue:oldTargetValue to:newTargetValue];
    }
}

- (void)contentSizeCategoryChanged
{
    [self updateTargetValue];
}

@end
