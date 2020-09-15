//
//  DBService.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/14/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "DBService.h"

@implementation DBService

// To access the database
static FMDatabase *sharedDatabase;
// To access a serial queue for updating the database
static FMDatabaseQueue *sharedQueue;

+ (FMDatabase *) sharedDatabase {
    
    @try {
        NSURL *fileURL = [[NSFileManager.defaultManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil] URLByAppendingPathComponent:@"CryptocurrencyAnalizer.sqlite"];
        sharedDatabase = [FMDatabase databaseWithURL:fileURL];
    } @catch (NSException *exception) {
        NSLog(@"DB error: %@", exception.name);
    }
    return sharedDatabase;
};

+ (FMDatabaseQueue *) sharedQueue {
    @try {
        NSURL *documents = [NSFileManager.defaultManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL *fileUrl = [documents URLByAppendingPathComponent:@"test.sqlite"];
        sharedQueue = [FMDatabaseQueue databaseQueueWithPath:fileUrl.path];
    } @catch (NSException *exception) {
        NSLog(@"Database Queue error: %@", exception.name);
    }
    return sharedQueue;
};

// Creating a table with the specified list of columns and value types
+ (void)createTable:(NSString *)table withColumns:(NSArray<TableColumn *> *)columns completion:(Completion)completion {

    NSMutableString *sqlStatement = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID Integer Primary key AutoIncrement,", table];
    
    for (TableColumn *tableColumn in columns) {
        [sqlStatement appendFormat:@"%@ %@ ",tableColumn.name, tableColumn.type];
        ([columns indexOfObjectIdenticalTo:tableColumn] == columns.count - 1) ? [sqlStatement appendString:@");"] : [sqlStatement appendString:@","];
    }
    [DBService update:sqlStatement values:nil completion:completion];
}

// All transactions in FMDB are an UPDATE if they are not a QUERY, this helper method is called by the CREATE, INSERT, and DELETE functions
+ (void)update:(NSString *)sqlStatement values:(NSArray<NSObject *> *)values completion:(Completion)completion {
    
    if (!sharedQueue) {
        sharedQueue = [DBService sharedQueue];
    }
    if (!sharedDatabase) {
        sharedDatabase = [DBService sharedDatabase];
    }
    
    [sharedQueue inDeferredTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        @try {
            if (!sharedDatabase.isOpen) {
                [sharedDatabase open];
            }
            [sharedDatabase executeUpdate:sqlStatement values:values error:nil];
            if(completion) {
                completion(YES, nil);
            }
            [sharedDatabase close];
        } @catch (NSException *exception) {
            NSLog(@"Updating failed: %@", exception.name);
            if(completion) {
                completion(NO, (NSError *)exception);
            }
            [sharedDatabase close];

        }
    }];
}

// Inserting an array of values in the given table
+ (void)insert:(NSArray<NSObject *> *)values intoTable:(NSString *)table completion:(Completion)completion {
    
    NSMutableString *sqlStatement = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES (NULL", table];
    
    for (NSObject *value in values) {
        ([values indexOfObjectIdenticalTo:value] == values.count - 1) ? [sqlStatement appendString:@", ?)"] : [sqlStatement appendString:@", ?"];
    }
    
    [DBService update:sqlStatement values:values completion:completion];
}

+ (void)countQueryOnTable:(NSString *)table whereConditions:(WhereCondition *)condition completion:(Completion)completion {
    
    NSMutableString *sqlCountStatement = [NSMutableString stringWithFormat:@"SELECT COUNT(*) FROM %@", table];

    if (condition) {
        [sqlCountStatement appendFormat:@" WHERE %@ = '%@'", condition.column, condition.value];
    }
    
    //[sharedQueue inDeferredTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        @try {
            if (!sharedDatabase.isOpen) {
                [sharedDatabase open];
            }
            int count = [sharedDatabase intForQuery:sqlCountStatement];
            if (count != 0) {
                completion(YES, nil);
            } else {
                completion(NO, nil);
            }
            [sharedDatabase close];
        } @catch (NSException *exception) {
           // rollback = YES;
            completion(NO, (NSError *)exception);
            [sharedDatabase close];
        }
   // }];
}

// Query the given table based on conditions provided
+ (void)queryOnTable:(NSString *)table whereConditions:(NSArray<WhereCondition *> *)conditions completion:(ResultCompletion)completion {
    
    NSMutableString *sqlStatement = [NSMutableString stringWithFormat:@"SELECT * FROM %@", table];
    
    NSMutableArray<NSObject *> *values = [NSMutableArray<NSObject *> new];
    if (conditions) {
        [sqlStatement appendString:@" WHERE"];
        for (WhereCondition *condition in conditions) {
            [values addObject:condition.value];
            [sqlStatement appendFormat:@" %@ = ?", condition.column];
            ([conditions indexOfObjectIdenticalTo:condition] == conditions.count - 1) ? [sqlStatement appendString:@""] : [sqlStatement appendString:@","];
        }
    }
    
    [sharedQueue inDeferredTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        @try {
            if (!sharedDatabase.isOpen) {
                [sharedDatabase open];
            }
            FMResultSet *fmresult = [sharedDatabase executeQuery:sqlStatement values:values error:nil];
            completion(YES, fmresult, nil);
            [sharedDatabase close];
        } @catch (NSException *exception) {
            rollback = YES;
            completion(YES, nil, (NSError *)exception);
            [sharedDatabase close];
        }
    }];
    
}

// Deleting a row of data from a given table based on conditions
+ (void)deleteFromTable:(NSString *)table whereConditions:(NSArray<WhereCondition *> *)conditions completion:(Completion)completion {
    
    NSString *sqlStatement = [NSString stringWithFormat:@"DELETE FROM %@", table];
    
    NSMutableArray<NSObject *> *values = [NSMutableArray<NSObject *> new];
    
    [sqlStatement stringByAppendingString:@" WHERE"];
    for (WhereCondition *condition in conditions) {
        [values addObject:condition.value];
        [sqlStatement stringByAppendingFormat:@" %@ = ?", condition.column];
        ([conditions indexOfObjectIdenticalTo:condition] == conditions.count - 1) ? [sqlStatement stringByAppendingString:@""] : [sqlStatement stringByAppendingString:@","];
    }
    
    [DBService update:sqlStatement values:values completion:completion];
}

+ (void)dropTable:(NSString *)table completion:(Completion)completion {
    
    NSString *sqlStatement = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", table];
    [DBService update:sqlStatement values:nil completion:completion];
}

@end
