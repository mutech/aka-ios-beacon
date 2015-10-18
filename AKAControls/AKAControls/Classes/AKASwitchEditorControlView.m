//
//  AKASwitchEditorControlView.m
//  AKAControls
//
//  Created by Michael Utech on 30.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKASwitchEditorControlView.h"
#import "AKAEditorControlView_Protected.h"
#import "UISwitch+AKAIBBindingProperties.h"

@implementation AKASwitchEditorControlView

- (BOOL)autocreateEditor:(out UIView *__autoreleasing *)createdView
{
    UISwitch* editor = [[UISwitch alloc] initWithFrame:CGRectZero];
    BOOL result = editor != nil;

    if (result)
    {
        editor.stateBinding_aka = self.editorBinding;

        editor.on = NO;

        *createdView = editor;
    }
    
    return result;
}

@end
