//
//  AKATapGestureRecognizerBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 28.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAPropertyBinding.h"


@interface AKATapGestureRecognizerBinding : AKAPropertyBinding

@property(nonatomic, weak) NSObject* target;
@property(nonatomic, readonly) SEL action;
@property(nonatomic) NSString* actionSelectorName;

@end
