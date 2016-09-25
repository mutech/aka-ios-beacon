//
//  AlertOperationDemosTableViewController.m
//  AKABeaconDemo
//
//  Created by Michael Utech on 02.09.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//


#import "AlertOperationDemosTableViewController.h"
@import MessageUI;
@import AKABeacon;

@interface AlertOperationDemosTableViewController ()

@property(nonatomic, readonly) AKAOperationQueue* operationQueue;

@end

@implementation AlertOperationDemosTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _operationQueue = [AKAOperationQueue new];
    _operationQueue.maxConcurrentOperationCount = 5;
}

#pragma mark - Table view data source

- (IBAction)startAlertOperation:(id)sender
{
    [AKAAlertOperation presentAlertWithTitle:@"Presented by AKAAlertOperation"
                                     message:@"a delightful alert for you"
                              preferredStyle:UIAlertControllerStyleAlert
                                     actions:@[ [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil] ]
                         presentationContext:nil];
}

- (IBAction)startMultipleAlertOperations:(id)sender
{
    // Creates three alerts, which will be presented sequentially because of mutual exclusivity conditions
    // implemented by AKAAlertOperation:
    
    NSArray<AKAAlertOperation*>*operations =
    @[
      [AKAAlertOperation operationForAlertWithTitle:@"Alert #1"
                                            message:@"a delightful alert for you, two more alerts will follow"
                                     preferredStyle:UIAlertControllerStyleAlert
                                            actions:@[ [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil] ]
                                presentationContext:self],
      [AKAAlertOperation operationForAlertWithTitle:@"Alert #2"
                                            message:@"Here is the second alert"
                                     preferredStyle:UIAlertControllerStyleAlert
                                            actions:@[ [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil] ]
                                presentationContext:self],
      [AKAAlertOperation operationForAlertWithTitle:@"Alert #1"
                                            message:@"and finally the last alert"
                                     preferredStyle:UIAlertControllerStyleAlert
                                            actions:@[ [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil] ]
                                presentationContext:self]
      ];

    [self.operationQueue addOperations:operations waitUntilFinished:NO];
}

- (IBAction)sendMail:(id)sender
{
    MFMailComposeViewController* controller = [MFMailComposeViewController new];
    AKASendMailOperation* operation = [AKASendMailOperation operationForController:controller presentationContext:self];
    
#if TARGET_OS_SIMULATOR
    AKAAlertOperation* alertOperation =
        [AKAAlertOperation operationForAlertWithTitle:@"Not supported in Simulator"
                                              message:@"MFMailComposeViewController does not work in the iOS simulator.\n\nThe expected (not desired) behavior is that you will get a macOS alert saying that MailCompositionService quit unexpectedly and the composer view controller will cancel the session, which in turn completes the execution of the send mail operation.\n\nWe will remove this notice if Apple ever cares to fix this bug."
                                       preferredStyle:UIAlertControllerStyleAlert
                                              actions:@[ [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil] ]
                                  presentationContext:self];
    [alertOperation addDependency:operation];
    [alertOperation addToOperationQueue:self.operationQueue];
#endif

    [operation addToOperationQueue:self.operationQueue];
}

@end
