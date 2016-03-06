//
//  TwitterUser.h
//  Twitter Search
//
//  Created by Mario Cecchi on 06/03/2016.
//  Copyright © 2016 Mario Cecchi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterUser : NSObject
@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *profileImageURLString;
@end
