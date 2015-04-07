//
//  AKASwitchEditorControlView.m
//  AKAControls
//
//  Created by Michael Utech on 30.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKASwitchEditorControlView.h"
#import "AKAEditorControlView_Protected.h"
#import "AKASwitch.h"

@implementation AKASwitchEditorControlView

- (BOOL)autocreateEditor:(out UIView *__autoreleasing *)createdView
{
    AKASwitch* editor = [[AKASwitch alloc] initWithFrame:CGRectZero];
    BOOL result = editor != nil;

    if (result)
    {
        editor.valueKeyPath = self.valueKeyPath;

        editor.on = NO;

        *createdView = editor;
    }
    
    return result;
}

@end
