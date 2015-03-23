//
//  AKATestContainerView.h
//  AKAControlsDemo
//
//  Created by Michael Utech on 20.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface AKATestContainerView : UIView

@property (nonatomic)IBInspectable NSString* theme;

@property (nonatomic)IBInspectable BOOL customLayout;

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField* editor;
@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;

@end
