//
//  AKABinding_UISearchBar_textBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 21.09.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAKeyboardControlViewBinding.h"

@interface AKABinding_UISearchBar_textBinding: AKAKeyboardControlViewBinding

@property(nonatomic, nullable) NSFormatter* formatter;
@property(nonatomic, nullable) NSFormatter* editingFormatter;
@property(nonatomic, nullable) NSString*    textForUndefinedValue;
@property(nonatomic) BOOL                   treatEmptyTextAsUndefined;

@end
