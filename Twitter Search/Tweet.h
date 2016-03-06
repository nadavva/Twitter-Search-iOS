//
//  Tweet.h
//  Twitter Search
//
//  Created by Mario Cecchi on 06/03/2016.
//  Copyright © 2016 Mario Cecchi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwitterUser.h"

@interface Tweet : NSObject
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) TwitterUser *user;
@end
