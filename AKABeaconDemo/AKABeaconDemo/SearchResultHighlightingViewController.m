//
//  SearchResultHighlightingViewController.m
//  AKABeaconDemo
//
//  Created by Michael Utech on 23.12.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "SearchResultHighlightingViewController.h"
@import AKABeacon;

@interface SearchResultHighlightingViewController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation SearchResultHighlightingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [AKABindingBehavior addToViewController:self];

    self.textValue = @"Demo text";
    self.searchPattern = @"Demo";
    self.searchBar.text = self.searchPattern;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchPattern = searchText;
}

@end
