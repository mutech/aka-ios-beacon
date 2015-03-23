//
//  AKAControlsErrors.h
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AKACommons/AKAErrors.h>

typedef enum AKAControlsErrorCodes {
    AKATextEditorControlViewRequiresUITextFieldEditor
}

AKAControlsErrorCodes;

@class AKAControl;
@class AKACompositeControl;
@class AKAEditorControlView;

@interface AKAControlsErrors : AKAErrors

+ (NSString*)akaControlsErrorDomain;

+ (BOOL)attemptRecoveryActions;

#pragma mark - Control Ownership

+ (void)invalidAttemptToSetOwnerOfControl:(AKAControl*)control
                                  ownedBy:(AKACompositeControl*)currentOwner
                               toNewOwner:(AKACompositeControl*)owner;

#pragma mark - Composite Control Member Activation

+ (void)invalidAttemptToActivate:(AKAControl*)control
                     inComposite:(AKACompositeControl*)composite
 whileAnotherMemberIsStillActive:(AKAControl*)oldActive
                        recovery:(BOOL(^)())recover;

+ (void)invalidAttemptToActivateNonMemberControl:(AKAControl*)control
                                      inComposite:(AKACompositeControl*)composite;

#pragma mark - ControlView Errors


+ (NSError *)errorForTextEditorControlView:(AKAEditorControlView *)editorControlView
                               invalidView:(id)view
                                   forRole:(NSString*)role
                              expectedType:(Class)type;

@end
