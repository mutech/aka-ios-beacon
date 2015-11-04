//
//  AKAControlValidatorProtocol.h
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AKAControlValidatorProtocol <NSObject>

- (BOOL)validateModelValue:(id)modelValue error:(NSError**)error;

@end
