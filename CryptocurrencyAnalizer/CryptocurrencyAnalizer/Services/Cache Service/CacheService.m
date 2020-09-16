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

//+ (void)getCachedObjects:(NSString *)table whereConditions:(NSArray<WhereCondition *> *)conditions completion:(ResultCompletion)completion {
//
//    [DBService queryOnTable:table whereConditions:conditions completion:^(BOOL success, FMResultSet * _Nullable result, NSError * _Nullable error) {
//        completion(success, result, error);
//    }];
//}

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

