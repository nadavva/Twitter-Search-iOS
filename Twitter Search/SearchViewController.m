//
//  SearchViewController.m
//  Twitter Search
//
//  Created by Mario Cecchi on 06/03/2016.
//  Copyright © 2016 Mario Cecchi. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResultsViewController.h"

@interface SearchViewController() <UISearchBarDelegate>
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSString *searchQuery;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SearchResults"]) {
        SearchResultsViewController *resultsVC = segue.destinationViewController;
        resultsVC.searchQuery = self.searchQuery;
    }
}

#pragma mark - UISearchBar methods

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if (searchBar.text.length > 0) {
        self.searchQuery = searchBar.text;
        [self performSegueWithIdentifier:@"SearchResults" sender:self];
    }
}

#pragma mark - Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Search Cell" forIndexPath:indexPath];
    return cell;
}

@end
