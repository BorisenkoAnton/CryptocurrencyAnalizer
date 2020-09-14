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

typedef void (^Completion)(BOOL completion, NSError *_Nullable error);
typedef void (^ResultCompletion)(BOOL completion, FMResultSet *_Nullable, NSError *_Nullable error);

NS_ASSUME_NONNULL_BEGIN

// Service to manage work with DB
@interface DBService : NSObject

+ (void)createTable:(NSString *)table withColumns:(NSArray<TableColumn *> *) columns completion:(Completion)completion;
+ (void)update:(NSString *)sqlStatement values:(nullable NSArray<NSObject *> *)values completion:(Completion)completion;
+ (void)insert:(nullable NSArray<NSObject *> *)values intoTable:(NSString *)table completion:(Completion)completion;
+ (void)queryOnTable:(NSString *)table whereConditions:(nullable NSArray<WhereCondition *> *)conditions completion:(ResultCompletion)completion;
+ (void)deleteFromTable:(NSString *)table whereConditions:(nullable NSArray<WhereCondition *> *)conditions completion:(Completion)completion;
+ (void)dropTable:(NSString *)table completion:(Completion)completion;

@end

NS_ASSUME_NONNULL_END
