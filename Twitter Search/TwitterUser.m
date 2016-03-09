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

+ (NSValueTransformer *)profileImageURLStringJSONTransformer {
    // This converts the small profile pictures for references to the original sizes (needed for retina-quality photos)
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *urlString, BOOL *success, NSError *__autoreleasing *error) {
        return [urlString stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
    }];
}

@end
