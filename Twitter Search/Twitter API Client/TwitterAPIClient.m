//
//  TwitterAPIClient.m
//  Twitter Search
//
//  Created by Mario Cecchi on 3/9/16.
//  Copyright © 2016 Mario Cecchi. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "Tweet.h"
#import "TwitterAPIClient.h"

@implementation TwitterAPIClient

static NSString *const APIBaseURL = @"https://api.twitter.com/1.1";
static ACAccount *twitterAccount;

+ (void)requestAccessToTwitterAccounts:(void(^)(NSError *error))completionHandler {
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        NSError *returnError;
        if (!granted) {
            returnError = [NSError errorWithDomain:@"TwitterAPIErrorDomain" code:TwitterAPIErrorAccessDenied userInfo:@{}];
            completionHandler(error);
            return;
        }
        
        NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
        if (arrayOfAccounts.count == 0) {
            returnError = [NSError errorWithDomain:@"TwitterAPIErrorDomain" code:TwitterAPIErrorNoAccounts userInfo:@{}];
            completionHandler(error);
            return;
        }
        
        twitterAccount = arrayOfAccounts.lastObject;
        completionHandler(nil);
    }];
}

+ (void)searchWithQuery:(NSString *)query maxID:(long long)maxID limit:(int)limit completionHandler:(void(^)(NSArray<Tweet *> *tweets, NSError *error))completionHandler {
    NSString *searchQueryEncoded = [query stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSString *requestURLString = [NSString stringWithFormat:@"%@/search/tweets.json?count=%d&q=%@", APIBaseURL, limit, searchQueryEncoded];
    if (maxID > 1) {
        requestURLString = [requestURLString stringByAppendingString:[NSString stringWithFormat:@"&max_id=%lld", maxID]];
    }
    
    NSURL *requestURL = [NSURL URLWithString:requestURLString];
    SLRequest *postRequest = [SLRequest
                              requestForServiceType:SLServiceTypeTwitter
                              requestMethod:SLRequestMethodGET
                              URL:requestURL parameters:nil];
    postRequest.account = twitterAccount;
    
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            completionHandler(nil, error);
            return;
        }
        
        NSError *jsonError;
        NSArray *statusesArray = [NSJSONSerialization
                                  JSONObjectWithData:responseData
                                  options:NSJSONReadingMutableLeaves
                                  error:&jsonError][@"statuses"];
        if (jsonError) {
            NSLog(@"Error reading response from Twitter. %@", jsonError.localizedDescription);
            completionHandler(nil, jsonError);
            return;
        }
        
        NSError *modelParsingError;
        NSArray<Tweet *> *tweets = [MTLJSONAdapter modelsOfClass:Tweet.class fromJSONArray:statusesArray error:&modelParsingError];
        
        completionHandler(tweets, modelParsingError);
    }];
}

@end
