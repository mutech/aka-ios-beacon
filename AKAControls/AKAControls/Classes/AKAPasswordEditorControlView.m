//
//  AKAPasswordEditorControlView.m
//  AKAControls
//
//  Created by Michael Utech on 30.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAPasswordEditorControlView.h"
#import "AKAEditorControlView_Protected.h"

@implementation AKAPasswordEditorControlView

- (BOOL)autocreateEditor:(out UIView *__autoreleasing *)createdView
{
    BOOL result = [super autocreateEditor:createdView];
    if (result && [*createdView isKindOfClass:[UITextField class]])
    {
        UITextField* textField = (id)*createdView;
        textField.secureTextEntry = YES;
    }
    return result;
}

@end