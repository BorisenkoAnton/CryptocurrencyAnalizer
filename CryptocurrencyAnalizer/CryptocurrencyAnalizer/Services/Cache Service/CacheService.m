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

+ (void)cacheObjects:(NSArray<NSObject *> *)objects toTable:(NSString *)table {
    
    [DBService insert:objects intoTable:table completion:nil];
}

+ (void)checkCacheForNeedToBeUpdating:(NSString *)table whereConditions:(NSArray<WhereCondition *> *)conditions maxSeparation:(NSDateComponents *)components completion:(void (^)(BOOL needsToBeUpdated))completion{
    
    [DBService getMaxValue:@"timestamp" fromTable:table whereConditions:conditions completion:^(BOOL success, FMResultSet * _Nullable result, NSError * _Nullable error) {
        if (success) {
            [result next];
            
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            
            NSDate *latestDate = [calendar dateByAddingComponents:components toDate:[result dateForColumn:@"timestamp"] options:0];
            
            if ([NSDate now] > latestDate) {
                completion(YES);
            } else {
                completion(NO);
            }
            
        }
    }];
}

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

