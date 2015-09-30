//
//  AKAReference.h
//  AKACommons
//
//  Created by Michael Utech on 11.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKAWeakReference<__covariant ObjectType>;
@class AKAStrongReference<__covariant ObjectType>;

@interface AKAReference<__covariant ObjectType> : NSObject

+ (AKAStrongReference<ObjectType>*)strongReferenceTo:(id)value;
+ (AKAWeakReference<ObjectType>*)weakReferenceTo:(id)value;

@property(nonatomic, readonly) ObjectType value;

@end

@interface AKAWeakReference<__covariant ObjectType>: AKAReference

@property(nonatomic, weak, readonly) ObjectType value;

@end

@interface AKAStrongReference<__covariant ObjectType>: AKAReference

@property(nonatomic, strong, readonly) ObjectType value;

@end

@interface AKAWeakReferenceProxy<__covariant ObjectType>: NSProxy

+ (id)weakReferenceProxyFor:(id)value;

+ (id)weakReferenceProxyFor:(id)value
               deallocation:(void(^)())deallocationBlock;

@end