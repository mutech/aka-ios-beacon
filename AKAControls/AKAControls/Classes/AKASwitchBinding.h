//
//  AKASwitchControlViewBinding.h
//  AKAControls
//
//  Created by Michael Utech on 31.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAObsoleteViewBinding.h"

#pragma mark - AKASwitchControlViewBinding
#pragma mark -

@interface AKASwitchBinding: AKAObsoleteViewBinding

#pragma mark - State

@property(nonatomic, weak) id<UITextFieldDelegate> savedSwitchDelegate;

@end

#pragma mark - AKASwitchControlViewBindingConfiguration
#pragma mark -

@interface AKASwitchBindingConfiguration: AKAObsoleteViewBindingConfiguration
@end