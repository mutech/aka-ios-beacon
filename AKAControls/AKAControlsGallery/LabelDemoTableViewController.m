//
//  LabelDemoTableViewController.m
//  AKAControlsGallery
//
//  Created by Michael Utech on 03.11.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "LabelDemoTableViewController.h"

@interface CustomFormatter : NSFormatter

@property(nonatomic) NSString* format;

@end

@implementation CustomFormatter

- (instancetype)init
{
    if (self = [super init])
    {
        self.format = @"%@";
    }
    return self;
}

- (NSString *)stringForObjectValue:(id)obj
{
    NSString* text = [NSString stringWithFormat:@"%@ %@", obj[@"givenName"], obj[@"familyName"]];
    return [NSString stringWithFormat:self.format, text];
}

@end


@interface LabelDemoTableViewController ()

@end


@implementation LabelDemoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textValue = @"Michael";
    self.floatValue = 12345.678;
    self.dateValue = [NSDate new];
    self.boolValue = YES;
    self.objectValue = @{ @"givenName": @"Michael", @"familyName": @"Utech" };
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

@end
