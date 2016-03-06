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
#import "SearchResultsViewController.h"
#import "Tweet.h"
#import "TweetCell.h"

@interface SearchResultsViewController()
@property (nonatomic, strong) NSArray<Tweet *> *tweets;
@end


@implementation SearchResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.searchQuery;
    
    self.tableView.allowsSelection = NO;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100.0f;
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass(TweetCell.class) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"Tweet Cell"];
    
    [self loadResults];
}

- (void)loadResults {
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (!granted) {
            // TODO: Handle failure to get account access
            return;
        }
        
        NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
        if (arrayOfAccounts.count == 0) {
            // TODO: Handle not having a Twitter account
            return;
        }
        
        NSString *searchQueryEncoded = [self.searchQuery stringByAddingPercentEscapesUsingEncoding:
                                        NSUTF8StringEncoding];
        NSString *requestURLString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/search/tweets.json?q=%@", searchQueryEncoded];
        NSURL *requestURL = [NSURL URLWithString:requestURLString];
        NSDictionary *parameters = @{};
        SLRequest *postRequest = [SLRequest
                                  requestForServiceType:SLServiceTypeTwitter
                                  requestMethod:SLRequestMethodGET
                                  URL:requestURL parameters:parameters];
        ACAccount *twitterAccount = [arrayOfAccounts lastObject];
        postRequest.account = twitterAccount;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD show];
        });
        
        [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
            
            NSArray *statusesArray = [NSJSONSerialization
                                      JSONObjectWithData:responseData
                                      options:NSJSONReadingMutableLeaves
                                      error:&error][@"statuses"];
            if (error) {
                NSLog(@"Error reading response from Twitter. %@", error.localizedDescription);
                return;
            }
            
            self.tweets = [MTLJSONAdapter modelsOfClass:Tweet.class fromJSONArray:statusesArray error:&error];
            if (error) {
                NSLog(@"Error parsing Tweet object. %@", error.localizedDescription);
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
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
