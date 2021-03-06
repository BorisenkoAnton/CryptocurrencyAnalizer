//
//  CacheService.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/15/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

// Frameworks
#import <Foundation/Foundation.h>
#import "FMDB.h"

// Helpers
#import "TableColumn.h"
#import "WhereCondition.h"

// Services
#import "DBManager.h"


// Models
#import "DBModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CacheManager : NSObject

+ (void)cacheObjects:(NSArray<NSObject *> *)objects toTable:(NSString *)table;

+ (void)checkCacheForNeedToBeUpdating:(NSString *)table
                        forCoin:(NSString *)coinName
                        maxSeparation:(NSDateComponents *)components
                        completion:(void (^)(BOOL needsToBeUpdated))completion;

+ (void)clearCacheInTable:(NSString *)table forCoin:(NSString *)coinName completion:(void (^)(BOOL success))completion;

+ (void)cacheArrayOfObjects:(NSArray<NSObject *> *)objects toTable:(NSString *)table;

+ (void)getCachedDataIfExists:(NSString *)table
                        limit:(NSString *)limit
                        maxSeparation:(nonnull NSDateComponents *)components
                        coinName:(NSString *)coinName
                        completion:(void (^)(BOOL success, NSMutableArray<DBModel *> *cachedData))completion;

@end

NS_ASSUME_NONNULL_END
