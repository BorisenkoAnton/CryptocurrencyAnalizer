//
//  DBService.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/14/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

// Frameworks
#import <Foundation/Foundation.h>
#import "FMDB.h"

// Helpers
#import "TableColumn.h"
#import "WhereCondition.h"
#import "SQLStatementOptions.h"

typedef void (^Completion)(BOOL success, NSError *_Nullable error);
typedef void (^ResultCompletion)(BOOL success, FMResultSet *_Nullable result, NSError *_Nullable error);

NS_ASSUME_NONNULL_BEGIN

// Service to manage work with DB
@interface DBManager : NSObject

+ (void)createTable:(NSString *)table withColumns:(NSArray<TableColumn *> *) columns completion:(nullable Completion)completion;

+ (void)update:(NSString *)sqlStatement values:(nullable NSArray<NSObject *> *)values completion:(nullable Completion)completion;

+ (void)insert:(nullable NSArray<NSObject *> *)values intoTable:(NSString *)table completion:(nullable Completion)completion;

+ (void)queryOnTable:(NSString *)table sqlStatementOptions:(SQLStatementOptions)options completion:(ResultCompletion)completion;

+ (void)deleteFromTable:(NSString *)table whereConditions:(nullable NSArray<WhereCondition *> *)conditions completion:(nullable Completion)completion;

+ (void)dropTable:(NSString *)table completion:(nullable Completion)completion;

+ (NSArray<WhereCondition *> *)createWhereConditionsFromDictionary:(NSDictionary *)conditions;

+ (NSArray<TableColumn *> *)createTableColumnsFromArray:(NSArray *)columns;

@end

NS_ASSUME_NONNULL_END
