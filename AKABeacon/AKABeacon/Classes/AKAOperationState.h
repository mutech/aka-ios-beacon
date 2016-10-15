//
//  AKAOperationState.h
//  AKABeacon
//
//  Created by Michael Utech on 08.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;

typedef NS_OPTIONS(NSUInteger, AKAOperationState)
{
    AKAOperationStateInitialized            =   1,
    AKAOperationStateEnqueuing              =   2,
    AKAOperationStatePending                =   4,
    AKAOperationStateEvaluatingConditions   =   8,
    AKAOperationStateReady                  =  16,
    AKAOperationStateExecuting              =  32,
    AKAOperationStateFinishing              =  64,
    AKAOperationStateFinished               = 128,
};

typedef NS_OPTIONS(NSUInteger, AKAOperationStateSuccessors)
{
    AKAOperationStateInitializedSuccessors          = AKAOperationStateEnqueuing,
    AKAOperationStateEnqueuingSuccessors            = AKAOperationStatePending,
    AKAOperationStatePendingSuccessors              = AKAOperationStateEvaluatingConditions | AKAOperationStateReady | AKAOperationStateFinishing,
    AKAOperationStateEvaluatingConditionsSuccessors = AKAOperationStateReady | AKAOperationStateFinishing,
    AKAOperationStateReadySuccessors                = AKAOperationStateExecuting | AKAOperationStateFinishing,
    AKAOperationStateExecutingSuccessors            = AKAOperationStateFinishing,
    AKAOperationStateFinishingSuccessors            = AKAOperationStateFinished,
    AKAOperationStateFinishedSuccessors             = 0
};
