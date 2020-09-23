//
//  NetworkService.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/7/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkService.h"
#import "RelativeURLs.h"
#import "FixedValues.h"

// Service to manage networking via AFNetworking
@implementation NetworkService

// Singleton method
+ (id)shared {
    
    static NetworkService *networkService = nil;
    static dispatch_once_t onceToken;
    [URLService getBaseURL];
    dispatch_once(&onceToken, ^{
        networkService = [[self alloc] init];
        networkService.configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        networkService.baseUrl = [URLService getBaseURL];
        networkService.apiKey = [URLService getAPIKey];
        networkService.requestSerializer = [AFJSONRequestSerializer serializer];
    });
    return networkService;
}

// Downloading data with GET request by given url, parameters and headers
- (void)downloadData:(RelativeURL)relativeURL
          parameters:(nullable id)parameters
          headers:(nullable NSDictionary<NSString *,NSString *> *)headers
          completion:(void (^)(NSObject *data))completion {

    NSMutableString *url = [NSMutableString stringWithString:self.baseUrl];
    [url appendString:[URLService getRelativeStringFrom:relativeURL]];
    
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [self GET:url parameters:parameters headers:headers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
        completion(nil);
    }];
    
}

- (void)getAndParseData:(NSString *)coin withAPILimit:(NSNumber *)limit completion:(NetworkServiceCompletion _Nullable )completion {
    
    RelativeURL relativeURL;
    if ([limit  isEqual:API_LIMIT_FOR_MINUTELY_HISTORY]) {
        relativeURL = RelativeURLMinutelyHistory;
    } else if ([limit  isEqual:API_LIMIT_FOR_HOURLY_HISTORY]) {
        relativeURL = RelativeURLHourlyHistory;
    } else if ([limit  isEqual:API_LIMIT_FOR_DAILY_HISTORY_M]) {
        relativeURL = RelativeURLDailyHistory;
    } else if ([limit  isEqual:API_LIMIT_FOR_DAILY_HISTORY_Y]){
        relativeURL = RelativeURLDailyHistory;
    } else {
        relativeURL = RelativeURLAvailableCoins;
    }
}

//RelativeURLDailyHistory,
//RelativeURLHourlyHistory,
//RelativeURLMinutelyHistory,
//RelativeURLAvailableCoins

// Getting any type of historical data for needed coin and parse it
- (void)getAndParseHistoricalDataForCoin:(NSString *)coin withLimit:(NSNumber *)limit byRelativeURL:(RelativeURL)relativeURL completion:(NetworkServiceCompletion _Nullable )completion {
    
    NSDictionary *body = @{@"fsym":coin, @"tsym":@"USD", @"limit":limit};
    
    [self downloadData:relativeURL parameters:body headers:nil completion:^(NSObject * _Nullable data) {
        // Parsing response
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = (NSDictionary *)data;
            NSDictionary *dataField = [response valueForKey:@"Data"];
            NSArray *historicalInfo = [dataField valueForKey:@"Data"];
            
            NSString *pairName = [NSString stringWithFormat:@"%@/USD", coin];
            NSMutableArray<DBModel *> *historicalInfoForCoin = [NSMutableArray<DBModel *> new];
            for (NSObject *historicalInfoItem in historicalInfo) {
                NSNumber *price = (NSNumber *)[(NSDictionary *)historicalInfoItem valueForKey:@"high"];
                NSDate *timestamp = (NSDate *)[(NSDictionary *)historicalInfoItem valueForKey:@"time"];
                
                DBModel *model = [[DBModel alloc] initWithPairName:pairName timeStamp:timestamp andPrice:price];
                [historicalInfoForCoin addObject:model];
                
            }
            
            completion(historicalInfoForCoin);
        } else {
            completion(nil);
        }
    }];
}

// Getting daily historical data for needed period and needed coin
- (void)getDailyHistoricalDataForCoin:(NSString *)coin withLimit:(NSNumber *)limit completion:(NetworkServiceCompletion _Nullable )completion {
    
    [self getAndParseHistoricalDataForCoin:coin withLimit:limit byRelativeURL:RelativeURLDailyHistory completion:^(NSMutableArray<DBModel *> *coinData) {
        completion(coinData);
    }];
}

// Getting hourly historical data for needed period and needed coin
- (void)getHourlyHistoricalDataForCoin:(NSString *)coin withLimit:(NSNumber *)limit completion:(NetworkServiceCompletion _Nullable )completion {
    
    [self getAndParseHistoricalDataForCoin:coin withLimit:limit byRelativeURL:RelativeURLHourlyHistory completion:^(NSMutableArray<DBModel *> *coinData) {
        completion(coinData);
    }];
}

// Getting minutely historical data for needed period and needed coin
- (void)getMinutelyHistoricalDataForCoin:(NSString *)coin withLimit:(NSNumber *)limit completion:(NetworkServiceCompletion _Nullable )completion {
    
    [self getAndParseHistoricalDataForCoin:coin withLimit:limit byRelativeURL:RelativeURLMinutelyHistory completion:^(NSMutableArray<DBModel *> *coinData) {
        NSMutableArray *tenMinutesChanges = [NSMutableArray new];
        for (int i = 0; i < coinData.count; i += 10) {
            [tenMinutesChanges addObject:coinData[i]];
        }
        
        completion(tenMinutesChanges);
    }];
}

// Getting array of NSString names of all available coins
- (void)getAvailableCoins:(void (^)(NSArray *availableCoins))completion {
    
    NSDictionary *body = @{@"api_key":self.apiKey};
    
    [self downloadData:RelativeURLAvailableCoins parameters:body headers:nil completion:^(NSObject * _Nullable data) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = (NSDictionary *)data;
            NSDictionary *dataField = [response valueForKey:@"Data"];
            NSMutableArray *availableCoins = [NSMutableArray new];
            
            for (NSString *coin in dataField) {
                [availableCoins addObject:coin];
            }
            
            completion(availableCoins);
        } else {
            completion(nil);
        }
    }];
}

@end
