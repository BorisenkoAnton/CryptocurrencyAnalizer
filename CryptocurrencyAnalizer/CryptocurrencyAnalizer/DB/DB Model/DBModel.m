//
//  DBModel.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/15/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "DBModel.h"

@implementation DBModel

- (id)initWithPairName:(NSString *)pairName timeStamp:(NSDate *)timestamp andPrice:(NSNumber *)price {
    
    self.ID = nil;
    self.pairName = pairName;
    self.timestamp = timestamp;
    self.price = price;
    
    return self;
}


+ (void)createTablesForModel {
    
    // Creating all needed for caching tables if they are not exist
    NSArray *columns = @[DB_PAIR_NAME_COLUMN, DB_TEXT_TYPE, DB_PRICE_COLUMN, DB_REAL_TYPE, DB_TIMESTAMP_COLUMN, DB_INTEGER_TYPE];
    NSArray<TableColumn *> *columnsForTablesWithPrices = [DBService createTableColumnsFromArray:columns];
    
    [DBService createTable:DB_MINUTELY_TABLE withColumns:columnsForTablesWithPrices completion:nil];
    [DBService createTable:DB_HOURLY_TABLE withColumns:columnsForTablesWithPrices completion:nil];
    [DBService createTable:DB_DAILY_TABLE withColumns:columnsForTablesWithPrices completion:nil];
}

@end
