//
//  AKAEditorControlView.h
//  AKACommons
//
//  Created by Michael Utech on 15.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AKAThemableCompositeControlView.h"

#import "AKACompositeViewBindingConfiguration.h"
#import "AKAViewBinding.h"

IB_DESIGNABLE
/**
 * Control view comprised of a label, an editor and an optional
 * messageLabel view.
 *
 * The purpose of this control view is to unify the layout of form fields
 * across an application (or a visual context) without having to update
 * a potentially huge set of views and constraints on the storyboard whenever
 * you want to change the layout.
 *
 * The view also serves as base class for a number of implementations
 * such as AKATextEditorControlView or AKASwitchEditorControlView
 * which adopt specific control views as editor views. These implementations
 * are designed to be used directly in the storyboard, while this class
 * requires some assitance by the developer who has to add the editor
 * view as subview and setup the editor outlet identifying the editor.
 *
 * It is generally preferrable to use specific implementations if they
 * exist for the control type you need and if the IB configuration options
 * you need to customize are passed through by the specific editor control
 * view.
 *
 * Editor control views create the subviews they need by themselves
 * (with the exception of the editor view in this base class) unless they
 * are provided as subview on the storyboard. This means that you can
 * use your own implementations simply by dragging them into the editor
 * view and by setting up the corresponding outlet.
 *
 * If you add a subview, you will probably want to add layout constraints
 * to silence interface builder warnings. You should mark them as plaeholder
 * constraints to prevent them from beeing added to live views. If you do
 * not do that, they will be replaced whenever you apply a theme to the
 * editor control view.
 *
 * Editor control views support live rendering to show you what the views
 * will look like. When you add your own subview, you will probably want to
 * disable the preview option because otherwise both your subviews and
 * the created views will be displayed (this is only an esthetical issue).
 */
@interface AKAEditorControlView : AKAThemableCompositeControlView

#pragma mark - Interface Builder and Binding Configuration Properties

/**
 * The key path refering to the controls model value relative to
 * the controls data context.
 */
@property(nonatomic) IBInspectable NSString* valueKeyPath;

/**
 * The key path refering to the view's editor's value
 */
@property(nonatomic) IBInspectable NSString* editorKeyPath;

/**
 * The text of the editor view's label. Please note that if a labelKeyPath is defined, it
 * will override the label text.
 */
@property(nonatomic) IBInspectable NSString* labelText;

/**
 * The key path refering to the view's label's text relative to the controls data context.
 */
@property(nonatomic) IBInspectable NSString* labelKeyPath;

#pragma mark - Outlets

@property(nonatomic, weak) IBOutlet UILabel* label;
@property(nonatomic, weak) IBOutlet UIView* editor;
@property(nonatomic, weak) IBOutlet UILabel* messageLabel;

@end

@interface AKAEditorBindingConfiguration : AKACompositeViewBindingConfiguration

/**
 * The key path refering to the view's editor's value
 */
@property(nonatomic) NSString* editorKeyPath;

/**
 * The text of the editor view's label. Please note that if a labelKeyPath is defined, it
 * will override the label text.
 */
@property(nonatomic) NSString* labelText;

/**
 * The key path refering to the view's label's text relative to the controls data context.
 */
@property(nonatomic) NSString* labelKeyPath;

@end

@interface AKAEditorBinding: AKAViewBinding
@end