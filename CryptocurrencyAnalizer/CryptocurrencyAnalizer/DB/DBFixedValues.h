//
//  DBFixedValues.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 10/12/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#ifndef DBFixedValues_h
#define DBFixedValues_h

// DB data types
#define DB_TEXT_TYPE @"TEXT"
#define DB_REAL_TYPE @"REAL"
#define DB_INTEGER_TYPE @"INTEGER"

// Tables names
#define DB_MINUTELY_TABLE @"minutelyHistoricalData"
#define DB_HOURLY_TABLE @"hourlyHistoricalData"
#define DB_DAILY_TABLE @"dailyHistoricalData"

// Tables columns names
#define DB_PAIR_NAME_COLUMN @"pairName"
#define DB_PRICE_COLUMN @"price"
#define DB_TIMESTAMP_COLUMN @"timestamp"

// Limits for queries
#define DB_LIMIT_FOR_MINUTELY_TABLE @"144"
#define DB_LIMIT_FOR_HOURLY_TABLE @"168"
#define DB_LIMIT_FOR_DAILY_TABLE_M @"30"
#define DB_LIMIT_FOR_DAILY_TABLE_Y @"365"

#endif /* DBFixedValues_h */
