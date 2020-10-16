//
//  CacheService.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/15/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "CacheManager.h"
#import "DBModel.h"

@implementation CacheManager

// Caching objects (like ["BTC/USD", 10898, 1600560000]) to given table
+ (void)cacheObjects:(NSArray<NSObject *> *)objects toTable:(NSString *)table {
    
    [DBManager insert:objects intoTable:table completion:nil];
}

// Checking cache for need to be updating with the help of comparison of the current date and the latest date from table
+ (void)checkCacheForNeedToBeUpdating:(NSString *)table forCoin:(NSString *)coinName maxSeparation:(NSDateComponents *)components completion:(void (^)(BOOL needsToBeUpdated))completion{
    
    NSDictionary *whereConditions = @{DB_PAIR_NAME_COLUMN:[NSString stringWithFormat:@"%@/USD", coinName]};
    
    SQLStatementOptions options;
    
    options.count = NO;
    options.orderBy = DB_TIMESTAMP_COLUMN;
    options.desc = YES;
    options.limit = @"1";
    options.whereConditions = [DBManager createWhereConditionsFromDictionary:whereConditions];
    
    [DBManager queryOnTable:table sqlStatementOptions:options completion:^(BOOL success, FMResultSet * _Nullable result, NSError * _Nullable error) {
        
        if (success) {
            [result next];
            
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            
            // Adding maximum separation (in some time units) to the latest date from table
            NSDate *latestDate = [calendar dateByAddingComponents:components toDate:[result dateForColumn:DB_TIMESTAMP_COLUMN] options:0];
            
            if ([[NSDate now] timeIntervalSince1970] > [latestDate timeIntervalSince1970]) {
                completion(YES);
            } else {
                completion(NO);
            }
        }
    }];

}

// Clearing all the cach for needed coin
+ (void)clearCacheInTable:(NSString *)table forCoin:(NSString *)coinName completion:(void (^)(BOOL success))completion{
    
    NSDictionary *whereConditions = @{DB_PAIR_NAME_COLUMN:[NSString stringWithFormat:@"%@/USD", coinName]};
    
    [DBManager deleteFromTable:table whereConditions:[DBManager createWhereConditionsFromDictionary:whereConditions] completion:^(BOOL success, NSError * _Nullable error) {
        
        if (success) {
            completion(YES);
        } else {
            completion(NO);
        }
    }];
}

// Caching array of objects (like ["BTC/USD", 10898, 1600560000]) to given table
+ (void)cacheArrayOfObjects:(NSArray<NSObject *> *)objects toTable:(NSString *)table {
    
    NSMutableArray<NSObject *> *cachingObjects = [NSMutableArray<NSObject *> new];
    
    for (DBModel *model in objects) {
        [cachingObjects removeAllObjects];
        [cachingObjects addObject:model.pairName];
        [cachingObjects addObject:model.price];
        [cachingObjects addObject:model.timestamp];
        
        [CacheManager cacheObjects:cachingObjects toTable:table];
    }
}


+ (void)getCachedDataIfExists:(NSString *)table limit:(NSString *)limit maxSeparation:(NSDateComponents *)components coinName:(NSString *)coinName completion:(void (^)(BOOL, NSMutableArray<DBModel *> *cachedData))completion {
    
    // First, check if cache exists with needed volume of data
       SQLStatementOptions options;
       
       NSDictionary *whereConditions = @{DB_PAIR_NAME_COLUMN:[NSString stringWithFormat:@"%@/USD", coinName]};
       
       options.limit = limit;
       options.count = YES;
       options.whereConditions = [DBManager createWhereConditionsFromDictionary:whereConditions];
       
       [DBManager queryOnTable:table sqlStatementOptions:options completion:^(BOOL success, FMResultSet * _Nullable result, NSError * _Nullable error) {
           // Then, if data is cached in needed volume, checking it for updating
           if (success) {
               [CacheManager checkCacheForNeedToBeUpdating:table forCoin:coinName maxSeparation:components completion:^(BOOL needsToBeUpdated) {
                   if (needsToBeUpdated) {
                       completion(NO, nil);
                   } else {
                       // If cache have not to be updating, get it from db
                       SQLStatementOptions newOptions;
                       NSDictionary *whereConditions = @{DB_PAIR_NAME_COLUMN:[NSString stringWithFormat:@"%@/USD", coinName]};
                       
                       newOptions.limit = limit;
                       newOptions.count = NO;
                       newOptions.desc = nil;
                       newOptions.whereConditions = [DBManager createWhereConditionsFromDictionary:whereConditions];
                       
                       [DBManager queryOnTable:table sqlStatementOptions:newOptions completion:^(BOOL success, FMResultSet * _Nullable result, NSError * _Nullable error) {
                           if (success) {
                               NSMutableArray *cachedData = [NSMutableArray new];
                               
                               while ([result next]) {
                                   DBModel *model = [DBModel new];
                                   
                                   model.price = [NSNumber numberWithDouble:[result doubleForColumn:DB_PRICE_COLUMN]];
                                   
                                   NSNumber *timestampInMS = [NSNumber numberWithInteger:[result intForColumn:DB_TIMESTAMP_COLUMN]];
                                   
                                   model.timestamp = timestampInMS;
                                   
                                   [cachedData addObject:model];
                               }
                               
                               completion(YES, cachedData);
                           } else {
                               completion(NO, nil);
                           }
                       }];
                   }
               }];
           } else {
               completion(NO, nil);
           }
       }];
}

@end
