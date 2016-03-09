//
//  SearchResultsViewController.m
//  Twitter Search
//
//  Created by Mario Cecchi on 06/03/2016.
//  Copyright © 2016 Mario Cecchi. All rights reserved.
//

#import "UIAlertController+okAlert.h"
#import <UIScrollView+InfiniteScroll.h>
#import "SearchResultsViewController.h"
#import "Tweet.h"
#import "TweetCell.h"
#import "TwitterAPIClient.h"

@interface SearchResultsViewController()
@property (nonatomic, strong) NSArray<Tweet *> *tweets;
@end

static const int NumberOfTweetsToLoad = 25;

@implementation SearchResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.searchQuery;
    
    self.tableView.allowsSelection = NO;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100.0f;
    
    // Setup infinite scroll
    __weak id weakSelf = self;
    [self.tableView addInfiniteScrollWithHandler:^(UITableView* tableView) {
        [weakSelf loadMoreResults];
    }];
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass(TweetCell.class) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"Tweet Cell"];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refreshTable:)
                  forControlEvents:UIControlEventValueChanged];
    
    // Set initial loading indicator
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y-self.refreshControl.frame.size.height) animated:NO];
    
    [self loadResults];
}

- (void)refreshTable:(id)sender {
    if (self.refreshControl.refreshing) {
        [self loadResults];
    }
}

- (void)loadResults {
    self.tweets = @[];
    [self loadMoreResults];
}

- (void)loadMoreResults {
    [TwitterAPIClient requestAccessToTwitterAccounts:^(NSError *error) {
        if (error) {
            NSString *alertTitle, *alertMessage;
            if (error.code == TwitterAPIErrorAccessDenied) {
                alertTitle = NSLocalizedString(@"TWITTER_DENIED_ALERT_TITLE", @"");
                alertMessage = NSLocalizedString(@"TWITTER_DENIED_ALERT_MESSAGE", @"");
            } else if (error.code == TwitterAPIErrorNoAccounts) {
                alertTitle = NSLocalizedString(@"TWITTER_NO_ACCOUNTS_ALERT_TITLE", @"");
                alertMessage = NSLocalizedString(@"TWITTER_NO_ACCOUNTS_ALERT_MESSAGE", @"");
            }
            
            UIAlertController *alert = [UIAlertController okAlertWithTitle:alertTitle message:alertMessage];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alert animated:YES completion:nil];
                [self.refreshControl endRefreshing];
                [self.tableView reloadData];
            });
            
            return;
        }
        
        long long oldestLoadedTweetID = 0;
        if (self.tweets.count > 0) {
            Tweet *oldestLoadedTweet = self.tweets.lastObject;
            oldestLoadedTweetID = oldestLoadedTweet.statusID - 1; // to skip last tweet
        }
        
        [TwitterAPIClient searchWithQuery:self.searchQuery maxID:oldestLoadedTweetID limit:NumberOfTweetsToLoad completionHandler:^(NSArray<Tweet *> *newTweets, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
            
            if (error || !newTweets) {
                UIAlertController *alert = [UIAlertController okAlertWithTitle:NSLocalizedString(@"LOADING_FAILED_ALERT_TITLE", @"") message:NSLocalizedString(@"LOADING_FAILED_ALERT_MESSAGE", @"")];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:alert animated:YES completion:nil];
                });
                
                return;
            }
            
            NSMutableArray *tweets = self.tweets.mutableCopy;
            [tweets addObjectsFromArray:newTweets];
            self.tweets = tweets;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.tableView finishInfiniteScroll];
            });
        }];
    }];
}


#pragma mark - Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Tweet Cell" forIndexPath:indexPath];
    
    Tweet *tweet = self.tweets[indexPath.row];
    [cell configureCellWithTweet:tweet];
    
    return cell;
}


@end
