//
//  AKAEditorControlView_Protected.h
//  AKAControls
//
//  Created by Michael Utech on 20.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAEditorControlView.h"

@interface AKAEditorControlView (Protected)

- (UILabel*)autoCreateViewForRole_label;
- (UILabel*)autoCreateViewForRole_errorMessageLabel;
- (UIView*)autoCreateViewForRole_editor;

- (BOOL)validateLabel:(inout __autoreleasing id *)ioValue
                error:(out NSError *__autoreleasing *)error;
- (BOOL)validateEditor:(inout __autoreleasing id *)ioValue
                 error:(out NSError *__autoreleasing *)error;
- (BOOL)validateErrorMessageLabel:(inout __autoreleasing id *)ioValue
                            error:(out NSError *__autoreleasing *)error;
- (BOOL)validateView:(inout __autoreleasing id*)ioValue
             forRole:(NSString*)role
        isKindOfType:(Class)type
               error:(out NSError *__autoreleasing *)error;
@end
