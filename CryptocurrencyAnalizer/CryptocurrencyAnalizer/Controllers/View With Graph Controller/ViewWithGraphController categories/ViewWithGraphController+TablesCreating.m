//
//  ViewWithGraphController+TablesCreating.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/23/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "ViewWithGraphController+TablesCreating.h"

@implementation ViewWithGraphController (TablesCreating)

- (void)createTablesInDB {
    
    // Creating all needed for caching tables if they are not exist
    NSDictionary *columns = @{DB_PAIR_NAME_COLUMN:DB_TEXT_TYPE, DB_PRICE_COLUMN:DB_REAL_TYPE, DB_TIMESTAMP_COLUMN:DB_INTEGER_TYPE};
    NSArray<TableColumn *> *columnsForTablesWithPrices = [DBService createTableColumnsFromDictionary:columns];
    [DBService createTable:DB_MINUTELY_TABLE withColumns:columnsForTablesWithPrices completion:nil];
    [DBService createTable:DB_HOURLY_TABLE withColumns:columnsForTablesWithPrices completion:nil];
    [DBService createTable:DB_DAILY_TABLE withColumns:columnsForTablesWithPrices completion:nil];
}

@end
