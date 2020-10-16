//
//  AlertHelper.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 10/16/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "AlertHelper.h"

@implementation AlertHelper

+ (UIAlertController *)createAlertControllerWithNoActionAndTitle:(nullable NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)style {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];

    [alert addAction:defaultAction];
    
    return alert;
}

@end
