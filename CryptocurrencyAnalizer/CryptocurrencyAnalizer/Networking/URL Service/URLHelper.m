//
//  URLService.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/21/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "URLHelper.h"

@implementation URLHelper

+ (NSString *)getRelativeStringFrom:(RelativeURL)relativeUrl {
    
    NSString *url = nil;
    
    switch (relativeUrl) {
        case RelativeURLDailyHistory: {
            url = @"/data/v2/histoday";
            break;
        }
            
        case RelativeURLHourlyHistory: {
            url = @"/data/v2/histohour";
            break;
        }
            
        case RelativeURLMinutelyHistory: {
            url = @"/data/v2/histominute";
            break;
        }
            
        case RelativeURLAvailableCoins: {
            url = @"/data/blockchain/list";
            break;
        }
            
        default:
            break;
    }
    
    return url;
}

+ (NSString *)getBaseURL {
    
    NSString *path = [[NSBundle mainBundle] pathForResource: @"APIHelper" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *baseURL = [dict objectForKey: @"Base url"];
    return baseURL;
}

+ (NSString *)getAPIKey {
    
    NSString *path = [[NSBundle mainBundle] pathForResource: @"APIHelper" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *baseURL = [dict objectForKey: @"API key"];
    return baseURL;
}

@end
