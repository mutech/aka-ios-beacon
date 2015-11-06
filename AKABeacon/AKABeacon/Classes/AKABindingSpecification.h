//
//  AKABindingSpecification.h
//  AKABeacon
//
//  Created by Michael Utech on 26.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
@import AKACommons.AKANullability;

@class AKABindingProvider;
typedef AKABindingProvider* _Nullable opt_AKABindingProvider;

@class AKATypePattern;
@class AKABindingTargetSpecification;
@class AKABindingExpressionSpecification;
@class AKABindingAttributeSpecification;

/**
   Specifies how binding attributes are processed by a binding provider when it sets up a binding.
 */
typedef NS_ENUM(NSUInteger, AKABindingAttributeUse)
{
    /**
       The attribute is ignored by the processing binding provider. The binding processes the attribute itself.
     */
    AKABindingAttributeUseIgnore = 0,

    /**
       The attribute's binding expression will be stored (unevaluated) in the owner binding's bindingProperty specified in the attribute specification.
     */
    AKABindingAttributeUseAssignExpressionToBindingProperty,

    /**
       The attribute's binding expression will be evaluated in the current binding context and the resulting value will be stored in the owner binding's bindingProperty specified in the attribute specification.
     */
    AKABindingAttributeUseAssignValueToBindingProperty,

    /**
       The attribute's binding expression will be used to create a property binding targeting the owner binding's bindingProperty specified in the attribute specification.
     */
    AKABindingAttributeUseBindToBindingProperty
};

/**
   Specifies the type of a binding expression's primary expression.
 */
typedef NS_OPTIONS(uint_fast64_t, AKABindingExpressionType)
{
    /**
       Specifies a binding expression with no primary expression.
     */
    AKABindingExpressionTypeNone = 0,

    /**
       Specifies an unqualified key path, e.g. a key path with no leading scope (such as $data, $root, $control)
     */
    AKABindingExpressionTypeUnqualifiedKeyPath = (1 << 0),

    /**
       Specifies a key path relative to the data context ($data).
     */

    AKABindingExpressionTypeDataContextKeyPath = (1 << 1),

    /**
       Specifies a key path relative to the top level data context ($root).
     */
    AKABindingExpressionTypeRootDataContextKeyPath = (1 << 2),

    /**
       Specifies a key path relative to the owner of the binding ($control).

       @note This expression type and scope might be removed or renamed in a future version if bindings will be decoupled from controls for applications which want to use bindings manually.
     */
    AKABindingExpressionTypeControlKeyPath = (1 << 3),

    /**
       Specifies an array primary expression (e.g. ["x" "y"]).
     */
    AKABindingExpressionTypeArray = (1 << 5),

    /**
       Specifies a class primary expression (e.g. <ClassName>)
     */
    AKABindingExpressionTypeClassConstant = (1 << 10),

    /**
       Specifies a constant string expression (e.g. "abc")
     */
    AKABindingExpressionTypeStringConstant = (1 << 11),

    /**
       @warning do not use, this will most likely be removed or become a private constant. Use AKABindingExpressionTypeAnyNumberConstant to specify any valid number constant.
     */
    AKABindingExpressionTypeNumberConstant = (1 << 12),

    /**
       Specifies a boolean constant expression.

       Boolean values are specified as $true or $false. Boolean values can be omitted in attribute specifications ({a, b, c} instead of {a:$true, b:$true, c:$true}), then the presence of an attribute means the value $true, and its absence $false.
     */
    AKABindingExpressionTypeBooleanConstant = (1 << 13),

    /**
       Specifies an integer constant (e.g. 123).

       All integer constants are internally represented as NSNumber initialized with a long long value.
     */
    AKABindingExpressionTypeIntegerConstant = (1 << 14),

    /**
       Specifies a double constant (e.g. 0.5).

       Double constants are distinguished from integer constants by the presence of a decimal point. So '0' is an integer and '.0' or '0.' is a double.
     */
    AKABindingExpressionTypeDoubleConstant = (1 << 15),

    /**
       Specifies a UIColor constant (e.g. $UIColor{r:123, g:123, b:123, a:255})

       Color constant components are specified by mandatory attributes "red", "green" and "blue" and an optional alpha channel or "r", "g", "b" and "a". Components can be specified as integer values in the range [0 .. 255] or as double values in the range [0.0 .. 1.0].
     */
    AKABindingExpressionTypeUIColorConstant = (1 << 16),

    /**
       Specifies a CGColor constant (e.g. $CGColor{r:123, g:123, b:123, a:255}).

       Color constant components are given as mandatory attributes "red", "green" and "blue" and an optional alpha channel or "r", "g", "b" and "a". Components can be specified as integer values in the range [0 .. 255] or as double values in the range [0.0 .. 1.0].
     */
    AKABindingExpressionTypeCGColorConstant = (1 << 17),

    /**
       Specifies a CGPoint constant (e.g. $CGPoint{x:0.0, y:0.0}).

       Point coordinates are specified as mandatory attributes "x" and "y" with double values.
     */
    AKABindingExpressionTypeCGPointConstant = (1 << 18),

    /**
       Specifies a CGSize constant (e.g. $CGSize{w:1.0, h:1.0}).

       Size dimensions are specified as mandatory attributes "width" and "height" or "w" and "h" with double values.
     */
    AKABindingExpressionTypeCGSizeConstant = (1 << 19),

    /**
       Specifies a CGRect constant (e.g. $CGRect{x:1.0, y:1.0, w:1.0, h:1.0}).

       Rectangle coordinates and dimensions are specified as mandatory attributes "x", "y", "width", "height" or "w", "h" with double values.
     */
    AKABindingExpressionTypeCGRectConstant = (1 << 20),

    /**
       Specifies a UIFont constant (e.g. $UIFont{name:"Helvetica Neue", size:15.0}).

       TODO: document attributes.
     */
    AKABindingExpressionTypeUIFontConstant = (1 << 21),

    /**
       Specifies all key path types (unqualified, data context, root data context, control).
     */
    AKABindingExpressionTypeAnyKeyPath = (AKABindingExpressionTypeDataContextKeyPath | AKABindingExpressionTypeRootDataContextKeyPath | AKABindingExpressionTypeControlKeyPath),

    /**
       Specifies a class constant or key path expression.
     */
    AKABindingExpressionTypeClass = (AKABindingExpressionTypeAnyKeyPath | AKABindingExpressionTypeClassConstant),

    /**
       Specifies a string constant or key path expression.
     */
    AKABindingExpressionTypeString = (AKABindingExpressionTypeAnyKeyPath | AKABindingExpressionTypeStringConstant),

    /**
       Specifies a boolean or key path expression.
     */
    AKABindingExpressionTypeBoolean = (AKABindingExpressionTypeAnyKeyPath | AKABindingExpressionTypeBooleanConstant),

    /**
       Specifies an integer or key path expression.
     */
    AKABindingExpressionTypeInteger = (AKABindingExpressionTypeAnyKeyPath | AKABindingExpressionTypeIntegerConstant),

    /**
       Specifies a double or key path expression.
     */
    AKABindingExpressionTypeDouble = (AKABindingExpressionTypeAnyKeyPath | AKABindingExpressionTypeDoubleConstant),

    /**
       Specifies a number constant or key path expression.
     */
    AKABindingExpressionTypeNumber = (AKABindingExpressionTypeAnyKeyPath | AKABindingExpressionTypeNumberConstant),

    /**
       Specifies a UIColor or CGColor constant expression.
     */
    AKABindingExpressionTypeAnyColorConstant = (AKABindingExpressionTypeUIColorConstant | AKABindingExpressionTypeCGColorConstant),

    /**
       Specifies a number constant expression (integer, double or boolean)
     */
    AKABindingExpressionTypeAnyNumberConstant = (AKABindingExpressionTypeNumberConstant | AKABindingExpressionTypeBooleanConstant | AKABindingExpressionTypeIntegerConstant | AKABindingExpressionTypeDoubleConstant),

    /**
       Specifies a constant expression (string, number constant, color constant, point, size, rectangle or font constant).
     */
    AKABindingExpressionTypeAnyConstant = (AKABindingExpressionTypeClassConstant | AKABindingExpressionTypeStringConstant | AKABindingExpressionTypeAnyNumberConstant | AKABindingExpressionTypeAnyColorConstant | AKABindingExpressionTypeCGPointConstant | AKABindingExpressionTypeCGSizeConstant | AKABindingExpressionTypeCGRectConstant | AKABindingExpressionTypeUIFontConstant),

    /**
       Specifies any expression (all supported expression types).
     */
    AKABindingExpressionTypeAny = (AKABindingExpressionTypeAnyKeyPath | AKABindingExpressionTypeAnyConstant | AKABindingExpressionTypeArray)
};


#pragma mark - AKABindingSpecification
#pragma mark -

@interface AKABindingSpecification: NSObject

#pragma mark - Initialization

/**
 Initializes the binding specification from its serialized from.

 @see kAKABindingSpecificationBindingTypeKey kAKABindingSpecificationBindingProviderTypeKey kAKABindingSpecificationBindingTargetSpecificationKey kAKABindingSpecificationBindingExpressionType kAKABindingSpecificationArrayItemBindingProviderTypeKey kAKABindingSpecificationAttributesKey

 @param dictionary a dictionary containing the serialized binding specification

 @return the new binding specification
 */
- (instancetype _Nullable)                 initWithDictionary:(req_NSDictionary)dictionary;

#pragma mark - Conversion

- (void)                                      addToDictionary:(req_NSMutableDictionary)specDictionary;

#pragma mark - Properties

@property(nonatomic, readonly, nullable) Class                              bindingType;

@property(nonatomic, readonly, nonnull) AKABindingProvider*                 bindingProvider;

@property(nonatomic, readonly, nullable) AKABindingTargetSpecification*     bindingTargetSpecification;

@property(nonatomic, readonly, nullable) AKABindingExpressionSpecification* bindingSourceSpecification;

@property(nonatomic, readonly, nullable) AKABindingProvider*                arrayItemBindingProvider;

- (opt_AKABindingProvider)bindingProviderForAttributeWithName:(req_NSString)attributeName;


#pragma mark - Constants
/// @name Constants

/**
 Key in the serialized AKABindingSpecification and AKABindingAttributeSpecification dictionaries corresponding to the property bindingType. The entry is optional and specifies a sub class of AKABinding.
 */
FOUNDATION_EXPORT NSString* _Nonnull const kAKABindingSpecificationBindingTypeKey;

/**
 Key in the serialized AKABindingSpecification and AKABindingAttributeSpecification dictionaries corresponding to the property bindingProvider. The entry is optional and specifies a sub class of AKABindingProvider. The corresponding property returns the shared instance of the provider.
 */
FOUNDATION_EXPORT NSString* _Nonnull const kAKABindingSpecificationBindingProviderTypeKey;

/**
 Key in the serialized AKABindingSpecification and AKABindingAttributeSpecification dictionaries corresponding to the property bindingTargetSpecification. The entry is optional and specifies an AKATypePattern or a serialized type pattern, see [AKATypePattern initWithDictionary:], [AKATypePattern initWithArrayOfClasses:] and [AKATypePattern initWithClass:] for possible values.

 @see AKABindingTargetSpecification AKATypePattern
 */
FOUNDATION_EXPORT NSString* _Nonnull const kAKABindingSpecificationBindingTargetSpecificationKey;

/**
 Key in the serialized AKABindingSpecification and AKABindingAttributeSpecification dictionaries corresponding to the property expressionType. The entry is optional and specifies an options set (AKABindingExpressionType) which specifies the set of valid primary expression types. If not defined, all expression types--including no expression--are valid.
 */
FOUNDATION_EXPORT NSString* _Nonnull const kAKABindingSpecificationBindingExpressionType;

/**
 Key in the serialized AKABindingSpecification and AKABindingAttributeSpecification dictionaries corresponding to the property arrayItemBindingProvider. The entry is optional and only valid if the primary expression is (or can be) an array (AKABindingExpressionTypeArray).
 */
FOUNDATION_EXPORT NSString* _Nonnull const kAKABindingSpecificationArrayItemBindingProviderTypeKey;

/**
 Key in the serialized AKABindingSpecification and AKABindingAttributeSpecification dictionaries corresponding to the property attributes. The entry is optional. If specified, a dictionary with keys of type string containing valid identifiers has to be provided. Attribute values can be instances of AKABindingAttributeSpecification or dictionaries containing serialized attribute binding specifications.
 */
FOUNDATION_EXPORT NSString* _Nonnull const kAKABindingSpecificationAttributesKey;

@end


@interface AKABindingTargetSpecification: NSObject

- (instancetype _Nullable)initWithDictionary:(req_NSDictionary)dictionary;
- (void)addToDictionary:(req_NSMutableDictionary)specDictionary;

@property(nonatomic, readonly, nullable) AKATypePattern*        typePattern;

@end

@interface AKABindingExpressionSpecification: NSObject

- (instancetype _Nullable)initWithDictionary:(req_NSDictionary)dictionary;

/**
   Adds the (serialized) binding expression specification to the specified serialized AKABindingSpecification dictionary.

   @param specDictionary the AKABindingSpecification dictionary
 */
- (void)addToDictionary:(req_NSMutableDictionary)specDictionary;

/**
 * Specifies the set of valid types of the binding expressions primary expression.
 *
 * Please note that key path expressions will have a type of AKAProperty,
 * numeric and boolean constants NSNumber, string constants NSString,
 */
@property(nonatomic, readonly)          AKABindingExpressionType expressionType;

/**
 * Specifies which attributes can be defined in a matching binding expression.
 */
@property(nonatomic, readonly, nonnull) NSDictionary<NSString*, AKABindingAttributeSpecification*>*
    attributes;

/**
 * Specifies the binding provider to be used for items in primary expressions of array type.
 */
@property(nonatomic, readonly, nullable) AKABindingProvider*                arrayItemBindingProvider;

@end

@interface AKABindingAttributeSpecification: AKABindingSpecification

#pragma mark - Constants
/// @name Constants

/**
Key in the serialized AKABindingAttributeSpecification dictionary corresponding to the property required. The entry is optional defaulting to NO and specifies whether the attribute is required in applicable binding expressions.
*/
FOUNDATION_EXPORT NSString* _Nonnull const kAKABindingAttributesSpecificationRequiredKey;

/**
 Key in the serialized AKABindingAttributeSpecification dictionary corresponding to the property use. The entry is mandatory defaulting to AKABindingAttributeUseIgnore and specifies how the attribute is processed by the binding provider when setting up a binding.

 @see AKABindingAttributeUse
 @see kAKABindingAttributesSpecificationBindingPropertyKey
 */
FOUNDATION_EXPORT NSString* _Nonnull const kAKABindingAttributesSpecificationUseKey;

/**
 Key in the serialized AKABindingAttributeSpecification dictionary corresponding to the property bindingProperty. The entry is optional defaulting to attribute's name and specifies the target property in the owner binding, that will be setup using this attribute.

 It is invalid to specify a bindingProperty for AKABindingAttributeUseIgnore.

 @see kAKABindingAttributesSpecificationUseKey
 @see AKABindingAttributeUse
 */
FOUNDATION_EXPORT NSString* _Nonnull const kAKABindingAttributesSpecificationBindingPropertyKey;

#pragma mark - Initialization
/// @name Initialization

/**
 Initializes the binding attribute specification from its serialized from.

 @param dictionary a dictionary containing the serialized binding specification

 @return the new binding attribute specification

 @see AKABindingSpecification
 @see kAKABindingSpecificationBindingTypeKey kAKABindingSpecificationBindingProviderTypeKey kAKABindingSpecificationBindingTargetSpecificationKey kAKABindingSpecificationBindingExpressionType kAKABindingSpecificationArrayItemBindingProviderTypeKey kAKABindingSpecificationAttributesKey
 @see kAKABindingAttributesSpecificationRequiredKey kAKABindingAttributesSpecificationUseKey kAKABindingAttributesSpecificationBindingPropertyKey
 */
- (instancetype _Nullable)initWithDictionary:(req_NSDictionary)dictionary;
- (void)addToDictionary:(req_NSMutableDictionary)specDictionary;

/**
 * Specifies if the attribute has to be provided in matching binding expressions.
 */
@property(nonatomic, readonly)           BOOL required;

@property(nonatomic, readonly)           AKABindingAttributeUse attributeUse;
@property(nonatomic, readonly, nullable) NSString*          bindingPropertyName;

@end

@interface AKATypePattern: NSObject

- (instancetype _Nullable)initWithArrayOfClasses:(req_NSArray)array;
- (instancetype _Nullable)initWithClass:(Class _Nonnull)type;
- (instancetype _Nullable)initWithDictionary:(req_NSDictionary)dictionary;
- (void)addToDictionary:(req_NSMutableDictionary)specDictionary;

@property(nonatomic, readonly, nullable) NSSet<Class>*      acceptedTypes;
@property(nonatomic, readonly, nullable) NSSet<Class>*      rejectedTypes;
@property(nonatomic, readonly, nullable) NSSet<NSString*>*  acceptedValueTypes;
@property(nonatomic, readonly, nullable) NSSet<NSString*>*  rejectedValueTypes;

- (BOOL)matchesObject:(id _Nullable)object;

@end
