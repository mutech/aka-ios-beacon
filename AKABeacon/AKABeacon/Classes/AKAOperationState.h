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
    AKAOperationStateInitialized            =  1,
    AKAOperationStatePending                =  2,
    AKAOperationStateEvaluatingConditions   =  4,
    AKAOperationStateReady                  =  8,
    AKAOperationStateExecuting              = 16,
    AKAOperationStateFinishing              = 32,
    AKAOperationStateFinished               = 64,
};

typedef NS_OPTIONS(NSUInteger, AKAOperationStateSuccessors)
{
    AKAOperationStateInitializedSuccessors          = AKAOperationStatePending,
    AKAOperationStatePendingSuccessors              = AKAOperationStateEvaluatingConditions | AKAOperationStateReady,
    AKAOperationStateEvaluatingConditionsSuccessors = AKAOperationStateReady | AKAOperationStateFinishing,
    AKAOperationStateReadySuccessors                = AKAOperationStateExecuting | AKAOperationStateFinishing,
    AKAOperationStateExecutingSuccessors            = AKAOperationStateFinishing,
    AKAOperationStateFinishingSuccessors            = AKAOperationStateFinished,
    AKAOperationStateFinishedSuccessors             = 0
};