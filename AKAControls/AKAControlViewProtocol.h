//
//  AKAControlViewProtocol.h
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

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
