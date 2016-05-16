//
//  AKACommons.h
//  AKACommons
//
//  Created by Michael Utech on 11.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for AKACommons.
FOUNDATION_EXPORT double AKACommonsVersionNumber;

//! Project version string for AKACommons.
FOUNDATION_EXPORT const unsigned char AKACommonsVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <AKACommons/PublicHeader.h>

#import <AKACommons/AKALog.h>
#import <AKACommons/AKAErrors.h>
#import <AKACommons/AKAReference.h>
#import <AKACommons/AKAProperty.h>
#import <AKACommons/AKANullability.h>

// UI/TableViews/
#import <AKACommons/AKATVMultiplexedDataSource.h>
#import <AKACommons/AKATVProxy.h>
#import <AKACommons/AKATVDataSourceSpecification.h>
#import <AKACommons/AKATVCoordinateMappingProtocol.h>

// Categories/
#import <AKACommons/NSObject+AKASelectorTools.h>
#import <AKACommons/NSObject+AKAConcurrencyTools.h>
#import <AKACommons/NSObject+AKAAssociatedValues.h>
#import <AKACommons/NSString+AKATools.h>
#import <AKACommons/NSString+AKAKeyPathUtilities.h>
#import <AKACommons/NSMutableString+AKATools.h>
#import <AKACommons/NSIndexPath+AKARowAndSectionAsInteger.h>
#import <AKACommons/UIView+AKAHierarchyVisitor.h>
#import <AKACommons/UIView+AKAReusableViewsSupport.h>
#import <AKACommons/UIView+AKAConstraintTools.h>

// Networking/
#import <AKACommons/AKANetworkingErrors.h>
#import <AKACommons/AKAIPAddress.h>
#import <AKACommons/AKAIPNetmask.h>
#import <AKACommons/AKAInterfaceInfo.h>
#import <AKACommons/AKAInterfaceInfo+Deprecated.h>

// Collections/
#import <AKACommons/AKAMutableOrderedDictionary.h>
#import <AKACommons/AKAArrayComparer.h>

// KVO/
#import <AKACommons/AKAKVOChangeEvent.h>
#import <AKACommons/AKAKVOPublisher.h>
#import <AKACommons/AKAKVOSubscription.h>

// DataStructures
#import <AKACommons/AKAObservableCollection.h>
