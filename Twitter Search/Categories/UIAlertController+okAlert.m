//
//  UIAlertController+okAlert.m
//  Twitter Search
//
//  Created by Mario Cecchi on 09/03/2016.
//  Copyright © 2016 Mario Cecchi. All rights reserved.
//

#import "UIAlertController+okAlert.h"

@implementation UIAlertController (okAlert)

+ (instancetype)okAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    return alert;
}

@end
