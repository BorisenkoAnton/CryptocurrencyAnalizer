//
//  AlertHelper.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 10/16/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlertHelper : NSObject

+ (UIAlertController *)createAlertControllerWithNoActionAndTitle:(nullable NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)style;

@end

NS_ASSUME_NONNULL_END
