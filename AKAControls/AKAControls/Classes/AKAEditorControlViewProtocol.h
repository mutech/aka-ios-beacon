//
//  AKAEditorControlViewProtocol.h
//  AKAControls
//
//  Created by Michael Utech on 20.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AKAControlViewProtocol.h"
#import "AKAEditorControlViewBindingConfigurationProtocol.h"

@protocol AKAEditorControlViewProtocol <
    AKAControlViewProtocol,
    AKAEditorControlViewBindingConfigurationProtocol>

@end
