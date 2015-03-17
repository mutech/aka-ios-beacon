//
//  AKAControlConverterProtocol.h
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AKAControlConverterProtocol <NSObject>

- (BOOL)convertViewValue:(id)viewValue
            toModelValue:(id*)modelValueStorage
                   error:(NSError**)error;

- (BOOL)convertModelValue:(id)modelValue
              toViewValue:(id)viewValueStorage
                    error:(NSError*)error;

@end
