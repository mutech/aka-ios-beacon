//
//  AKABooleanTextConverter.h
//  AKABeacon
//
//  Created by Michael Utech on 09.09.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAControlConverterProtocol.h"

@interface AKABooleanTextConverter : NSObject<AKAControlConverterProtocol>

#pragma mark - Initialization

- (instancetype)initWithTextForYes:(NSString*)textForYes
                         textForNo:(NSString*)textForNo
                  textForUndefined:(NSString*)textForUndefined;

- (instancetype)initWithBaseConverter:(id<AKAControlConverterProtocol>)baseConverter
                           textForYes:(NSString*)textForYes
                            textForNo:(NSString*)textForNo
                     textForUndefined:(NSString*)textForUndefined;

#pragma mark - Configuration

@property(nonatomic, readonly) id<AKAControlConverterProtocol> baseConverter;
@property(nonatomic, readonly) NSString* textForYes;
@property(nonatomic, readonly) NSString* textForNo;
@property(nonatomic, readonly) NSString* textForUndefined;

@end
