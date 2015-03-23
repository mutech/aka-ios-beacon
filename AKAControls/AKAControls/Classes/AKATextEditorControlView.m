//
//  AKATextEditorControlView.m
//  AKAControls
//
//  Created by Michael Utech on 20.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATextEditorControlView.h"
#import "AKAEditorControlView_Protected.h"
#import "AKATextField.h"
#import "AKAControlsErrors.h"

@implementation AKATextEditorControlView

- (UIView *)autoCreateViewForRole_editor
{
    UITextField* result = [[AKATextField alloc] initWithFrame:CGRectZero];
    result.translatesAutoresizingMaskIntoConstraints = NO;

    result.borderStyle = UITextBorderStyleRoundedRect;
    result.placeholder = self.labelText;
    if ([result isKindOfClass:[AKATextField class]])
    {
        AKATextField* aka = (AKATextField*)result;
        if (self.controlName.length > 0)
        {
            aka.controlName = [self.controlName stringByAppendingString:@"_editor"];
        }
        aka.role = @"editor";
        aka.valueKeyPath = self.editorValueKeyPath;
    }
    else
    {
        result.tag = 20; // TODO: get this from role specification
    }

    return result;
}

- (BOOL)validateEditor:(inout __autoreleasing id *)ioValue
                 error:(out NSError *__autoreleasing *)error
{
    return [self validateView:ioValue
                      forRole:@"editor"
                 isKindOfType:[UITextField class]
                        error:error];
}

@end
