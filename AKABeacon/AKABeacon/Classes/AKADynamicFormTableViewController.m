//
//  AKADynamicFormTableViewController.m
//  AKABeacon
//
//  Created by Michael Utech on 14.12.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.UIView_AKAHierarchyVisitor;

#import "AKADynamicFormTableViewController.h"
#import "AKABindingContextProtocol.h"
#import "UIView+AKABindingSupport.h"
#import "AKABinding.h"

@interface AKADynamicFormTableViewCellBindingContext: NSObject<AKABindingContextProtocol>

- (instancetype)initWithRoot:(id<AKABindingContextProtocol>)root
                 dataContext:(id)dataContext;

@property(nonatomic, readonly)id<AKABindingContextProtocol> rootContext;
@property(nonatomic, readonly)id dataContext;

@end

@implementation AKADynamicFormTableViewCellBindingContext

- (instancetype)initWithRoot:(id<AKABindingContextProtocol>)root
                 dataContext:(id)dataContext
{
    if (self = [self init])
    {
        _rootContext = root;
        _dataContext = dataContext;
    }
    return self;
}

- (id)dataContextValueForKeyPath:(NSString *)keyPath
{
    return [self dataContextPropertyForKeyPath:keyPath
                            withChangeObserver:nil].value;
}

- (id)rootDataContextValueForKeyPath:(NSString *)keyPath
{
    return [self rootDataContextPropertyForKeyPath:keyPath
                                withChangeObserver:nil].value;
}

- (id)controlValueForKeyPath:(NSString *)keyPath
{
    return [self controlPropertyForKeyPath:keyPath
                        withChangeObserver:nil].value;
}

- (AKAProperty *)dataContextPropertyForKeyPath:(NSString *)keyPath
                            withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    return [AKAProperty propertyOfWeakKeyValueTarget:self.dataContext
                                             keyPath:keyPath
                                      changeObserver:valueDidChange];
}

- (AKAProperty *)rootDataContextPropertyForKeyPath:(NSString *)keyPath
                                withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    return [self.rootContext dataContextPropertyForKeyPath:keyPath
                                        withChangeObserver:valueDidChange];
}

- (AKAProperty *)controlPropertyForKeyPath:(NSString *)keyPath
                        withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    (void)keyPath;
    (void)valueDidChange;
    return nil;
}

@end


@interface AKADynamicFormTableViewController() <AKABindingContextProtocol>
@end

@implementation AKADynamicFormTableViewController

- (BOOL)renderCell:(UITableViewCell *)cell
   withDataContext:(id)dataContext
             error:(out_NSError)error
{
    __block BOOL result = YES;
    id<AKABindingContextProtocol> bindingContext =
        [[AKADynamicFormTableViewCellBindingContext alloc] initWithRoot:self
                                                            dataContext:dataContext];
    __strong UIView* contentView = cell.contentView;
    [contentView aka_enumerateSelfAndSubviewsUsingBlock:
     ^(UIView *view, BOOL *stopEnumeratingViews, BOOL *doNotDescend)
     {
         (void)doNotDescend;
         [view aka_enumerateBindingExpressionsWithBlock:
          ^(SEL _Nonnull property, req_AKABindingExpression expression, BOOL * _Nonnull stop)
          {
              (void)property;
              result = [AKABinding applyBindingExpression:expression
                                                 toTarget:view
                                                inContext:bindingContext
                                                    error:error];
              *stop = !result;
          }];
         *stopEnumeratingViews = !result;
     }];
    return result;
}

#pragma mark - AKABindingContextProtocol

- (id)dataContextValueForKeyPath:(NSString *)keyPath
{
    return [self dataContextPropertyForKeyPath:keyPath
                            withChangeObserver:nil].value;
}

- (id)rootDataContextValueForKeyPath:(NSString *)keyPath
{
    return [self rootDataContextPropertyForKeyPath:keyPath
                                withChangeObserver:nil].value;
}

- (id)controlValueForKeyPath:(NSString *)keyPath
{
    return [self controlPropertyForKeyPath:keyPath
                        withChangeObserver:nil].value;
}

- (AKAProperty *)dataContextPropertyForKeyPath:(NSString *)keyPath
                            withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    return [AKAProperty propertyOfWeakKeyValueTarget:self
                                             keyPath:keyPath
                                      changeObserver:valueDidChange];
}

- (AKAProperty *)rootDataContextPropertyForKeyPath:(NSString *)keyPath
                                withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    return [self dataContextPropertyForKeyPath:keyPath
                            withChangeObserver:valueDidChange];
}

- (AKAProperty *)controlPropertyForKeyPath:(NSString *)keyPath
                        withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    (void)keyPath;
    (void)valueDidChange;
    return nil;
}

@end
