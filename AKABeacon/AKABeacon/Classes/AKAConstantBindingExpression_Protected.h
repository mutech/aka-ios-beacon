//
//  AKAConstantBindingExpression.h
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAConstantBindingExpression.h"


@interface AKAConstantBindingExpression(Protected)

// Redefined to provide constant setter to sub subclasses
@property(nonatomic, nullable) id constant;

@end
