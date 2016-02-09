//
//  AKANullability.h
//  AKACommons
//
//  Created by Michael Utech on 20.09.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;
@import UIKit;

#ifndef AKANullability_h
#define AKANullability_h

/* Rationale:
 
 We decided to (progressively) use nullability annotations in all interfaces, for the sake of Swift and also for the greater good.
 
 That however rendered the source completely unreadable (Objective-C is already noisy, but with type declarations like `NSError* _Nullable __autoreleasing*_Nullable` it's just going too far.
 
 So we decided to create type aliases using prefixes like 'opt_' (-ional), 'req_' (-uired), 'out_' (optional output parameter), 'reqout_' (required output parameter) and 'inout_' (optional input/output parameter). Out- and inout types are pointers to the respective type.
 
 We initially used typedefs, but since these are visible in Swift (where it just creates confusion but doesn't help readability) we decided to use macros instead.
 
 The #ifdef's should not be necessary if you create typedefs for prefixed type names such as opt_AKAProperty. We use them here, because it seems possible that something like out_NSError might be defined by another party. In this case we expect that it will be easier to detect such a conflict if we use their definition and get errors on our side of the table, since we are obviously not following naming conventions with this approach (the other party might be Apple).

 We hate this approach, we just hate unreadable source code a bit more. If your point of view differs, we apologize (sincerely).
 */


#ifndef req_instancetype
// "nonnull instancetype" is not supported by AppCode (yet)
#define req_instancetype            instancetype _Nonnull
#endif
#ifndef opt_instancetype
// "nullable instancetype" is not supported by AppCode (yet)
#define opt_instancetype            instancetype _Nullable
#endif

#ifndef opt_id
#define opt_id                      id _Nullable
#endif
#ifndef req_id
#define req_id                      id _Nonnull
#endif
#ifndef out_id
#define out_id                      id __autoreleasing _Nullable * _Nullable
#endif
#ifndef inout_id
#define inout_id                    out_id
#endif

#ifndef opt_id_NSCopying
#define opt_id_NSCopying            id<NSCopying> _Nullable
#endif
#ifndef req_id_NSCopying
#define req_id_NSCopying            id<NSCopying> _Nonnull
#endif


#ifndef opt_NSObject
#define opt_NSObject                NSObject* _Nullable
#endif
#ifndef req_NSObject
#define req_NSObject                NSObject* _Nonnull
#endif

#ifndef opt_Class
#define opt_Class                   Class _Nullable
#endif
#ifndef req_Class
#define req_Class                   Class _Nonnull
#endif
#ifndef out_Class
#define out_Class                   Class _Nullable* _Nullable
#endif

#ifndef outreq_BOOL
#define outreq_BOOL                 BOOL* _Nonnull
#endif

#ifndef opt_NSError
#define opt_NSError                 NSError* _Nullable
#endif
#ifndef out_NSError
#define out_NSError                 NSError* _Nullable __autoreleasing*_Nullable
#endif
#ifndef req_NSError
#define req_NSError                 NSError* _Nonnull
#endif
#ifndef inout_NSError
#define inout_NSError               out_NSError
#endif

#ifndef opt_NSString
#define opt_NSString                NSString* _Nullable
#endif
#ifndef req_NSString
#define req_NSString                NSString* _Nonnull
#endif
#ifndef out_NSString
#define out_NSString                NSString* _Nullable __autoreleasing*_Nullable
#endif

#ifndef out_unichar
#define out_unichar                 unichar* _Nullable
#endif

#ifndef opt_NSNumber
#define opt_NSNumber                NSNumber* _Nullable
#endif
#ifndef req_NSNumber
#define req_NSNumber                NSNumber* _Nonnull
#endif
#ifndef out_NSNumber
#define out_NSNumber                NSNumber* _Nullable __autoreleasing*_Nullable
#endif

#ifndef opt_NSDate
#define opt_NSDate                  NSDate* _Nullable
#endif
#ifndef req_NSDate
#define req_NSDate                  NSDate* _Nonnull
#endif

#ifndef opt_NSArray
#define opt_NSArray                 NSArray* _Nullable
#endif
#ifndef req_NSArray
#define req_NSArray                 NSArray* _Nonnull
#endif

#ifndef opt_NSSet
#define opt_NSSet                   NSSet* _Nullable
#endif
#ifndef req_NSSet
#define req_NSSet                   NSSet* _Nonnull
#endif

#ifndef opt_NSDictionary
#define opt_NSDictionary            NSDictionary* _Nullable
#endif
#ifndef req_NSDictionary
#define req_NSDictionary            NSDictionary* _Nonnull
#endif
#ifndef out_NSDictionary
#define out_NSDictionary            NSDictionary* _Nullable __autoreleasing* _Nullable
#endif
#ifndef opt_NSMutableDictionary
#define opt_NSMutableDictionary     NSMutableDictionary* _Nullable
#endif
#ifndef req_NSMutableDictionary
#define req_NSMutableDictionary     NSMutableDictionary* _Nonnull
#endif

#ifndef opt_NSFormatter
#define opt_NSFormatter             NSFormatter* _Nullable
#endif
#ifndef req_NSFormatter
#define req_NSFormatter             NSFormatter* _Nonnull
#endif
#ifndef opt_NSDateFormatter
#define opt_NSDateFormatter         NSDateFormatter* _Nullable
#endif
#ifndef req_NSDateFormatter
#define req_NSDateFormatter         NSDateFormatter* _Nonnull
#endif
#ifndef opt_NSNumberFormatter
#define opt_NSNumberFormatter       NSNumberFormatter* _Nullable
#endif
#ifndef req_NSNumberFormatter
#define req_NSNumberFormatter       NSNumberFormatter* _Nonnull
#endif

#ifndef opt_NSLocale
#define opt_NSLocale                NSLocale* _Nullable
#endif
#ifndef req_NSLocale
#define req_NSLocale                NSLocale* _Nonnull
#endif
#ifndef opt_NSCalendar
#define opt_NSCalendar              NSCalendar* _Nullable
#endif
#ifndef req_NSCalendar
#define req_NSCalendar              NSCalendar* _Nonnull
#endif
#ifndef opt_NSTimeZone
#define opt_NSTimeZone              NSTimeZone* _Nullable
#endif
#ifndef req_NSTimeZone
#define req_NSTimeZone              NSTimeZone* _Nonnull
#endif

#ifndef opt_NSIndexPath
#define opt_NSIndexPath             NSIndexPath* _Nullable
#endif
#ifndef req_NSIndexPath
#define req_NSIndexPath             NSIndexPath* _Nonnull
#endif

#ifndef opt_SEL
#define opt_SEL                     SEL _Nullable
#endif
#ifndef req_SEL
#define req_SEL                     SEL _Nonnull
#endif

#ifndef opt_UIResponder
#define opt_UIResponder             UIResponder* _Nullable
#endif
#ifndef req_UIResponder
#define req_UIResponder             UIResponder* _Nonnull
#endif

#ifndef opt_UIViewController
#define opt_UIViewController        UIViewController* _Nullable
#endif
#ifndef req_UIViewController
#define req_UIViewController        UIViewController* _Nonnull
#endif

#ifndef opt_UIView
#define opt_UIView                  UIView* _Nullable
#endif
#ifndef req_UIView
#define req_UIView                  UIView* _Nonnull
#endif
#ifndef opt_UILabel
#define opt_UILabel                 UILabel* _Nullable
#endif
#ifndef req_UILabel
#define req_UILabel                 UILabel* _Nonnull
#endif
#ifndef opt_UITextField
#define opt_UITextField             UITextField* _Nullable
#endif
#ifndef req_UITextField
#define req_UITextField             UITextField* _Nonnull
#endif
#ifndef opt_UITextView
#define opt_UITextView              UITextView* _Nullable
#endif
#ifndef req_UITextView
#define req_UITextView              UITextView* _Nonnull
#endif
#ifndef opt_UISwitch
#define opt_UISwitch                UISwitch* _Nullable
#endif
#ifndef req_UISwitch
#define req_UISwitch                UISwitch* _Nonnull
#endif
#ifndef opt_UITableView
#define opt_UITableView             UITableView* _Nullable
#endif
#ifndef req_UITableView
#define req_UITableView             UITableView* _Nonnull
#endif
#ifndef opt_UITableViewCell
#define opt_UITableViewCell         UITableViewCell* _Nullable
#endif
#ifndef req_UITableViewCell
#define req_UITableViewCell         UITableViewCell* _Nonnull
#endif
#ifndef opt_UITableViewDataSource
#define opt_UITableViewDataSource   id<UITableViewDataSource>_Nullable
#endif
#ifndef req_UITableViewDataSource
#define req_UITableViewDataSource   id<UITableViewDataSource>_Nonnull
#endif
#ifndef opt_UITableViewDelegate
#define opt_UITableViewDelegate     id<UITableViewDelegate>_Nullable
#endif
#ifndef req_UITableViewDelegate
#define req_UITableViewDelegate     id<UITableViewDelegate>_Nonnull
#endif

#endif /* AKANullability_h */
