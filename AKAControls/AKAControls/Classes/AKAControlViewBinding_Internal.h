//
//  AKAControlViewBinding_Internal.h
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAControlViewBinding_Protected.h"

@protocol AKAControlViewProtocol;
@protocol AKAControlViewBindingConfigurationProtocol;

@interface AKAControlViewBinding (Internal)

+ (AKAControlViewBinding*)bindingOfType:(Class)preferredBindingType
                        withControlView:(UIView<AKAControlViewProtocol>*)view
                           controlOwner:(AKACompositeControl*)owner;

+ (AKAControlViewBinding*)bindingOfType:(Class)preferredBindingType
                      withConfiguration:(id<AKAControlViewBindingConfigurationProtocol>)configuration
                                   view:(UIView*)view
                           controlOwner:(AKACompositeControl*)owner;

@end
