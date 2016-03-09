//
//  TwitterAPIClient.h
//  Twitter Search
//
//  Created by Mario Cecchi on 3/9/16.
//  Copyright © 2016 Mario Cecchi. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSInteger TwitterAPIErrorAccessDenied = 1;
static const NSInteger TwitterAPIErrorNoAccounts = 2;

@interface TwitterAPIClient : NSObject

+ (void)requestAccessToTwitterAccounts:(void(^)(NSError *error))completionHandler;

+ (void)searchWithQuery:(NSString *)query maxID:(long long)maxID limit:(int)limit completionHandler:(void(^)(NSArray<Tweet *> *tweets, NSError *error))completionHandler;

@end
