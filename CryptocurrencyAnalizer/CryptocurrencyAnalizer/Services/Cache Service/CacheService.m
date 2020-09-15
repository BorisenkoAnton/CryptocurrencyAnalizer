//
//  CacheService.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/15/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "CacheService.h"

@implementation CacheService

+ (void)cacheObjects:(NSArray<NSObject *> *)objects toTable:(NSString *)table {
    
    [DBService insert:objects intoTable:table completion:nil];
}

+ (void)getCachedObjects:(NSString *)table whereConditions:(NSArray<WhereCondition *> *)conditions completion:(ResultCompletion)completion {
    
    [DBService queryOnTable:table whereConditions:conditions completion:^(BOOL success, FMResultSet * _Nullable result, NSError * _Nullable error) {
        completion(success, result, error);
    }];
}

@end
