//
//  NetworkService.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/7/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

@import AFNetworking;

#ifndef NetworkService_h
#define NetworkService_h

@interface NetworkService : AFHTTPSessionManager

@property NSURLSessionConfiguration *configuration;
@property NSString *baseUrl;
@property NSString *apiKey;

+ (id)shared;

- (void)downloadData:(NSString *)url
          parameters:(nullable id)parameters
          headers:(nullable NSDictionary<NSString *,NSString *> *)headers
          completion:(void (^_Nonnull)(NSObject * _Nullable data))completion;
- (void)getAvailableCoins:(void (^_Nullable)(NSArray * _Nonnull availableCoins))completion;
- (void)getDailyHistoricalDataForCoin:(NSString *_Nonnull)coin
                       withLimit:(NSNumber *_Nullable)limit
                       completion:(void (^_Nullable)(NSArray * _Nullable coinData))completion;
- (void)getHourlyHistoricalDataForCoin:(NSString *_Nonnull)coin
                       withLimit:(NSNumber *_Nullable)limit
                       completion:(void (^_Nullable)(NSArray * _Nullable coinData))completion;
- (void)getMinutelyHistoricalDataForCoin:(NSString *_Nonnull)coin
                       withLimit:(NSNumber *_Nullable)limit
                       completion:(void (^_Nullable)(NSArray * _Nullable coinData))completion;

@end

#endif /* NetworkService_h */
