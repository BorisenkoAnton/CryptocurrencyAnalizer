//
//  NetworkService.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/7/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkService.h"

// Service to manage networking via AFNetworking
@implementation NetworkService

+ (id)shared {
    
    static NetworkService *networkService = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        networkService = [[self alloc] init];
        networkService.configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        networkService.baseUrl = @"https://min-api.cryptocompare.com";
        networkService.requestSerializer = [AFJSONRequestSerializer serializer];
    });
    return networkService;
}

- (void)downloadData:(NSString *)url
          parameters:(nullable id)parameters
          headers:(nullable NSDictionary<NSString *,NSString *> *)headers
          completion:(void (^)(NSObject *data))completion {

    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [self GET:url parameters:parameters headers:headers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
        completion(nil);
    }];
    
}

// Getting daily historical data for needed period and needed coin
- (void)getDailyHistoricalDataForCoin:(NSString *)coin withLimit:(NSNumber *)limit completion:(void (^)(NSArray *coinData))completion {
    
    NSString *url = [self.baseUrl stringByAppendingString:@"/data/v2/histoday"];
    NSDictionary *body = @{@"fsym":coin, @"tsym":@"USD", @"limit":limit};
    
    [self downloadData:url parameters:body headers:nil completion:^(NSObject * _Nullable data) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = (NSDictionary *)data;
            NSDictionary *dataField = [response valueForKey:@"Data"];
            NSArray *historicalInfo = [dataField valueForKey:@"Data"];
            
            NSMutableArray *historicalInfoForCoin = [NSMutableArray new];
            for (NSObject *historicalInfoItem in historicalInfo) {
                NSNumber *price = (NSNumber *)[(NSDictionary *)historicalInfoItem valueForKey:@"high"];
                [historicalInfoForCoin addObject:price];
            }
            
            completion(historicalInfoForCoin);
        } else {
            completion(nil);
        }
    }];
}

// Getting hourly historical data for needed period and needed coin
- (void)getHourlyHistoricalDataForCoin:(NSString *)coin withLimit:(NSNumber *)limit completion:(void (^)(NSArray *coinData))completion {
    
    NSString *url = [self.baseUrl stringByAppendingString:@"/data/v2/histohour"];
    NSDictionary *body = @{@"fsym":coin, @"tsym":@"USD", @"limit":limit};
    
    [self downloadData:url parameters:body headers:nil completion:^(NSObject * _Nullable data) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = (NSDictionary *)data;
            NSDictionary *dataField = [response valueForKey:@"Data"];
            NSArray *historicalInfo = [dataField valueForKey:@"Data"];
            
            NSMutableArray *historicalInfoForCoin = [NSMutableArray new];
            for (NSObject *historicalInfoItem in historicalInfo) {
                NSNumber *price = (NSNumber *)[(NSDictionary *)historicalInfoItem valueForKey:@"high"];
                [historicalInfoForCoin addObject:price];
            }
            
            completion(historicalInfoForCoin);
        } else {
            completion(nil);
        }
    }];
}

// Getting minutely historical data for needed period and needed coin
- (void)getMinutelyHistoricalDataForCoin:(NSString *)coin withLimit:(NSNumber *)limit completion:(void (^)(NSArray *coinData))completion {
    
    NSString *url = [self.baseUrl stringByAppendingString:@"/data/v2/histominute"];
    NSDictionary *body = @{@"fsym":coin, @"tsym":@"USD", @"limit":limit};
    
    [self downloadData:url parameters:body headers:nil completion:^(NSObject * _Nullable data) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = (NSDictionary *)data;
            NSDictionary *dataField = [response valueForKey:@"Data"];
            NSArray *historicalInfo = [dataField valueForKey:@"Data"];
            
            NSMutableArray *historicalInfoForCoin = [NSMutableArray new];
            for (NSObject *historicalInfoItem in historicalInfo) {
                NSNumber *price = (NSNumber *)[(NSDictionary *)historicalInfoItem valueForKey:@"high"];
                [historicalInfoForCoin addObject:price];
            }
            
            completion(historicalInfoForCoin);
        } else {
            completion(nil);
        }
    }];
}

// Getting array of NSString names of all available coins
- (void)getAvailableCoins:(void (^)(NSArray *availableCoins))completion {
    
    NSString *url = [self.baseUrl stringByAppendingString:@"/data/blockchain/list"];
    NSDictionary *body = @{@"api_key":@"f2796ad1a4b0f52d336872f658e1d1fd76b0ca2789ee28e89f9b5858fde95461"};
    
    [self downloadData:url parameters:body headers:nil completion:^(NSObject * _Nullable data) {
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
