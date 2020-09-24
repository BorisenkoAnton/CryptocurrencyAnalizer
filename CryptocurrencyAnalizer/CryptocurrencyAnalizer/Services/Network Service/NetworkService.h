//
//  NetworkService.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/7/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "DBModel.h"
#import "URLService.h"
@import AFNetworking;

#ifndef NetworkService_h
#define NetworkService_h

typedef void (^NetworkServiceCompletion)(NSMutableArray<DBModel *> * _Nullable coinData);

@interface NetworkService : AFHTTPSessionManager

@property NSURLSessionConfiguration * _Nonnull configuration;
@property NSString * _Nonnull baseUrl;
@property NSString * _Nullable apiKey;

+ (id _Nonnull)shared;

- (void)downloadData:(RelativeURL)relativeURL
          parameters:(id _Nullable )parameters
          headers:(nullable NSDictionary<NSString *, NSString *> *)headers
          completion:(void (^_Nonnull)(NSObject * _Nullable data))completion;

- (void)getAndParseData:(NSString *_Nullable)coin withAPILimit:(NSNumber *_Nullable)limit completion:(NetworkServiceCompletion _Nullable )completion;

@end

#endif /* NetworkService_h */
