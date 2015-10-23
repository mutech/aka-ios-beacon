//
//  AKAScalarControl.h
//  AKAControls
//
//  Created by Michael Utech on 14.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAControl.h"

@interface AKAScalarControl : AKAControl

#pragma mark - Value Access

@property(nonatomic, nullable) id                               viewValue;

@property(nonatomic, nullable) id                               modelValue;

#pragma mark - Conversion

- (BOOL)                                       convertViewValue:(opt_id)viewValue
                                                   toModelValue:(out_id)modelValueStorage
                                                          error:(out_NSError)error;

- (BOOL)                                      convertModelValue:(opt_id)modelValue
                                                    toViewValue:(out_id)viewValueStorage
                                                          error:(out_NSError)error;

@end


@interface AKAScalarControl (Protected)

#pragma mark - Initialization

@end
