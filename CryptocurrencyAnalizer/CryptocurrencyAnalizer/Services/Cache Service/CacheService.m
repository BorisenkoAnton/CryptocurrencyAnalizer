//
//  CacheService.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/15/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "CacheService.h"
#import "DBModel.h"

@implementation CacheService

// Caching objects (like ["BTC/USD", 10898, 1600560000]) to given table
+ (void)cacheObjects:(NSArray<NSObject *> *)objects toTable:(NSString *)table {
    
    [DBService insert:objects intoTable:table completion:nil];
}

// Checking cache for need to be updating with the help of comparison of the current date and the latest date from table
+ (void)checkCacheForNeedToBeUpdating:(NSString *)table whereConditions:(NSArray<WhereCondition *> *)conditions maxSeparation:(NSDateComponents *)components completion:(void (^)(BOOL needsToBeUpdated))completion{
    
    [DBService getMaxValue:@"timestamp" fromTable:table whereConditions:conditions completion:^(BOOL success, FMResultSet * _Nullable result, NSError * _Nullable error) {
        // Success means that there were needed items in the table
        if (success) {
            [result next];
            
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            
            // Adding maximum separation (in some time units) to the latest date from table
            NSDate *latestDate = [calendar dateByAddingComponents:components toDate:[result dateForColumn:@"timestamp"] options:0];
            
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
    
    WhereCondition *condition = [[WhereCondition alloc] initWithColumn:@"pairName" andValue:[NSString stringWithFormat:@"%@/USD", coinName]];
    [DBService deleteFromTable:table whereConditions:[NSArray arrayWithObject:condition] completion:^(BOOL success, NSError * _Nullable error) {
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

