//
//  DBService.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/14/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "TableColumn.h"
#import "WhereCondition.h"

typedef void (^Completion)(BOOL success, NSError *_Nullable error);
typedef void (^ResultCompletion)(BOOL success, FMResultSet *_Nullable result, NSError *_Nullable error);

NS_ASSUME_NONNULL_BEGIN

// Service to manage work with DB
@interface DBService : NSObject

+ (void)createTable:(NSString *)table withColumns:(NSArray<TableColumn *> *) columns completion:(nullable Completion)completion;

+ (void)update:(NSString *)sqlStatement values:(nullable NSArray<NSObject *> *)values completion:(nullable Completion)completion;

+ (void)insert:(nullable NSArray<NSObject *> *)values intoTable:(NSString *)table completion:(nullable Completion)completion;

+ (void)countQueryOnTable:(NSString *)table whereConditions:(WhereCondition *)condition limit:(NSString *)limit completion:(Completion)completion;

+ (void)queryOnTable:(NSString *)table whereConditions:(nullable NSArray<WhereCondition *> *)conditions limit:(nullable NSString *)limit completion:(ResultCompletion)completion;

+ (void)deleteFromTable:(NSString *)table whereConditions:(nullable NSArray<WhereCondition *> *)conditions completion:(nullable Completion)completion;

+ (void)dropTable:(NSString *)table completion:(nullable Completion)completion;

+ (void)getMaxValue:(NSString *)value fromTable:(NSString *)table whereConditions:(nullable NSArray<WhereCondition *> *)conditions completion:(ResultCompletion)completion;

@end

NS_ASSUME_NONNULL_END
