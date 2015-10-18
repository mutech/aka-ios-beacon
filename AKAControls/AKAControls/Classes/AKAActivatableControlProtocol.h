//
//  AKAActivatableControlProtocol.h
//  AKAControls
//
//  Created by Michael Utech on 16.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAControl.h"

@protocol AKAAutoActivatableControlProtocol <NSObject>

@property(nonatomic, readonly) BOOL isActive;

- (BOOL)autoActivate;
- (void)didActivate;

- (BOOL)shouldDeactivate;
- (BOOL)deactivate;
- (void)didDeactivate;

@end

@protocol AKAActivatableControlProtocol <AKAAutoActivatableControlProtocol>

- (BOOL)activate;

@end

typedef AKAControl<AKAAutoActivatableControlProtocol> AKAAutoActivatableControl;
typedef AKAControl<AKAActivatableControlProtocol>     AKAActivatableControl;
