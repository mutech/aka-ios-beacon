//
//  AKAControlViewProtocol.h
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AKAControl;
@class AKACompositeControl;
@class AKAControlViewBinding;
@class AKAProperty;

@protocol AKAControlViewProtocol <NSObject>

@property(nonatomic, weak, readonly) AKAControlViewBinding* controlBinding;

- (AKAControlViewBinding*)bindToControl:(AKAControl*)control;

- (AKAControl*)createControlWithDataContext:(id)dataContext;

- (AKAControl*)createControlWithOwner:(AKACompositeControl *)owner;

@end

@protocol AKAEditingControlViewProtocol <AKAControlViewProtocol>

#pragma mark - Interface Builder Properties

// Implementation Note: IB does not recognize IBInspectable properties
// in protocols, you have to redeclare the properties in your
// UIView implementation to be able to set it in IB.

/**
 * The key path refering to the controls model value relative to
 * the controls data context.
 */
@property(nonatomic) IBInspectable NSString* valueKeyPath;

@end