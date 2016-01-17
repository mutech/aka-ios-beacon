//
//  AKAArrayPropertyBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 06.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAPropertyBinding.h"

@class AKAArrayPropertyBinding;

@protocol AKAArrayPropertyBindingDelegate <AKABindingDelegate>

@optional
- (void)                                            binding:(AKAArrayPropertyBinding*_Nonnull)binding
                                     sourceArrayItemAtIndex:(NSUInteger)arrayItemIndex
                                                      value:(opt_id)oldValue
                                                didChangeTo:(opt_id)newValue;

@end


@interface AKAArrayPropertyBinding : AKAPropertyBinding
@end
