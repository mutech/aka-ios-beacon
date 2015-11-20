//
//  Created by Michael Utech on 17.11.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;

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