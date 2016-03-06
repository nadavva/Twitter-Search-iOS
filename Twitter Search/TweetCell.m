//
//  TweetCell.m
//  Twitter Search
//
//  Created by Mario Cecchi on 06/03/2016.
//  Copyright © 2016 Mario Cecchi. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "TweetCell.h"

@implementation TweetCell

- (void)configureCellWithTweet:(Tweet *)tweet {
    self.tweetLabel.text = tweet.text;
    self.userNameLabel.text = tweet.user.name;

    NSString *profilePictureURLString = tweet.user.profileImageURLString;
    if (profilePictureURLString.length > 0) {
        [self.profilePicture sd_setImageWithURL:[NSURL URLWithString:profilePictureURLString]
                  placeholderImage:nil
                           options:SDWebImageRefreshCached | SDWebImageRetryFailed];
    } else {
        self.profilePicture.image = nil;
    }
}

@end
