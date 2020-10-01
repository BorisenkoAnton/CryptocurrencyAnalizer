//
//  CacheService.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/15/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "CacheService.h"
#import "DBModel.h"
#import "FixedValues.h"

@implementation CacheService

// Caching objects (like ["BTC/USD", 10898, 1600560000]) to given table
+ (void)cacheObjects:(NSArray<NSObject *> *)objects toTable:(NSString *)table {
    
    [DBService insert:objects intoTable:table completion:nil];
}

// Checking cache for need to be updating with the help of comparison of the current date and the latest date from table
+ (void)checkCacheForNeedToBeUpdating:(NSString *)table forCoin:(NSString *)coinName maxSeparation:(NSDateComponents *)components completion:(void (^)(BOOL needsToBeUpdated))completion{
    
    NSDictionary *whereConditions = @{DB_PAIR_NAME_COLUMN:[NSString stringWithFormat:@"%@/USD", coinName]};
    
    SQLStatementOptions options;
    
    options.count = NO;
    options.orderBy = DB_TIMESTAMP_COLUMN;
    options.desc = YES;
    options.limit = @"1";
    options.whereConditions = [DBService createWhereConditionsFromDictionary:whereConditions];
    
    [DBService queryOnTable:table sqlStatementOptions:options completion:^(BOOL success, FMResultSet * _Nullable result, NSError * _Nullable error) {
        
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
    
    [DBService deleteFromTable:table whereConditions:[DBService createWhereConditionsFromDictionary:whereConditions] completion:^(BOOL success, NSError * _Nullable error) {
        
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
        
        [CacheService cacheObjects:cachingObjects toTable:table];
    }
}

@end
