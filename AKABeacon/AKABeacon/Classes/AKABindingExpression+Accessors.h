//
//  AKABindingExpression+Accessors.h
//  AKABeacon
//
//  Created by Michael Utech on 22.03.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingExpression.h"

@interface AKABindingExpression(Accessors)

+ (opt_AKABindingExpression)bindingExpressionForTarget:(id<NSObject>_Nonnull)target
                                              property:(req_SEL)selector;
+ (void)                          setBindingExpression:(opt_AKABindingExpression)bindingExpression
                                             forTarget:(id<NSObject>_Nonnull)target
                                              property:(req_SEL)selector;
+ (void)          enumerateBindingExpressionsForTarget:(id<NSObject>_Nonnull)target
                                             withBlock:(void (^_Nonnull)(SEL _Nonnull property,
                                                                         req_AKABindingExpression ex,
                                                                         outreq_BOOL stop))block;
@end

