//
//  UIAlertController+okAlert.h
//  Twitter Search
//
//  Created by Mario Cecchi on 09/03/2016.
//  Copyright © 2016 Mario Cecchi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (okAlert)

+ (instancetype)okAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
