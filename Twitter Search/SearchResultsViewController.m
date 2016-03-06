//
//  SearchResultsViewController.m
//  Twitter Search
//
//  Created by Mario Cecchi on 06/03/2016.
//  Copyright © 2016 Mario Cecchi. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "Tweet.h"

@interface SearchResultsViewController()
@property (nonatomic, strong) NSArray<Tweet *> *results;
@end


@implementation SearchResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.searchQuery;
    
    [self loadResults];
}

- (void)loadResults {
    
}

#pragma mark - Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Search Cell" forIndexPath:indexPath];
    
    Tweet *tweet = self.results[indexPath.row];
    cell.textLabel.text = tweet.text;
    
    return cell;
}


@end
