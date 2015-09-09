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

@synthesize autoActivate = _autoActivate;
@synthesize KBActivationSequence = _KBActivationSequence;
@synthesize liveModelUpdates = _liveModelUpdates;

#pragma mark - AKATextFieldControlViewBindingConfigurationProtocol

- (void)setupDefaultValues
{
    [super setupDefaultValues];
    self.liveModelUpdates = NO;
    self.autoActivate = YES;
    self.KBActivationSequence = YES;
}

- (void)setAutoActivate:(BOOL)autoActivate
{
    _autoActivate = autoActivate;
    if ([self.editor isKindOfClass:[AKATextField class]])
    {
        ((AKATextField*)self.editor).autoActivate = autoActivate;
    }
}

- (void)setKBActivationSequence:(BOOL)KBActivationSequence
{
    _KBActivationSequence = KBActivationSequence;
    if ([self.editor isKindOfClass:[AKATextField class]])
    {
        ((AKATextField*)self.editor).KBActivationSequence = KBActivationSequence;
    }
}

- (void)setLiveModelUpdates:(BOOL)liveModelUpdates
{
    _liveModelUpdates = liveModelUpdates;
    if ([self.editor isKindOfClass:[AKATextField class]])
    {
        ((AKATextField*)self.editor).liveModelUpdates = liveModelUpdates;
    }
}

#pragma mark - AKAEditorControlView overrides

- (BOOL)autocreateEditor:(out UIView *__autoreleasing *)createdView
{
    AKATextField* editor = [[AKATextField alloc] initWithFrame:CGRectZero];
    BOOL result = editor != nil;

    if (result)
    {
        editor.autoActivate = self.autoActivate;
        editor.KBActivationSequence = self.KBActivationSequence;
        editor.liveModelUpdates = self.liveModelUpdates;

        editor.text = @"";

        *createdView = editor;
    }

    return result;
}

@end