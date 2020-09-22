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
    
    //[sharedQueue inDeferredTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
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
    //}];
}

// Inserting an array of values in the given table
+ (void)insert:(NSArray<NSObject *> *)values intoTable:(NSString *)table completion:(Completion)completion {
    
    NSMutableString *sqlStatement = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES (NULL", table];
    
    for (NSObject *value in values) {
        ([values indexOfObjectIdenticalTo:value] == values.count - 1) ? [sqlStatement appendString:@", ?)"] : [sqlStatement appendString:@", ?"];
    }
    
    [DBService update:sqlStatement values:values completion:completion];
}

// Query the given table based on conditions provided
+ (void)queryOnTable:(NSString *)table sqlStatementOptions:(SQLStatementOptions)options completion:(ResultCompletion)completion {
    
    NSMutableString *sqlStatement;
    if (options.count) {
        sqlStatement = [NSMutableString stringWithFormat:@"SELECT COUNT(*) FROM %@", table];
    } else {
        sqlStatement = [NSMutableString stringWithFormat:@"SELECT * FROM %@", table];
    }
    
    NSMutableArray<NSObject *> *values = [NSMutableArray<NSObject *> new];
    if (options.whereConditions) {
        [sqlStatement appendString:@" WHERE"];
        for (WhereCondition *condition in options.whereConditions) {
            [values addObject:condition.value];
            [sqlStatement appendFormat:@" %@ = '%@'", condition.column, condition.value];
            ([options.whereConditions indexOfObjectIdenticalTo:condition] == options.whereConditions.count - 1) ? [sqlStatement appendString:@""] : [sqlStatement appendString:@","];
        }
    }
    
    if (options.orderBy) {
        [sqlStatement appendFormat:@" ORDER BY %@", options.orderBy];
    }
    
    if (options.desc) {
        [sqlStatement appendString:@" desc"];
    }
    
    if (options.limit) {
        [sqlStatement appendFormat:@" limit %@", options.limit];
    }

    @try {
        if (!sharedDatabase.isOpen) {
            [sharedDatabase open];
        }
        
        if (options.count && options.limit) {
            int count = [sharedDatabase intForQuery:sqlStatement];
            if (count >= [options.limit intValue]) {
                completion(YES, nil, nil);
            } else {
                completion(NO, nil, nil);
            }
        } else {
            FMResultSet *fmresult = [sharedDatabase executeQuery:sqlStatement values:values error:nil];
            completion(YES, fmresult, nil);
        }
        
        [sharedDatabase close];
    } @catch (NSException *exception) {
        completion(YES, nil, (NSError *)exception);
        [sharedDatabase close];
    }
    
}

// Deleting a row of data from a given table based on conditions
+ (void)deleteFromTable:(NSString *)table whereConditions:(NSArray<WhereCondition *> *)conditions completion:(Completion)completion {
    
    NSMutableString *sqlStatement = [NSMutableString stringWithFormat:@"DELETE FROM %@", table];
    
    NSMutableArray<NSObject *> *values = [NSMutableArray<NSObject *> new];
    
    [sqlStatement appendString:@" WHERE"];
    for (WhereCondition *condition in conditions) {
        [values addObject:condition.value];
        [sqlStatement appendFormat:@" %@ = ?", condition.column];
        ([conditions indexOfObjectIdenticalTo:condition] == conditions.count - 1) ? [sqlStatement appendString:@""] : [sqlStatement appendString:@","];
    }

    [DBService update:sqlStatement values:values completion:completion];
}

+ (void)dropTable:(NSString *)table completion:(Completion)completion {
    
    NSString *sqlStatement = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", table];
    [DBService update:sqlStatement values:nil completion:completion];
}

+ (NSArray<WhereCondition *> *)createWhereConditionsFromDictionary:(NSDictionary *)conditions {
    
    NSMutableArray<WhereCondition *> * createdConditions = [NSMutableArray<WhereCondition *> new];
    for(id key in conditions) {
        WhereCondition *newCondition = [[WhereCondition alloc] initWithColumn:key andValue:[conditions valueForKey:key]];
        [createdConditions addObject:newCondition];
    }
    return createdConditions;
}

+ (NSArray<TableColumn *> *)createTableColumnsFromDictionary:(NSDictionary *)columns {
    
    NSMutableArray<TableColumn *> * createdColumns = [NSMutableArray<TableColumn *> new];
    for(id key in columns) {
        TableColumn *newColumn = [[TableColumn alloc] initWithName:key andType:[columns valueForKey:key]];
        [createdColumns addObject:newColumn];
    }
    return createdColumns;
}

@end
