//
//  TwitterUser.m
//  Twitter Search
//
//  Created by Mario Cecchi on 06/03/2016.
//  Copyright © 2016 Mario Cecchi. All rights reserved.
//

#import "TwitterUser.h"

@implementation TwitterUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"screenName": @"screen_name",
             @"name": @"name",
             @"profileImageURLString": @"profile_image_url_https"
             };
}

@end
