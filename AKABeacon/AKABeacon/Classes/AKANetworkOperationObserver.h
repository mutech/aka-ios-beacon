//
//  AKANetworkOperationObserver.h
//  AKABeacon
//
//  Created by Michael Utech on 24/09/2016.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAOperationObserver.h"

/**
 Interface for updating network activity indicators.
 
 The primary use case is to provide alternative network indicators to AKANetworkOperationObserver or to make it cooperate with third party frameworks providing alternative mechanisms to update the status bar network activity indicator.
 
 @see AKANetworkOperationObserver
 */
@protocol AKANetworkActivityIndicatorProtocol

/**
 Time interval in seconds until after the activity indicator should be hidden after the network activity finished. This is used to prevent the indicator from flickering when short running tasks turn it on and off very quickly.
 
 Return NAN to disable delayed hiding. This is required if hideNetworkActivityIndicator implements delayed hiding itself.

 @return the delay after which the indicator is turned off.
 */
@property(nonatomic, readonly) NSTimeInterval hidingDelay;

/**
 The tolerance value for hidingDelay. See NSTimer for details.

 Return NAN to use the default tolerance of NSTimer.

 @return The tolerance value for hidingDelay
 */
@property(nonatomic, readonly) NSTimeInterval hidingDelayTolerance;

/**
 Shows the network activity indicator.
 */
- (void)showNetworkActivityIndicator;

/**
 Hides the network activity indicator. Please note that the implementation of this method is expected to immediately switch of the indicator and not honor hidingDelay.
 
 Alternatively, the method can implement its own delay but then hidingDelay is expected to return NAN.
 */
- (void)hideNetworkActivityIndicator;

@end

/**
 Observer that will ensure that the iOS network activity indicator is shown while any observed operations are running.
 
 Actions which are not implemented as AKAOperation's can use startUsingNetwork and stopUsingNetwork or showNetworkActivityIndicatorWhilePerformingBlock: to update the network activity indicator cooperatively with this mechanism.
 */
@interface AKANetworkOperationObserver : NSObject<AKAOperationObserver>

#pragma mark - Initialization

+ (nonnull instancetype)sharedInstance;

#pragma mark - Configuration

/**
 Replaces the method of updating the network activity indicator. You can use this to disable updates of the iOS network activity indicator (setting it to nil) or to use another mechanism in order to cooperate with other frameworks you might be using or to use a different indicator view.
 
 You should not change the indicator while the current indicator is shown, because that would simply leave it in whichever state it was. The preferred way to change this is at application start.

 @param indicator an alternative network activity indicator to be used instead of the default iOS indicator, or nil to disable the default indicator.
 */
+ (void)setNetworkActivityIndicator:(nullable id<AKANetworkActivityIndicatorProtocol>)indicator;

/**
 @return the default implementation of AKANetworkActivityIndicatorProtocol which will operate on the network activity indicator in the iOS status bar.
 */
+ (nonnull id<AKANetworkActivityIndicatorProtocol>)defaultNetworkActivityIndicator;

#pragma mark - Setup operations to update the indicator state

/**
 Adds the sharedInstance as observer of the specified operation to ensure that the network activity indicator is shown while the operation is running.

 @param operation the operation to observe.
 */
+ (void)showNetworkActivityIndicatorWhileOperationIsRunning:(nonnull AKAOperation*)operation;

#pragma mark - Direct indicator state updates

/**
 Ensure that the network activity indicator is shown while performing the specified block.

 @param block the block using the network
 */
+ (void)showNetworkActivityIndicatorWhilePerformingBlock:(void(^_Nonnull)())block;

/**
 Shows the network activity indicator and prevents other operations to hide it unless stopUserNetwork is called.
 */
+ (void)startUsingNetwork;

/**
 Hides the network activity indicator unless other operations are still using the network.
 */
+ (void)stopUsingNetwork;

@end
