//
//  AKASubviewsSpecification.m
//  AKABeacon
//
//  Created by Michael Utech on 27.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;
#import "NSString+AKATools.h"
#import "NSObject+AKASelectorTools.h"

#import "AKASubviewsSpecification.h"

@interface AKASubviewsSpecification ()

@property(nonatomic) NSMutableDictionary*subviewSpecificationStorage;

@end

@implementation AKASubviewsSpecification

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.subviewSpecificationStorage = NSMutableDictionary.new;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self)
    {
        [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            (void)stop; // not needed
            if ([key isKindOfClass:[NSString class]])
            {
                NSString* viewName = key;
                if ([obj isKindOfClass:[NSDictionary class]])
                {
                    [self addViewNamed:viewName withDictionary:obj];
                }
                else
                {
                    // TODO: error handling
                }
            }
            else
            {
                // TODO: error handling
            }
        }];
    }
    return self;
}

#pragma mark - Validation

- (BOOL)validateTarget:(UIView*)target
          withDelegate:(id<AKASubviewsSpecificationDelegate>)delegate
           fixProblems:(BOOL)fixProblems
{
    __block BOOL result = YES;

    [self.subviewSpecificationStorage enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        (void)key; // not needed
        (void)stop; // not needed
        AKASubviewsSpecificationItem* item = obj;

        if ([delegate respondsToSelector:@selector(subviewsSpecification:item:willValidateTarget:)])
        {
            [delegate subviewsSpecification:self item:item willValidateTarget:target];
        }
        BOOL itemResult = [item validateTarget:target
                                  withDelegate:delegate
                                   fixProblems:fixProblems];
        if ([delegate respondsToSelector:@selector(subviewsSpecification:item:didValidateTarget:withSuccess:)])
        {
            [delegate subviewsSpecification:self item:item didValidateTarget:target withSuccess:itemResult];
        }
        result &= itemResult;
    }];
    return result;
}

#pragma mark - Access

- (NSDictionary*)subviewSpecificationsByName
{
    return [NSDictionary dictionaryWithDictionary:self.subviewSpecificationStorage];
}

- (NSDictionary*)viewsDictionaryForTarget:(UIView *)containerView
{
    NSMutableDictionary* result = NSMutableDictionary.new;
    [self.subviewSpecificationStorage enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        (void)stop; // not needed
        AKASubviewsSpecificationItem * specification = obj;
        UIView* view = [specification matchingViewInTarget:containerView];
        if (view)
        {
            result[key] = view;
        }
    }];
    return result;
}

#pragma mark - Adding specification items

- (void)addViewNamed:(NSString*)viewName
      withDictionary:(NSDictionary*)viewSpecification
{
    AKASubviewsSpecificationItem * item =
    [[AKASubviewsSpecificationItem alloc] initWithDictionary:viewSpecification
                                                            name:viewName];
    [self addViewSpecificationItem:(AKASubviewsSpecificationItem *)item];
}

- (void)addViewSpecificationItem:(AKASubviewsSpecificationItem *)item
{
    self.subviewSpecificationStorage[item.name] = item;
}

@end

@implementation AKASubviewsSpecificationItem

#pragma mark - Initialization

- (instancetype)initWithName:(NSString*)name
                      outlet:(AKAUnboundProperty*)outlet
                     viewTag:(NSNumber*)viewTag
                requirements:(AKAThemeViewApplicability*)requirements
{
    self = [self init];
    if (self)
    {
        _name = name;
        _outlet = outlet;
        _viewTag = viewTag;
        _requirements = requirements;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
                              name:(NSString*)name
{
    self = [self init];
    if (self)
    {
        __block BOOL explicitOutlet = NO;

        _name = name;
        [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
            (void)stop; // not needed
            if ([@"outlet" isEqualToString:key])
            {
                explicitOutlet = YES;

                NSString* propertyKey = nil;
                if ([obj isKindOfClass:[NSNumber class]])
                {
                    if (((NSNumber*)obj).boolValue)
                    {
                        propertyKey = name;
                    }
                }
                else if ([obj isKindOfClass:[NSString class]])
                {
                    propertyKey = (NSString*)obj;
                }
                else
                {
                    // TODO: error handling
                }

                if (propertyKey.length > 0)
                {
                    self->_outlet = [AKAUnboundProperty unboundPropertyWithKeyPath:propertyKey];
                }
            }
            else if ([@"viewTag" isEqualToString:key])
            {
                if ([obj isKindOfClass:[NSNumber class]])
                {
                    self->_viewTag = @(((NSNumber*)obj).integerValue);
                }
                else
                {
                    // TODO: error handling
                }
            }
            else if ([@"requirements" isEqualToString:key])
            {
                self->_requirements = [[AKAThemeViewApplicability alloc] initWithSpecification:obj];
            }
            else
            {
                // TODO: error handling
            }
        }];

        if (!explicitOutlet && self.outlet == nil && self.name.length > 0)
        {
            _outlet = [AKAUnboundProperty unboundPropertyWithKeyPath:self.name];
        }
    }
    return self;
}

#pragma mark - Auto Creation

- (UIView*)matchingViewInTarget:(UIView*)superView
{
    UIView* result = nil;
    if (result == nil && self.outlet)
    {
        result = [self.outlet valueForTarget:superView];
    }
    if (result == nil && self.viewTag)
    {
        result = [superView viewWithTag:self.viewTag.integerValue];
    }
    if (result == nil && [@"self" isEqualToString:self.name])
    {
        result = superView;
    }
    return result;
}

- (BOOL)validateTarget:(UIView*)target
          withDelegate:(id<AKASubviewSpecificationItemDelegate>)delegate
           fixProblems:(BOOL)fixProblems
{
    BOOL result = NO;

    UIView* view = [self matchingViewInTarget:target];
    BOOL viewIsTarget = (view == target && target != nil);

    BOOL viewCreatedByDelegate = NO;
    if (view == nil && [delegate respondsToSelector:@selector(subviewSpecificationItem:subviewNotFoundInTarget:createdView:)])
    {
        viewCreatedByDelegate = [delegate subviewSpecificationItem:self
                                             subviewNotFoundInTarget:target
                                                         createdView:&view];
        if (view != nil && !viewCreatedByDelegate)
        {
            // It might not know, but obviously it did create it...
            viewCreatedByDelegate = YES;
        }
    }
    result = view != nil;

    if (result)
    {
        BOOL viewTagSpecified = (self.viewTag != nil);
        BOOL viewTagCorrect = viewTagSpecified && self.viewTag.integerValue == view.tag;
        if (viewTagSpecified && !viewTagCorrect)
        {
            BOOL viewTagCorrectedByDelegate = NO;
            if ([delegate respondsToSelector:@selector(subviewSpecificationItem:target:view:tagValue:differsFromExpectedValue:)])
            {
                viewTagCorrectedByDelegate = [delegate subviewSpecificationItem:self
                                                                         target:target
                                                                           view:view
                                                                       tagValue:view.tag
                                                       differsFromExpectedValue:self.viewTag.integerValue];
                viewTagCorrect = self.viewTag.integerValue == view.tag;
            }

            if (!viewTagCorrect && !viewTagCorrectedByDelegate && fixProblems)
            {
                view.tag = self.viewTag.integerValue;
                viewTagCorrect = YES;
            }
        }

        BOOL outletSpecified = self.outlet != nil;
        BOOL outletUsable = NO;
        if (outletSpecified)
        {
            id outletValue = [self.outlet valueForTarget:target];
            outletUsable = outletValue == view;
            if (!outletUsable && [delegate respondsToSelector:@selector(subviewSpecificationItem:target:outlet:doesNotReferToView:)])
            {
                [delegate subviewSpecificationItem:self
                                            target:target
                                            outlet:self.outlet
                                doesNotReferToView:view];
                outletUsable = outletValue == view;
            }

            if (!outletUsable && outletValue == nil && fixProblems)
            {
                [self.outlet setValue:view forTarget:target];
                outletValue = [self.outlet valueForTarget:target];
                outletUsable = outletValue == view;
            }
        }

        BOOL viewIsIdentifiable = viewTagCorrect || outletUsable || viewIsTarget;
        if (!viewIsIdentifiable)
        {
            result = NO;
            if ([delegate respondsToSelector:@selector(subviewSpecificationItem:createdView:willNotBeFoundInTarget:)])
            {
                [delegate subviewSpecificationItem:self createdView:view willNotBeFoundInTarget:target];
            }
        }
        else if (!viewIsTarget)
        {
            BOOL viewIsDescendant = [view isDescendantOfView:target];
            BOOL viewAddedByDelegate = NO;
            if (!viewIsDescendant && viewCreatedByDelegate && [delegate respondsToSelector:@selector(subviewSpecificationItem:createdView:isNotSubviewOfTarget:)])
            {
                viewAddedByDelegate = [delegate subviewSpecificationItem:self
                                                             createdView:view
                                                    isNotSubviewOfTarget:target];
                viewIsDescendant = [view isDescendantOfView:target];
            }

            if (!viewIsDescendant && !viewAddedByDelegate && fixProblems)
            {
                [target addSubview:view];
                viewIsDescendant = [view isDescendantOfView:target];
            }

            if (!viewIsDescendant && [delegate respondsToSelector:@selector(subviewSpecificationItem:createdView:willNotBeFoundInTarget:)])
            {
                [delegate subviewSpecificationItem:self createdView:view willNotBeFoundInTarget:target];
            }
        }
    }

    if (self.requirements)
    {
        // Requirements are the last instance of determining the result. If even after failures
        // the requirements are satisfied, the result is positive.
        result = [self.requirements isApplicableToView:view];
        if (!result && [delegate respondsToSelector:@selector(subviewSpecificationItem:target:view:doesNotMeetRequirements:)])
        {
            [delegate subviewSpecificationItem:self
                                        target:target
                                          view:view
                       doesNotMeetRequirements:self.requirements];
        }
    }

    return result;
}

@end
