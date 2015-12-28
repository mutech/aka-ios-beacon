//
//  SearchResultHighlightingViewController.m
//  AKABeaconDemo
//
//  Created by Michael Utech on 23.12.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "SearchResultHighlightingViewController.h"

@interface SearchResultHighlightingViewController () <UISearchBarDelegate>

@property(nonatomic) NSString* searchPattern;
@property(nonatomic) NSString* textValue;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation SearchResultHighlightingViewController

- (void)viewDidLoad
{
    self.textValue = @"Demo text";
    self.searchPattern = @"Demo";
    self.searchBar.text = self.searchPattern;

    [super viewDidLoad];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchPattern = searchText;
}

@end
