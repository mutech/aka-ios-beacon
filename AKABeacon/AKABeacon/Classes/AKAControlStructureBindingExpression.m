//
//  AKAControlStructureBindingExpression.m
//  AKABeacon
//
//  Created by Michael Utech on 10.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAControlStructureBindingExpression.h"
#import "AKABeaconErrors.h"
#import "AKABindingExpression_Internal.h"


#pragma mark - AKAConstantBindingExpression
#pragma mark -

@implementation AKAControlStructureBindingExpression

#pragma mark - Initialization

// TODO:

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeAbstract;
}


#pragma mark - Diagnostics

- (BOOL)isConstant
{
    return NO;
}

- (NSString*)constantStringValueOrDescription
{
    return @"Control Structure Expression";
}

#pragma mark - Serialization

// TODO

@end


