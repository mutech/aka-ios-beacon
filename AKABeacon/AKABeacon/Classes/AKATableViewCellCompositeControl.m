//
//  AKATableViewCellCompositeControl.h
//  AKABeacon
//
//  Created by Michael Utech on 26.04.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKATableViewCellCompositeControl.h"
#import "AKACompositeControl_Internal.h"
#import "AKAControl_Internal.h"
#import "AKADynamicPlaceholderTableViewCell.h"
#import "AKACompositeControl_Internal.h"
#import "AKAFormTableViewController.h"
#import "AKAPropertyBinding.h"
#import "NSObject+AKAConcurrencyTools.h"

@interface AKATableViewCellCompositeControl()

@property(nonatomic) BOOL excluded;
@property(nonatomic) AKAPropertyBinding* excludedBinding;

@end


@implementation AKATableViewCellCompositeControl

#pragma mark - Diagnostics

- (NSString *)debugDescriptionDetails
{
    NSString* result = [NSString stringWithFormat:@"cell@[%ld-%ld]: %@, configuration: { %@ }",
                        (long)self.indexPath.section, (long)self.indexPath.row,
                        @"-"/*self.view.description*/,
                        @"-"/*self.viewBinding.configuration.description*/];
    return result;
}

- (BOOL)excluded
{
    BOOL result = NO;
    if ([self.tableView.dataSource isKindOfClass:[AKAFormTableViewController class]])
    {
        AKAFormTableViewController* tvController = (id)self.tableView.dataSource;

        result = [tvController isRowControlHidden:self];
    }
    return result;
}

- (void)setExcluded:(BOOL)excluded
{
    if (self.tableViewController)
    {
        AKAFormTableViewController* tvController = self.tableViewController;

        [self aka_performBlockInMainThreadOrQueue:^{
            BOOL wasExcluded = [tvController isRowControlHidden:self];
            if (YES || excluded != wasExcluded)
            {
                if (excluded)
                {
                    [tvController hideRowControls:@[ self ]
                                 withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                else
                {
                    [tvController unhideRowControls:@[ self ]
                                   withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
        } waitForCompletion:NO];
    }
}

- (NSUInteger)                     addBindingsForView:(req_UIView)view
{
    __block NSUInteger result = [super addBindingsForView:view];

    if ([view isKindOfClass:[AKATableViewCell class]])
    {
        AKATableViewCell* cell = (id)view;
        NSString* bindingExpressionText = cell.excludedBinding_aka;
        if (bindingExpressionText.length > 0)
        {
            NSError* localError;
            AKABindingExpression* bindingExpression =
                [AKABindingExpression bindingExpressionWithString:bindingExpressionText
                                                      bindingType:[AKAPropertyBinding class]
                                                            error:&localError];
            if (bindingExpression)
            {
                AKAProperty* excludedProperty = [AKAProperty propertyOfWeakTarget:self
                                                                           getter:
                                                 ^id _Nullable(id  _Nonnull target)
                                                 {
                                                     AKATableViewCellCompositeControl* control = target;
                                                     return @(control.excluded);
                                                 }
                                                                           setter:
                                                 ^(id  _Nonnull target, id  _Nullable value)
                                                 {
                                                     AKATableViewCellCompositeControl* control = target;
                                                     control.excluded = [value boolValue];
                                                 }];

                self.excludedBinding = [AKAPropertyBinding bindingToTarget:self
                                                       targetValueProperty:excludedProperty
                                                            withExpression:bindingExpression
                                                                   context:self
                                                                     owner:self
                                                                  delegate:nil
                                                                     error:&localError];
                NSAssert(self.excludedBinding, @"Failed to add binding: %@", localError.localizedDescription);
                if (self.isObservingChanges)
                {
                    [self.excludedBinding startObservingChanges];
                }
            }
            else
            {
                @throw [NSException exceptionWithName:@"InvalidBindingExpression"
                                               reason:localError.localizedDescription
                                             userInfo:@{ @"error": localError }];
            }
        }

    }

    return result;
}

- (void)startObservingChanges
{
    [super startObservingChanges];
    [self.excludedBinding startObservingChanges];
}

- (void)stopObservingChanges
{
    [self.excludedBinding stopObservingChanges];
    [super stopObservingChanges];
}

@end
