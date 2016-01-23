//
//  AKAEditorControlView_Protected.h
//  AKABeacon
//
//  Created by Michael Utech on 20.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAEditorControlView.h"
#import "AKAThemableContainerView_Protected.h"

@interface AKAEditorControlView (Protected)

- (BOOL)autocreateLabel:(out UIView*__autoreleasing *)createdView;
- (BOOL)autocreateEditor:(out UIView*__autoreleasing *)createdView;
- (BOOL)autocreateMessage:(out UIView*__autoreleasing *)createdView;

@end
