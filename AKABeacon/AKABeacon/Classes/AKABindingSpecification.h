//
//  AKABindingSpecification.h
//  AKABeacon
//
//  Created by Michael Utech on 26.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
@import AKACommons.AKANullability;


#pragma mark - Forward Declaration & Type Aliases
#pragma mark -

@class AKABindingProvider;
typedef AKABindingProvider* _Nullable opt_AKABindingProvider;

@class AKATypePattern;
typedef AKATypePattern*_Nonnull                         req_AKATypePattern;
typedef AKATypePattern*_Nullable                        opt_AKATypePattern;

@class AKABindingSpecification;
typedef AKABindingSpecification*_Nonnull                req_AKABindingSpecification;
typedef AKABindingSpecification*_Nullable               opt_AKABindingSpecification;

@class AKABindingTargetSpecification;
typedef AKABindingTargetSpecification*_Nonnull          req_AKABindingTargetSpecification;
typedef AKABindingTargetSpecification*_Nullable         opt_AKABindingTargetSpecification;

@class AKABindingExpressionSpecification;
typedef AKABindingExpressionSpecification* _Nonnull     req_AKABindingExpressionSpecification;
typedef AKABindingExpressionSpecification* _Nullable    opt_AKABindingExpressionSpecification;

@class AKABindingAttributeSpecification;
typedef AKABindingAttributeSpecification* _Nonnull req_AKABindingAttributeSpecification;
typedef AKABindingAttributeSpecification* _Nullable opt_AKABindingAttributeSpecification;


#pragma mark - AKABindingAttributeUse (Enumeration)
#pragma mark -

/**
   Specifies how a binding attribute is processed by a binding provider when it sets up a binding.
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


#pragma mark - AKABindingExpressionType (Enumeration)
#pragma mark -

/**
   Specifies the type of a binding expression's primary expression.
 */
typedef NS_OPTIONS(uint_fast64_t, AKABindingExpressionType)
{
    /**
     Specifies an abstract binding expression type. Abstract types cannot be validly instanciated and it is not valid to include the abstract type in a set of valid expression types in binding specifications.
     */
    AKABindingExpressionTypeAbstract = (1 << 0),

    // None has to be the first valid type:

    /**
     Specifies a binding expression with no primary expression.
     */
    AKABindingExpressionTypeNone = (1 << 1),

    /**
       Specifies an unqualified key path, e.g. a key path with no leading scope (such as $data, $root, $control)
     */
    AKABindingExpressionTypeUnqualifiedKeyPath = (1 << 2),

    /**
       Specifies a key path relative to the data context ($data).
     */

    AKABindingExpressionTypeDataContextKeyPath = (1 << 3),

    /**
       Specifies a key path relative to the top level data context ($root).
     */
    AKABindingExpressionTypeRootDataContextKeyPath = (1 << 4),

    /**
       Specifies a key path relative to the owner of the binding ($control).

       @note This expression type and scope might be removed or renamed in a future version if bindings will be decoupled from controls for applications which want to use bindings manually.
     */
    AKABindingExpressionTypeControlKeyPath = (1 << 5),

    /**
       Specifies an array primary expression (e.g. ["x", "y"]).
     */
    AKABindingExpressionTypeArray = (1 << 6),

    /**
       Specifies a class primary expression (e.g. <ClassName>)
     */
    AKABindingExpressionTypeClassConstant = (1 << 10),

    /**
       Specifies a constant string expression (e.g. "abc")
     */
    AKABindingExpressionTypeStringConstant = (1 << 11),

    /**
       Specifies a boolean constant expression.

       Boolean values are specified as $true or $false. Boolean values can be omitted in attribute specifications ({a, b, c} instead of {a:$true, b:$true, c:$true}), then the presence of an attribute means the value $true, and its absence $false.
     */
    AKABindingExpressionTypeBooleanConstant = (1 << 12),

    /**
       Specifies an integer constant (e.g. 123).

       All integer constants are internally represented as NSNumber initialized with a long long value.
     */
    AKABindingExpressionTypeIntegerConstant = (1 << 13),

    /**
       Specifies a double constant (e.g. 0.5).

       Double constants are distinguished from integer constants by the presence of a decimal point. So '0' is an integer and '.0' or '0.' is a double.
     */
    AKABindingExpressionTypeDoubleConstant = (1 << 14),

    /**
       Specifies an options constant (e.g. $options.OptionType { Value1, Value2 })

       Option values are specified as valueless (or boolean) attributes.

       Options can optionally specify an options type as pseudo key path.

       Options which specify a known options type can be statically evaluated to an integer constant. Options with options type can only be evaluated if the binding provides the options type. (which it often does for expected options values such as specified attributes).
     
       If an options constant does not specify a value, the value 0 is assumed.
     */
    AKABindingExpressionTypeOptionsConstant = (1 << 15),

    /**
     Specifies an enumeration constant (e.g. $enum.EnumType.Value or $enum.Value)

     Enumeration constants can optionally specify an enumeration type and value as pseudo key path.
     
     Enumerations which specify a known type can be statically evaluated to a constant value (which
     is not restricted to integer numbers). If no type is specified, enumeration values can only
     be evaluated if the binding provides the enumeration type (which it often does for expected enumeration values such as specified attributes).
     
     If an enumeration constant does not specify a value, the value nil is assumed.
     */
    AKABindingExpressionTypeEnumConstant = (1 << 16),

    /**
       Specifies a UIColor constant (e.g. $UIColor{r:123, g:123, b:123, a:255})

       Color constant components are specified by mandatory attributes "red", "green" and "blue" and an optional alpha channel or "r", "g", "b" and "a". Components can be specified as integer values in the range [0 .. 255] or as double values in the range [0.0 .. 1.0].
     */
    AKABindingExpressionTypeUIColorConstant = (1 << 17),

    /**
       Specifies a CGColor constant (e.g. $CGColor{r:123, g:123, b:123, a:255}).

       Color constant components are given as mandatory attributes "red", "green" and "blue" and an optional alpha channel or "r", "g", "b" and "a". Components can be specified as integer values in the range [0 .. 255] or as double values in the range [0.0 .. 1.0].
     */
    AKABindingExpressionTypeCGColorConstant = (1 << 18),

    /**
       Specifies a CGPoint constant (e.g. $CGPoint{x:0.0, y:0.0}).

       Point coordinates are specified as mandatory attributes "x" and "y" with double values.
     */
    AKABindingExpressionTypeCGPointConstant = (1 << 19),

    /**
       Specifies a CGSize constant (e.g. $CGSize{w:1.0, h:1.0}).

       Size dimensions are specified as mandatory attributes "width" and "height" or "w" and "h" with double values.
     */
    AKABindingExpressionTypeCGSizeConstant = (1 << 20),

    /**
       Specifies a CGRect constant (e.g. $CGRect{x:1.0, y:1.0, w:1.0, h:1.0}).

       Rectangle coordinates and dimensions are specified as mandatory attributes "x", "y", "width", "height" or "w", "h" with double values.
     */
    AKABindingExpressionTypeCGRectConstant = (1 << 21),

    /**
       Specifies a UIFont constant (e.g. $UIFont{name:"Helvetica Neue", size:15.0}).

       TODO: document attributes.
     */
    AKABindingExpressionTypeUIFontConstant = (1 << 22),

    /**
       Specifies all key path types (unqualified, data context, root data context, control).
     */
    AKABindingExpressionTypeAnyKeyPath = (AKABindingExpressionTypeUnqualifiedKeyPath |
                                          AKABindingExpressionTypeDataContextKeyPath |
                                          AKABindingExpressionTypeRootDataContextKeyPath |
                                          AKABindingExpressionTypeControlKeyPath),

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

     @note key path expressions might not evaluate to a boolean.
     */
    AKABindingExpressionTypeBoolean = (AKABindingExpressionTypeAnyKeyPath | AKABindingExpressionTypeBooleanConstant),

    /**
       Specifies an integer or key path expression.

     @note key path expressions might not evaluate to an integer.
     */
    AKABindingExpressionTypeInteger = (AKABindingExpressionTypeAnyKeyPath | AKABindingExpressionTypeIntegerConstant),

    /**
       Specifies a double or key path expression.

       @note key path expressions might not evaluate to a double.
     */
    AKABindingExpressionTypeDouble = (AKABindingExpressionTypeAnyKeyPath | AKABindingExpressionTypeDoubleConstant),

    /**
       Specifies a UIColor or CGColor constant expression.
     */
    AKABindingExpressionTypeAnyColorConstant = (AKABindingExpressionTypeUIColorConstant | AKABindingExpressionTypeCGColorConstant),

    /**
     Specifies a number constant expression (integer (long logn) or double)
     */
    AKABindingExpressionTypeAnyNumberConstant = (AKABindingExpressionTypeIntegerConstant |
                                                 AKABindingExpressionTypeDoubleConstant),


    /**
     Specifies a number constant, key path or enum expression.
     
     @note key path and enum expressions might not evaluate to a number.
     */
    AKABindingExpressionTypeNumber= (AKABindingExpressionTypeAnyKeyPath |
                                     AKABindingExpressionTypeAnyNumberConstant |
                                     AKABindingExpressionTypeEnumConstant |
                                     AKABindingExpressionTypeOptionsConstant |
                                     AKABindingExpressionTypeBooleanConstant),

    /**
       Specifies a constant expression (string, number constant, color constant, point, size, rectangle or font constant).
     */
    AKABindingExpressionTypeAnyConstant = (AKABindingExpressionTypeClassConstant     |
                                           AKABindingExpressionTypeStringConstant    |
                                           AKABindingExpressionTypeBooleanConstant   |
                                           AKABindingExpressionTypeAnyNumberConstant |
                                           AKABindingExpressionTypeAnyColorConstant  |
                                           AKABindingExpressionTypeCGPointConstant   |
                                           AKABindingExpressionTypeCGSizeConstant    |
                                           AKABindingExpressionTypeCGRectConstant    |
                                           AKABindingExpressionTypeUIFontConstant),

    /**
       Specifies any expression (all supported expression types).
     */
    AKABindingExpressionTypeAny = (AKABindingExpressionTypeAnyKeyPath | AKABindingExpressionTypeAnyConstant | AKABindingExpressionTypeArray)
};


#pragma mark - AKABindingSpecification
#pragma mark -

@interface AKABindingSpecification: NSObject

#pragma mark - Initialization
/// @name Initialization

/**
 Creates a new instance using the specified extension based on this instance.

 @param extension the specification containing the extensions

 @return a new specification based on this instance created by adding (or overriding) items with the specified extension.
*/
- (nonnull instancetype)             specificationExtendedWith:(req_AKABindingSpecification)extension;

- (nullable instancetype)                   initWithDictionary:(req_NSDictionary)dictionary
                                                       basedOn:(opt_AKABindingSpecification)base;

#pragma mark - Conversion
/// @name Conversion

- (void)                                       addToDictionary:(req_NSMutableDictionary)specDictionary;

#pragma mark - Properties
/// @name Properties

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


#pragma mark - AKABindingTargetSpecification
#pragma mark -

@interface AKABindingTargetSpecification: NSObject

#pragma mark - Initialization

- (nullable instancetype)                   initWithDictionary:(req_NSDictionary)dictionary;

- (nullable instancetype)                   initWithDictionary:(req_NSDictionary)dictionary
                                                       basedOn:(opt_AKABindingTargetSpecification)base;
#pragma mark - Conversion

- (void)addToDictionary:(req_NSMutableDictionary)              specDictionary;

@property(nonatomic, readonly, nullable) AKATypePattern*       typePattern;

@end


#pragma mark - AKABindingExpressionSpecification
#pragma mark -

@interface AKABindingExpressionSpecification: NSObject

#pragma mark - Initialization
/// @name Initialization

- (nullable instancetype)                   initWithDictionary:(req_NSDictionary)dictionary;

- (nullable instancetype)                   initWithDictionary:(req_NSDictionary)dictionary
                                                       basedOn:(opt_AKABindingExpressionSpecification)base;

#pragma mark - Conversion
/// @name Conversion

/**
   Adds the (serialized) binding expression specification to the specified serialized AKABindingSpecification dictionary.

   @param specDictionary the AKABindingSpecification dictionary
 */
- (void)                                       addToDictionary:(req_NSMutableDictionary)specDictionary;

#pragma mark - Properties
/// @name Properties

/**
 * Specifies the set of valid types of the binding expressions primary expression.
 *
 * Please note that key path expressions will have a type of AKAProperty,
 * numeric and boolean constants NSNumber, string constants NSString,
 */
@property(nonatomic, readonly) AKABindingExpressionType        expressionType;

/**
 * Specifies which attributes can be defined in a matching binding expression.
 */
@property(nonatomic, readonly, nonnull)
NSDictionary<NSString*, AKABindingAttributeSpecification*>*    attributes;

/**
 * Specifies the binding provider to be used for items in primary expressions of array type.
 */
@property(nonatomic, readonly, nullable) AKABindingProvider*   arrayItemBindingProvider;

@property(nonatomic, readonly) BOOL                            allowUnspecifiedAttributes;

@property(nonatomic, readonly, nullable) NSString*             enumerationType;

@property(nonatomic, readonly, nullable) NSString*             optionsType;

#pragma mark - Enumeration and Options Constant Registry
// @name Registering enumeration and options types

/**
 Registers a name/value mapping for the enumeration with the specified enumeration type name.

 Once registered, your enumeration can be used in binding expressions as "$enum.YourType.YourValue" or if the enumeration type is known in the context simply as "$enum.YourValue".

 It's best practice to register enumeration types from a dispatch_once block before they are first used.

 Please note that while in most cases you would use integer number values, you can store any type of values in the valuesByName dictionary. The only requirement is that the values are constant.

 Enumerations are similar to options, except that options allow to specify multiple values and are restricted to integer number values.

 @warning Options and Enumerations may share the same namespace!

 @param enumerationTypeName Globally unique name of the enumeration. Use the type name of the enumeration for standard enumeration type mappings and be sure to use non conflicting names for custom enumerations.

 @param valuesByName a dictionary mapping enumeration symbols (identifiers) to enumeration values. By beacon convention, Swift style enum values are used (e.g. CurrencyStyle instead of UINumberFormatterCurrencyStyle).
 */
+ (void)                               registerEnumerationType:(req_NSString)enumerationTypeName
                                              withValuesByName:(NSDictionary<NSString*, id>*_Nonnull)valuesByName;

/**
 Registers a name/value mapping for the options type with the specified options (enum) type name.

 Once registered, your options type can be used in binding expressions as "$options.YourType.YourValue", "$options.YourType{Value1, Value2}" or if the options type is known in the context simply as "$options{Value1, Value2}".

 It's best practice to register options types from a dispatch_once block before they are first used.

 Please note that options type values are restricted to integer number values (internally represented as long long). Use them in favor to enumerations if you want to supply multiple values and if option values are defined as bit flags.

 @warning Options and Enumerations may share the same namespace!

 @param enumerationTypeName Globally unique name of the enumeration. Use the type name of the enumeration for standard enumeration type mappings and be sure to use non conflicting names for custom enumerations.
 @param valuesByName a dictionary mapping enumeration symbols (identifiers) to enumeration values. By beacon convention, Swift style enum values are used (e.g. CurrencyStyle instead of UINumberFormatterCurrencyStyle).
 */
+ (void)                                   registerOptionsType:(req_NSString)optionsTypeName
                                              withValuesByName:(NSDictionary<NSString*, NSNumber*>*_Nonnull)valuesByName;

#pragma mark - Expression Type (Set) Names
// @name Accessing expression type and type set names

/**
 Maps expression types (not expression sets, such as AKABindingExpressionTypeAny) to their names.

 @return a dictionary with expression type code to name mappings.
 */
+ (NSDictionary<NSNumber*, NSString*>*_Nonnull)                expressionTypeNamesByCode;

/**
 Maps expression types sets (not expression, such as AKABindingExpressionBoolean) to their names.

 @return a dictionary with expression type set code to name mappings.
 */
+ (NSDictionary<NSNumber*, NSString*>*_Nonnull)                expressionTypeSetNamesByCode;

/**
 Returns a description for the specified expression type. If the specified type is a set, the result of expressionTypeSetDescription: is returned instead.

 @param expressionType an expression type or an expression type set.

 @return a string of the form "ExprType" or "ExprTypeSet {ExprType1,...}" or "{ExprType1,...}"
 */
+ (opt_NSString)                     expressionTypeDescription:(AKABindingExpressionType)expressionType;

/**
 Returns a description for the specified expression type set, consisting of the sets name (if it is a named set) and the member types comma separated in curly braces.

 @param expressionType an expression type set.

 @return a string of the form "ExprTypeSet {ExprType1,...}" or "{ExprType1,...}"
 */
+ (opt_NSString)                  expressionTypeSetDescription:(AKABindingExpressionType)expressionType;

@end


#pragma mark - AKABindingAttributeSpecification
#pragma mark -

@interface AKABindingAttributeSpecification: AKABindingSpecification

#pragma mark - Initialization
/// @name Initialization

//- (nullable instancetype)                   initWithDictionary:(req_NSDictionary)dictionary;

- (nullable instancetype)                   initWithDictionary:(req_NSDictionary)dictionary
                                 basedOnAttributeSpecification:(opt_AKABindingAttributeSpecification)attributeBase
                                       expressionSpecification:(opt_AKABindingExpressionSpecification)expressionBase;

#pragma mark - Conversion
/// @name Conversion

- (void)addToDictionary:(req_NSMutableDictionary)              specDictionary;

/**
 Specifies if the attribute has to be provided in matching binding expressions.
 */
@property(nonatomic, readonly) BOOL                            required;

/**
 Specifies how the attribute is used to set up the binding.
 
 @see AKABindingAttributeUse
 */
@property(nonatomic, readonly) AKABindingAttributeUse          attributeUse;

/**
 If attributeUse specifies that the attributes value is to be stored in a property of
 the binding object, bindingPropertyName specifies the name of that property. If nil,
 the attribute name is used as default property name.
 */
@property(nonatomic, readonly, nullable) NSString*             bindingPropertyName;


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

@end


#pragma mark - AKATypePattern
#pragma mark -

@interface AKATypePattern: NSObject

#pragma mark - Initialization
/// @name Initialization

- (nullable instancetype)                   initWithDictionary:(req_NSDictionary)dictionary;

- (nullable instancetype)                   initWithDictionary:(req_NSDictionary)dictionary
                                                       basedOn:(opt_AKATypePattern)base;

- (instancetype _Nullable)              initWithArrayOfClasses:(req_NSArray)array;

- (instancetype _Nullable)              initWithArrayOfClasses:(req_NSArray)array
                                                       basedOn:(opt_AKATypePattern)base;

- (instancetype _Nullable)                       initWithClass:(Class _Nonnull)type;

- (instancetype _Nullable)                       initWithClass:(Class _Nonnull)type
                                                       basedOn:(opt_AKATypePattern)base;

#pragma mark - Conversion
/// @name Conversion

- (void)                                       addToDictionary:(req_NSMutableDictionary)specDictionary;

#pragma mark - Properties
/// @name Properties

@property(nonatomic, readonly, nullable) NSSet<Class>*         acceptedTypes;

@property(nonatomic, readonly, nullable) NSSet<Class>*         rejectedTypes;

@property(nonatomic, readonly, nullable) NSSet<NSString*>*     acceptedValueTypes;

@property(nonatomic, readonly, nullable) NSSet<NSString*>*     rejectedValueTypes;

- (BOOL)matchesObject:(id _Nullable)object;

@end
