//
//  AKACollectionControlViewBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 19.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKAComplexControlViewBinding.h"
#import "AKACollectionControlViewBindingDelegate.h"

@interface AKACollectionControlViewBinding : AKAComplexControlViewBinding

@property(nonatomic, readonly, nullable) id<AKACollectionControlViewBindingDelegate, AKAControlViewBindingDelegate> delegate;

@end




