//
//  SearchViewController.m
//  Twitter Search
//
//  Created by Mario Cecchi on 06/03/2016.
//  Copyright © 2016 Mario Cecchi. All rights reserved.
//

#import "AppDelegate.h"
#import "Search.h"
#import "SearchViewController.h"
#import "SearchResultsViewController.h"

@interface SearchViewController() <UISearchBarDelegate>
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSString *searchQuery;
@property (nonatomic, strong) NSArray<Search *> *previousSearches;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;

    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    [self loadPreviousSearches];
}

- (void)loadPreviousSearches {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(Search.class) inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    self.previousSearches = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error loading previous searches. %@", error.localizedDescription);
    }

    [self.tableView reloadData];
}

- (void)saveSearchIfNecessary {
    Search *search = [Search searchWithUniqueQuery:self.searchQuery inManagedObjectContext:self.managedObjectContext];
    search.date = [NSDate date];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error saving search. %@", error.localizedDescription);
    }
    
    [self loadPreviousSearches];
}

- (void)searchForQuery:(NSString *)query {
    self.searchQuery = query;
    [self saveSearchIfNecessary];
    [self performSegueWithIdentifier:@"SearchResults" sender:self];
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
        [self searchForQuery:searchBar.text];
    }
}


#pragma mark - Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.previousSearches.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Search Cell" forIndexPath:indexPath];
    
    Search *search = self.previousSearches[indexPath.row];
    cell.textLabel.text = search.query;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Search *search = self.previousSearches[indexPath.row];
    [self searchForQuery:search.query];
}

@end
