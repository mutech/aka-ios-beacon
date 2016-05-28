//
//  UITableView+AKAIBBindingProperties.h
//  AKABeacon
//
//  Created by Michael Utech on 06.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;
#import "AKAControlViewProtocol.h"


IB_DESIGNABLE
@interface UITableView(AKAIBBindingProperties_datasourceBinding) <AKAControlViewProtocol>

@property(nonatomic, nullable)IBInspectable NSString* dataSourceBinding_aka;

@end
