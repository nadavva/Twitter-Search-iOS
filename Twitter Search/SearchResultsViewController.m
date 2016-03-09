    //
//  SearchResultsViewController.m
//  Twitter Search
//
//  Created by Mario Cecchi on 06/03/2016.
//  Copyright © 2016 Mario Cecchi. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIAlertController+okAlert.h"
#import <UIScrollView+InfiniteScroll.h>
#import "SearchResultsViewController.h"
#import "Tweet.h"
#import "TweetCell.h"

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
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (!granted) {
            UIAlertController *alert = [UIAlertController okAlertWithTitle:NSLocalizedString(@"Unable to access Twitter", @"") message:NSLocalizedString(@"You have not authorised Twitter Search to access your Twitter account, which is needed for loading the Tweets. Authorise this app in Settings > Twitter and try again.", @"")];
            [self presentViewController:alert animated:YES completion:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
            return;
        }
        
        NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
        if (arrayOfAccounts.count == 0) {
            UIAlertController *alert = [UIAlertController okAlertWithTitle:NSLocalizedString(@"No Twitter accounts configured", @"") message:NSLocalizedString(@"It looks like you haven't configured any Twitter accounts on your device. Configure an account in Settings > Twitter and try again.", @"")];
            [self presentViewController:alert animated:YES completion:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
            return;
        }
        
        NSString *searchQueryEncoded = [self.searchQuery stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        NSString *requestURLString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/search/tweets.json?count=%d&q=%@", NumberOfTweetsToLoad, searchQueryEncoded];
        if (self.tweets.count > 0) {
            Tweet *oldestLoadedTweet = self.tweets.lastObject;
            long long oldestTweetID = oldestLoadedTweet.statusID - 1; // to skip last tweet
            requestURLString = [requestURLString stringByAppendingString:[NSString stringWithFormat:@"&max_id=%lld", oldestTweetID]];
        }
        
        NSURL *requestURL = [NSURL URLWithString:requestURLString];
        SLRequest *postRequest = [SLRequest
                                  requestForServiceType:SLServiceTypeTwitter
                                  requestMethod:SLRequestMethodGET
                                  URL:requestURL parameters:nil];
        ACAccount *twitterAccount = [arrayOfAccounts lastObject];
        postRequest.account = twitterAccount;

        [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
            
            NSArray *statusesArray = [NSJSONSerialization
                                      JSONObjectWithData:responseData
                                      options:NSJSONReadingMutableLeaves
                                      error:&error][@"statuses"];
            if (error) {
                NSLog(@"Error reading response from Twitter. %@", error.localizedDescription);
                return;
            }
            
            NSArray<Tweet *> *newTweets = [MTLJSONAdapter modelsOfClass:Tweet.class fromJSONArray:statusesArray error:&error];
            if (error) {
                NSLog(@"Error parsing Tweet object. %@", error.localizedDescription);
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
