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

// Limits for queries and API calls
#define DB_LIMIT_FOR_MINUTELY_TABLE @"144"
#define DB_LIMIT_FOR_HOURLY_TABLE @"168"
#define DB_LIMIT_FOR_DAILY_TABLE_M @"30"
#define DB_LIMIT_FOR_DAILY_TABLE_Y @"365"

#define API_LIMIT_FOR_MINUTELY_HISTORY @1439
#define API_LIMIT_FOR_HOURLY_HISTORY @167
#define API_LIMIT_FOR_DAILY_HISTORY_M @29
#define API_LIMIT_FOR_DAILY_HISTORY_Y @364

// Plot dots count
#define PLOT_DOTS_COUNT_DAY 144
#define PLOT_DOTS_COUNT_WEEK 168
#define PLOT_DOTS_COUNT_MONTH 30
#define PLOT_DOTS_COUNT_YEAR 365

// Rotation in degrees
#define ROTATION_90_DEGREES 1.5708

// Date formats
#define DATE_FORMAT_DAILY @"dd/MM HH:mm"
#define DATE_FORMAT_WEEKLY @"dd/MM HH:mm"
#define DATE_FORMAT_MONTHLY @"dd/MM/yyyy"
#define DATE_FORMAT_YEARLY @"dd/MM/yyyy"
#define DATE_FORMAT_FOR_ANNOTATION @"dd.MM.yy HH:mm"

#define DATE_ONE_DAY (24 * 60 * 60)

#define DIVIDER_TEN_MINUTE 150
#define DIVIDER_ONE_HOUR 24
#define DIVIDER_ONE_DAY 1

#endif /* FixedValues_h */
