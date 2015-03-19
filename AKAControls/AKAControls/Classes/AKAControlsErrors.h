//
//  AKAControlsErrors.h
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AKACommons/AKAErrors.h>

@class AKAControl;
@class AKACompositeControl;

@interface AKAControlsErrors : AKAErrors

+ (NSString*)akaControlsErrorDomain;

+ (BOOL)attemptRecoveryActions;

+ (void)invalidAttemptToActivate:(AKAControl*)control
                     inComposite:(AKACompositeControl*)composite
 whileAnotherMemberIsStillActive:(AKAControl*)oldActive
                        recovery:(BOOL(^)())recover;

+ (void)invalidAttemptToActivateNonMemberControl:(AKAControl*)control
                                      inComposite:(AKACompositeControl*)composite;

@end
