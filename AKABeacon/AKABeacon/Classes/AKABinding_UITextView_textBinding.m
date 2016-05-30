//
//  AKABinding_UITextView_textBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 09.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAProperty.h"
#import "UIView+AKAHierarchyVisitor.h"

#import "AKABinding_UITextView_textBinding.h"

@interface AKABinding_UITextView_textBinding () <UITextViewDelegate>

#pragma mark - Saved UITextView State

#if RESTORE_BOUND_VIEW_STATE
@property(nonatomic, nullable) NSString*                   originalText;
#endif

@property(nonatomic, weak) id<UITextViewDelegate>          savedTextViewDelegate;
@property(nonatomic, nullable) NSString*                   previousText;

#pragma mark - Convenience

@property(nonatomic, readonly) UITextView*                 textView;

@end


@implementation AKABinding_UITextView_textBinding

+ (AKABindingSpecification *)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        // see specification defined in AKAKeyboardControlViewBindingProvider:
        NSDictionary* spec =
        @{ @"bindingType":          [AKABinding_UITextView_textBinding class],
           @"targetType":           [UITextView class],
           @"expressionType":       @(AKABindingExpressionTypeString)
           };

        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    return result;
}

#pragma mark - Initialization

- (void)validateTarget:(req_id)target
{
    NSParameterAssert([target isKindOfClass:[UITextView class]]);
}

- (req_AKAProperty)createBindingTargetPropertyForTarget:(req_id)view
{
    NSParameterAssert(view == nil || [view isKindOfClass:[UITextView class]]);
    (void)view;

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                AKABinding_UITextView_textBinding* binding = target;

                return binding.textView.text;
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_UITextView_textBinding* binding = target;

                if (value == nil || [value isKindOfClass:[NSString class]])
                {
                    binding.textView.text = value;
                }
                else if (value != nil)
                {
                    binding.textView.text = [NSString stringWithFormat:@"%@", value];
                }
            }
                          observationStarter:
            ^BOOL (id target)
            {
                AKABinding_UITextView_textBinding* binding = target;
                UITextView* textView = binding.textView;
                id<UITextViewDelegate> textViewDelegate = textView.delegate;

                if (textViewDelegate != binding)
                {
#if RESTORE_BOUND_VIEW_STATE
                    binding.originalText = textView.text;
#endif
                    binding.savedTextViewDelegate = textViewDelegate;
                    textView.delegate = binding;
                }

                return YES;
            }
                          observationStopper:
            ^BOOL (id target)
            {
                AKABinding_UITextView_textBinding* binding = target;
                UITextView* textView = binding.textView;
                id<UITextViewDelegate> textViewDelegate = textView.delegate;

                if (textViewDelegate == binding)
                {
                    textView.delegate = binding.savedTextViewDelegate;
                    binding.savedTextViewDelegate = nil;
#if RESTORE_BOUND_VIEW_STATE
                    textView.text = binding.originalText;
                    binding.originalText = nil;
#endif
                }

                return YES;
            }];
}

#pragma mark - Properties

- (UITextView*)textView
{
    UIView* result = self.target;

    NSParameterAssert(result == nil || [result isKindOfClass:[UITextView class]]);

    return (UITextView*)result;
}

- (void)                          setSavedTextViewDelegate:(id<UITextViewDelegate>)savedTextViewDelegate
{
    NSAssert(savedTextViewDelegate != self, @"Cannot register text view binding as saved delegate, it already acts as replacement/proxy delegate");

    _savedTextViewDelegate = savedTextViewDelegate;
}

#pragma mark - Change Observation

- (void)                                viewValueDidChange
{
    NSString* oldValue = self.previousText;
    NSString* newValue = self.textView.text;

    // Send change notification
    if (newValue != oldValue && ![newValue isEqualToString:oldValue])
    {
        [self targetValueDidChangeFromOldValue:oldValue toNewValue:newValue];
        newValue = self.textView.text; // the delegate may change the value
    }

    if (newValue != oldValue && ![newValue isEqualToString:oldValue])
    {
        [self.targetValueProperty notifyPropertyValueDidChangeFrom:oldValue to:newValue];
        self.previousText = newValue;
    }
}

#pragma mark - Activation

- (BOOL)                                supportsActivation
{
    BOOL result = self.textView != nil;

    return result;
}

- (BOOL)                                shouldAutoActivate
{
    BOOL result = self.supportsActivation && self.autoActivate;

    return result;
}

#pragma mark - Keyboard Activation Sequence

- (void)                    setResponderInputAccessoryView:(UIView*)responderInputAccessoryView
{
    self.textView.inputAccessoryView = responderInputAccessoryView;
}

#pragma mark - Obsolete (probably) Delegate Support Methods

- (BOOL)                                    shouldActivate
{
    return YES;
}

- (BOOL)                                  shouldDeactivate
{
    return YES;
}

#pragma mark - UITextViewDelegate Implementation

- (BOOL)                        textViewShouldBeginEditing:(UITextView*)textView
{
    id<UITextViewDelegate> secondary = self.savedTextViewDelegate;

    BOOL result = YES;

    if ([secondary respondsToSelector:@selector(textViewShouldBeginEditing:)])
    {
        result = [secondary textViewShouldBeginEditing:textView];
    }

    if (result)
    {
        result = [self shouldActivate];
    }

    if (result)
    {
        [self responderWillActivate:self.textView];
    }

    return result;
}

- (void)                           textViewDidBeginEditing:(UITextView*)textView
{
    NSParameterAssert(textView == self.textView);
    id<UITextViewDelegate> secondary = self.savedTextViewDelegate;

    self.previousText = self.textView.text;
    [self responderDidActivate:self.textView];

    if ([secondary respondsToSelector:@selector(textViewDidBeginEditing:)])
    {
        [secondary textViewDidBeginEditing:textView];
    }
}

- (void)                        textViewDidChangeSelection:(UITextView*)textView
{
    NSParameterAssert(textView == self.textView);
    id<UITextViewDelegate> secondary = self.savedTextViewDelegate;

    if ([secondary respondsToSelector:@selector(textViewDidChangeSelection:)])
    {
        [secondary textViewDidChangeSelection:textView];
    }
}

- (BOOL)                                          textView:(UITextView*)textView
                                   shouldChangeTextInRange:(NSRange)range
                                           replacementText:(NSString*)text
{
    NSParameterAssert(textView == self.textView);
    id<UITextViewDelegate> secondary = self.savedTextViewDelegate;

    BOOL result = YES;

    if ([secondary respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)])
    {
        result = [secondary      textView:textView
                  shouldChangeTextInRange:range
                          replacementText:text];
    }

    return result;
}

- (BOOL)                                          textView:(UITextView*)textView
                                     shouldInteractWithURL:(NSURL*)URL
                                                   inRange:(NSRange)characterRange
{
    NSParameterAssert(textView == self.textView);
    id<UITextViewDelegate> secondary = self.savedTextViewDelegate;

    BOOL result = YES;

    if ([secondary respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:)])
    {
        result = [secondary    textView:textView
                  shouldInteractWithURL:URL
                                inRange:characterRange];
    }

    return result;
}

- (BOOL)                                          textView:(UITextView*)textView
                          shouldInteractWithTextAttachment:(NSTextAttachment*)textAttachment
                                                   inRange:(NSRange)characterRange
{
    NSParameterAssert(textView == self.textView);
    id<UITextViewDelegate> secondary = self.savedTextViewDelegate;

    BOOL result = YES;

    if ([secondary respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:)])
    {
        result = [secondary               textView:textView
                  shouldInteractWithTextAttachment:textAttachment
                                           inRange:characterRange];
    }

    return result;
}

- (void)                                 textViewDidChange:(UITextView*)textView
{
    NSParameterAssert(textView == self.textView);
    id<UITextViewDelegate> secondary = self.savedTextViewDelegate;

    if ([secondary respondsToSelector:@selector(textViewDidChange:)])
    {
        [secondary textViewDidChange:textView];
    }

    // TODO: consider to centralize scrolling/resizing in base view bindings or in form control view (-delegate?)
    [self autoScrollToVisibleIfNeeded];

    if (self.liveModelUpdates)
    {
        [self viewValueDidChange];
    }
}

- (BOOL)                          textViewShouldEndEditing:(UITextView*)textView
{
    NSParameterAssert(textView == self.textView);
    id<UITextViewDelegate> secondary = self.savedTextViewDelegate;

    BOOL result = YES;

    if ([secondary respondsToSelector:@selector(textViewShouldEndEditing:)])
    {
        result &= [secondary textViewShouldEndEditing:textView];
    }

    result &= [self shouldDeactivate];

    return result;
}

- (void)                             textViewDidEndEditing:(UITextView*)textView
{
    NSParameterAssert(textView == self.textView);
    id<UITextViewDelegate> secondary = self.savedTextViewDelegate;

    if ([secondary respondsToSelector:@selector(textViewDidEndEditing:)])
    {
        [secondary textViewDidEndEditing:textView];
    }

    if (!self.liveModelUpdates)
    {
        [self viewValueDidChange];
    }

    [self responderDidDeactivate:textView];
}

#pragma mark - Hacks

- (void)                       autoScrollToVisibleIfNeeded
{
    // see also https://github.com/damienpontifex/BlogCodeSamples/issues/1#issuecomment-147236647

    UITextView* textView = self.textView;

    // We only attempt to do the scrolling if the text view's own scrolling is disabled
    // TODO: we probably should ascend the view hierarchy and adjust scroll positions everywhere to ensure maximum visibility of edited content.
    if (!textView.isScrollEnabled)
    {
        UITextPosition* _Nullable selectedTextRangeEnd = textView.selectedTextRange.end;

        if (selectedTextRangeEnd)
        {
            CGRect cursorR = [textView caretRectForPosition:(UITextPosition * _Nonnull)selectedTextRangeEnd];
            UITableView* tableView = [textView aka_superviewOfType:[UITableView class]];

            if (tableView)
            {
                BOOL animateScrolling = NO;

                // Resize text view if needed
                if (tableView.rowHeight == UITableViewAutomaticDimension)
                {
                    // If textView grew vertically, ensure that the enclosing
                    // table view cell is resized by calling begin/end updates
                    CGSize size = textView.frame.size;
                    CGSize newSize = [textView sizeThatFits:CGSizeMake(size.width, FLT_MAX)];

                    if (size.height != newSize.height)
                    {
                        // Do not animate if text view shrinked, because that looks ugly if the
                        // text view is the last cell (TODO: test all the million edge cases here)
                        animateScrolling &= newSize.height > size.height;

                        // Disable animations to prevent table view from jumping up and down
                        // (Bug in iOS8/9)
                        BOOL wasAnimating = [UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        [tableView beginUpdates];
                        [tableView endUpdates];
                        [UIView setAnimationsEnabled:wasAnimating];

                        // If we needed to resize the textview, we have to query the caret position again
                        // after resizing, because it will otherwise now have the position x=INF,y=INF
                        cursorR = [textView caretRectForPosition:(UITextPosition * _Nonnull)selectedTextRangeEnd];
                    }
                }

                // Get text field position relative to scroll view
                CGRect absoluteR = [textView convertRect:textView.frame
                                                  toView:tableView];
                CGPoint position = absoluteR.origin;
                // Compose rectangle we want to see (includes an additional line of text for some
                // trailing context if there is any).
                CGRect scrollR = CGRectMake(cursorR.origin.x + position.x,
                                            cursorR.origin.y + position.y,
                                            cursorR.size.width, cursorR.size.height + textView.font.pointSize * 1.1f);
                [tableView scrollRectToVisible:scrollR animated:animateScrolling];
            }
            else
            {
                // Not tested:
                UIScrollView* enclosingScrollView = [textView aka_superviewOfType:[UIScrollView class]];

                if (enclosingScrollView)
                {
                    // Get text field position relative to scroll view
                    CGRect absoluteR = [textView convertRect:textView.frame
                                                      toView:enclosingScrollView];
                    CGPoint position = absoluteR.origin;
                    // Compose rectangle we want to see (here we might want to add some space above or below, see about that later).
                    CGRect scrollR = CGRectMake(cursorR.origin.x + position.x,
                                                cursorR.origin.y + position.y,
                                                cursorR.size.width, cursorR.size.height);
                    [enclosingScrollView scrollRectToVisible:scrollR animated:YES];
                }
            }
        }
    }
}

@end
