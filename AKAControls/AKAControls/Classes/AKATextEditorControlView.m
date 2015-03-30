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

- (BOOL)subviewSpecificationItem:(AKASubviewsSpecificationItem *)specification
         subviewNotFoundInTarget:(UIView *)containerView
                     createdView:(out UIView *__autoreleasing *)createdView
{
    BOOL result = NO;
    if (containerView == self)
    {
        if (specification.requirements.requirePresent)
        {
            if ([@"editor" isEqualToString:specification.name])
            {
                AKATextField* editor = [[AKATextField alloc] initWithFrame:CGRectZero];
                editor.translatesAutoresizingMaskIntoConstraints = NO;

                editor.valueKeyPath = self.editorBinding;
                editor.role = specification.name;

                editor.text = @"";

                *createdView = editor;
                result = YES;
            }
            else
            {
                result = [super subviewSpecificationItem:specification
                                 subviewNotFoundInTarget:containerView
                                             createdView:createdView];
            }
        }
    }
    return result;
}

@end
