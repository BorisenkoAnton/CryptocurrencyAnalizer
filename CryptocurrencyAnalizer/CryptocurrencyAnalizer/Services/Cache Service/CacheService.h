//
//  CacheService.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/15/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "TableColumn.h"
#import "WhereCondition.h"
#import "DBService.h"

NS_ASSUME_NONNULL_BEGIN

@interface CacheService : NSObject

+ (void)cacheObjects:(NSArray<NSObject *> *)objects toTable:(NSString *)table;
//+ (void)getCachedObjects:(NSString *)table whereConditions:(nullable NSArray<WhereCondition *> *)conditions completion:(ResultCompletion)completion;
+ (void)cacheArrayOfObjects:(NSArray<NSObject *> *)objects toTable:(NSString *)table;

@end

NS_ASSUME_NONNULL_END
