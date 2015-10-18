//
//  AKAControl.h
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
@import AKACommons.AKAProperty;

#import "AKAControlConfiguration.h"
#import "AKAControlDelegate.h"
#import "AKABindingContextProtocol.h"
#import "AKAControlViewBinding.h"


@class AKACompositeControl;

typedef AKAControl* _Nullable opt_AKAControl;
typedef AKAControl* _Nonnull  req_AKAControl;

typedef NS_ENUM(NSInteger, AKAControlValidationState)
{

    AKAControlValidationStateNotValidated = 0,

    AKAControlValidationStateModelValueValid =      1 << 0,
    AKAControlValidationStateViewValueValid =       1 << 1,
    AKAControlValidationStateValid =                (AKAControlValidationStateModelValueValid |
                                                     AKAControlValidationStateViewValueValid),

    AKAControlValidationStateModelValueInvalid =    1 << 2,
    AKAControlValidationStateViewValueInvalid =     1 << 3,

    AKAControlValidationStateModelValueDirty =      1 << 4,
    AKAControlValidationStateViewValueDirty =       1 << 5
};


@interface AKAControl: NSObject

#pragma mark - Configuration

@property(nonatomic, readonly, weak, nullable)AKACompositeControl*          owner;

@property(nonatomic, readonly, weak, nullable)UIView*                       view;

@property(nonatomic, readonly, nullable) NSString*                          name;

@property(nonatomic, readonly, nullable) NSSet<NSString*>*                  tags;

@property(nonatomic, readonly, nullable) NSString*                          role;

#pragma mark - Validation

- (void)setValidationState:(AKAControlValidationState)validationState
                 withError:(opt_NSError)error;

@property(nonatomic, readonly) AKAControlValidationState                    validationState;

@property(nonatomic, readonly, nullable) NSError*                           validationError;

@property(nonatomic, readonly) BOOL                                         isValid;

@end


@interface AKAControl(BindingContext)<AKABindingContextProtocol>
@end


#import "AKABinding.h"
@interface AKAControl(BindingsOwner)

- (NSUInteger)                     addBindingsForView:(req_UIView)view;

- (BOOL)                            addBindingForView:(req_UIView)view
                                             property:(req_SEL)property
                                withBindingExpression:(req_AKABindingExpression)bindingExpression;

- (BOOL)                                   addBinding:(req_AKABinding)binding;

- (BOOL)                                removeBinding:(req_AKABinding)binding;

@end


@interface AKAControl(ObsoleteThemeSupport)

- (nullable AKAProperty*)themeNamePropertyForView:(req_UIView)view
                                   changeObserver:(void(^_Nullable)(opt_id oldValue, opt_id newValue))themeNameChanged;

- (void)setThemeName:(opt_NSString)themeName forClass:(req_Class)type;

@end


@interface AKAControl(Obsolete)

#pragma mark - Change Tracking
/// @name Change tracking

- (void)startObservingChanges;

- (void)stopObservingChanges;

@property(nonatomic, readonly) BOOL isObservingChanges;

#pragma mark - Keyboard Activation Sequence

@property(nonatomic, readonly) BOOL shouldAutoActivate;

@property(nonatomic, readonly) BOOL participatesInKeyboardActivationSequence;

#pragma mark - Diagnostics

@property(nonatomic, readonly, nullable) NSString* debugDescriptionDetails;

@end

