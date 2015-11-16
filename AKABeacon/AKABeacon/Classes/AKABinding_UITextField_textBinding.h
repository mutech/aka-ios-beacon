//
//  AKABinding_UITextField_textBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAKeyboardControlViewBinding.h"


@interface AKABinding_UITextField_textBinding: AKAKeyboardControlViewBinding

@property(nonatomic, nullable) NSFormatter* formatter;
@property(nonatomic, nullable) NSFormatter* editingFormatter;
@property(nonatomic, nullable) NSString*    textForUndefinedValue;
@property(nonatomic) BOOL                   treatEmptyTextAsUndefined;

@end