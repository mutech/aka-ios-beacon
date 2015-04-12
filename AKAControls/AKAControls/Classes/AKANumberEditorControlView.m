//
//  AKANumberEditorControlView.m
//  AKAControls
//
//  Created by Michael Utech on 12.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKANumberEditorControlView.h"
#import "AKANumberTextField.h"

@implementation AKANumberEditorControlView

#pragma mark - AKAEditorControlView overrides

- (BOOL)autocreateEditor:(out UIView *__autoreleasing *)createdView
{
    // TODO: Either use AKATextField (not sure if AKANumberTextField is
    // a good idea anyway) or refactor autocreation to undo this
    // copy&paste job here:
    AKATextField* editor = [[AKANumberTextField alloc] initWithFrame:CGRectZero];
    BOOL result = editor != nil;

    if (result)
    {
        editor.valueKeyPath = self.valueKeyPath;
        editor.autoActivate = self.autoActivate;
        editor.KBActivationSequence = self.KBActivationSequence;
        editor.liveModelUpdates = self.liveModelUpdates;
        editor.validatorKeyPath = self.validatorKeyPath;
        editor.converterKeyPath = self.converterKeyPath;

        editor.text = @"";

        *createdView = editor;
    }

    return result;
}

@end
