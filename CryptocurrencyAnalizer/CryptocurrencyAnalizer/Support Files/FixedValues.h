//
//  FixedValues.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/21/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#ifndef FixedValues_h
#define FixedValues_h

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

#endif /* FixedValues_h */
