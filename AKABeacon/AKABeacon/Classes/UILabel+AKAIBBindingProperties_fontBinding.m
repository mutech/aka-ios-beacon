//
//  UILabel+AKAIBBindingProperties_fontBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 21.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "UILabel+AKAIBBindingProperties_fontBinding.h"

#import "AKABinding+IBPropertySupport.h"
#import "AKAFontPropertyBinding.h"


@implementation UILabel (AKAIBBindingProperties_fontBinding)

- (NSString*)fontBinding_aka
{
    return [AKAFontPropertyBinding bindingExpressionTextForSelector:@selector(fontBinding_aka)
                                                             inView:self];
}

- (void)setFontBinding_aka:(NSString *)fontBinding_aka
{
    [AKAFontPropertyBinding setBindingExpressionText:fontBinding_aka
                                         forSelector:@selector(fontBinding_aka)
                                              inView:self];
}

@end
