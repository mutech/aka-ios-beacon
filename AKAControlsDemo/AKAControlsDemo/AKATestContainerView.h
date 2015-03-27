//
//  AKATestContainerView.h
//  AKAControlsDemo
//
//  Created by Michael Utech on 20.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AKAControls/AKAThemableContainerView.h>

IB_DESIGNABLE
@interface AKATestContainerView : AKAThemableContainerView

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIView* editor;
@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;

@end
