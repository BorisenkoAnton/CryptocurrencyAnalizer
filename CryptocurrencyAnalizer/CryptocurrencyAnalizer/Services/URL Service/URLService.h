//
//  URLService.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/21/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import <Foundation/Foundation.h>

// Helpers
#import "RelativeURLs.h"

NS_ASSUME_NONNULL_BEGIN

@interface URLService : NSObject

+ (NSString *)getRelativeStringFrom:(RelativeURL)relativeUrl;
+ (NSString *)getBaseURL;
+ (NSString *)getAPIKey;

@end

NS_ASSUME_NONNULL_END
