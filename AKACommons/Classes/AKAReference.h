//
//  AKAReference.h
//  AKACommons
//
//  Created by Michael Utech on 11.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKAStrongReference;
@class AKAWeakReference;

@interface AKAReference : NSObject

+ (AKAStrongReference*)strongReferenceTo:(id)value;
+ (AKAWeakReference*)weakReferenceTo:(id)value;

@property(nonatomic, readonly) id value;

@end

@interface AKAWeakReference: AKAReference

@property(nonatomic, weak, readonly) id value;

@end

@interface AKAStrongReference: AKAReference

@property(nonatomic, strong, readonly) id value;

@end