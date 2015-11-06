//
//  AKATextEditorControlView.h
//  AKABeacon
//
//  Created by Michael Utech on 20.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAEditorControlView.h"

IB_DESIGNABLE
@interface AKATextEditorControlView : AKAEditorControlView

@property(nonatomic) IBInspectable BOOL liveModelUpdates;
@property(nonatomic) IBInspectable BOOL autoActivate;
@property(nonatomic) IBInspectable BOOL KBActivationSequence;

@end

IB_DESIGNABLE
@interface AKATextLabelEditorControlView : AKAEditorControlView

@end
