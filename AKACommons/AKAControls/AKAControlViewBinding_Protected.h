//
//  AKAControlViewBinding_Protected.h
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAControlViewBinding.h"

@interface AKAControlViewBinding (Protected)

- (instancetype)initWithControl:(AKAControl*)control
                           view:(UIView*)view;

- (AKAProperty*)createViewValueProperty;

@end
