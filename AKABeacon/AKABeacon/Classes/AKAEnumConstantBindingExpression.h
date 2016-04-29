//
//  AKAEnumConstantBindingExpression.h
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAConstantBindingExpression.h"


@interface AKAEnumConstantBindingExpression: AKAConstantBindingExpression

@property(nonatomic, nullable) NSString* enumerationType;
@property(nonatomic, nullable) NSString* symbolicValue;

@end
