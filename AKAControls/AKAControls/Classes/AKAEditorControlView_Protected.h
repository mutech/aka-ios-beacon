//
//  AKAEditorControlView_Protected.h
//  AKAControls
//
//  Created by Michael Utech on 20.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAEditorControlView.h"

@interface AKAEditorControlView (Protected)

- (BOOL)autocreateLabel:(out UIView*__autoreleasing *)createdView;
- (BOOL)autocreateEditor:(out UIView*__autoreleasing *)createdView;
- (BOOL)autocreateMessage:(out UIView*__autoreleasing *)createdView;

@end
