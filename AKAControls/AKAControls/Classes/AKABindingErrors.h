//
//  AKABindingErrors.h
//  AKAControls
//
//  Created by Michael Utech on 31.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAControlsErrors.h"
#import "AKABindingExpression.h"
#import "AKABindingContextProtocol.h"

typedef NS_ENUM(NSInteger, AKABindingErrorCodes)
{
    AKABindingErrorUndefinedBindingSource = AKABindingErrorCodesMin,
};

@interface AKABindingErrors : AKAControlsErrors

+ (NSError*)bindingErrorUndefinedBindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                                    context:(req_AKABindingContext)bindingContext;

@end
