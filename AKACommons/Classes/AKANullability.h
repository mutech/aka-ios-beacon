//
//  AKANullability.h
//  AKACommons
//
//  Created by Michael Utech on 20.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
@import UIKit;

#ifndef AKANullability_h
#define AKANullability_h

// Rationale:
//
// Adding nullability annotations (both to support Swift and also for the greater good)
// makes interfaces very unreadable, so unreadable that I am even willing to create
// typedefs for about every frequently used type.
//
// The advantage for readability should become clear if you compare the typedefs to their
// definitions.
//
// So far, I used the prefix "opt_" for nullable types and "req_" non-nullables. A special
// case is "out_" which is primarily used for NSError, where both the error itself and its
// storage location are nullable.

typedef id _Nullable                                    opt_id;
typedef id _Nonnull                                     req_id;
typedef id __autoreleasing _Nullable * _Nullable         out_id;
typedef out_id                                          inout_id;

typedef id<NSCopying> _Nullable                         opt_id_NSCopying;
typedef id<NSCopying> _Nonnull                          req_id_NSCopying;


typedef NSObject* _Nullable                             opt_NSObject;
typedef NSObject* _Nonnull                              req_NSObject;

typedef Class _Nullable                                 opt_Class;
typedef Class _Nonnull                                  req_Class;
typedef Class _Nullable* _Nullable                      out_Class;

typedef BOOL* _Nonnull                                  outreq_BOOL;

typedef NSError* _Nullable                              opt_NSError;
typedef NSError* _Nullable __autoreleasing*_Nullable    out_NSError;
typedef out_NSError                                     inout_NSError;

typedef NSString* _Nullable                             opt_NSString;
typedef NSString* _Nonnull                              req_NSString;
typedef NSString* _Nullable __autoreleasing*_Nullable   out_NSString;

typedef unichar* _Nullable                              out_unichar;

typedef NSNumber* _Nullable                             opt_NSNumber;
typedef NSNumber* _Nonnull                              req_NSNumber;
typedef NSNumber* _Nullable __autoreleasing*_Nullable   out_NSNumber;

typedef NSDate* _Nullable                               opt_NSDate;
typedef NSDate* _Nonnull                                req_NSDate;

typedef NSArray* _Nullable                              opt_NSArray;
typedef NSArray* _Nonnull                               req_NSArray;

typedef NSSet* _Nullable                                opt_NSSet;
typedef NSSet* _Nonnull                                 req_NSSet;

typedef NSDictionary* _Nullable                         opt_NSDictionary;
typedef NSDictionary* _Nonnull                          req_NSDictionary;
typedef NSDictionary* _Nullable __autoreleasing* _Nullable out_NSDictionary;
typedef NSMutableDictionary* _Nullable                  opt_NSMutableDictionary;
typedef NSMutableDictionary* _Nonnull                   req_NSMutableDictionary;

typedef NSIndexPath* _Nullable                          opt_NSIndexPath;
typedef NSIndexPath* _Nonnull                           req_NSIndexPath;

typedef SEL _Nullable                                   opt_SEL;
typedef SEL _Nonnull                                    req_SEL;

typedef UIResponder* _Nullable                          opt_UIResponder;
typedef UIResponder* _Nonnull                           req_UIResponder;

typedef UIView* _Nullable                               opt_UIView;
typedef UIView* _Nonnull                                req_UIView;
typedef UILabel* _Nullable                              opt_UILabel;
typedef UILabel* _Nonnull                               req_UILabel;
typedef UITextField* _Nullable                          opt_UITextField;
typedef UITextField* _Nonnull                           req_UITextField;
typedef UITextView* _Nullable                           opt_UITextView;
typedef UITextView* _Nonnull                            req_UITextView;
typedef UISwitch* _Nullable                             opt_UISwitch;
typedef UISwitch* _Nonnull                              req_UISwitch;
typedef UITableView* _Nullable                          opt_UITableView;
typedef UITableView* _Nonnull                           req_UITableView;
typedef UITableViewCell* _Nullable                      opt_UITableViewCell;
typedef UITableViewCell* _Nonnull                       req_UITableViewCell;
typedef id<UITableViewDataSource>_Nullable              opt_UITableViewDataSource;
typedef id<UITableViewDataSource>_Nonnull               req_UITableViewDataSource;
typedef id<UITableViewDelegate>_Nullable                opt_UITableViewDelegate;
typedef id<UITableViewDelegate>_Nonnull                 req_UITableViewDelegate;

#endif /* AKANullability_h */
