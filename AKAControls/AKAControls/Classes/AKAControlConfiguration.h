//
//  AKAControlConfiguration.h
//  AKAControls
//
//  Created by Michael Utech on 16.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import Foundation;

#ifndef AKAControlConfiguration_h
#define AKAControlConfiguration_h

#define kAKAControlTypeKey @"controlType"
#define kAKAControlNameKey @"controlName"
#define kAKAControlTagsKey @"controlTags"
#define kAKAControlRoleKey @"controlRole"
#define kAKAControlViewBinding @"controlViewBinding"

typedef NSDictionary<NSString*, id>           AKAControlConfiguration;
typedef AKAControlConfiguration*_Nullable               opt_AKAControlConfiguration;
typedef AKAControlConfiguration*_Nonnull                req_AKAControlConfiguration;

typedef NSMutableDictionary<NSString*, id>    AKAMutableControlConfiguration;
typedef AKAMutableControlConfiguration*_Nullable        opt_AKAMutableControlConfiguration;
typedef AKAMutableControlConfiguration*_Nonnull         req_AKAMutableControlConfiguration;

#endif /* AKAControlConfiguration_h */
