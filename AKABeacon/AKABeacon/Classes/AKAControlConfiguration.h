//
//  AKAControlConfiguration.h
//  AKABeacon
//
//  Created by Michael Utech on 16.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import Foundation;

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedMacroInspection"

#ifndef AKAControlConfiguration_h
#define AKAControlConfiguration_h

#define kAKAControlTypeKey @"controlType"
#define kAKAControlNameKey @"controlName"
#define kAKAControlTagsKey @"controlTags"
#define kAKAControlRoleKey @"controlRole"
#define kAKAControlViewBinding @"controlViewBinding"

#define AKAControlConfiguration             NSDictionary<NSString*, id>
#define opt_AKAControlConfiguration         AKAControlConfiguration*_Nullable
#define req_AKAControlConfiguration         AKAControlConfiguration*_Nonnull

#define AKAMutableControlConfiguration      NSMutableDictionary<NSString*, id>
#define opt_AKAMutableControlConfiguration  AKAMutableControlConfiguration*_Nullable
#define req_AKAMutableControlConfiguration  AKAMutableControlConfiguration*_Nonnull

#endif /* AKAControlConfiguration_h */

#pragma clang diagnostic pop