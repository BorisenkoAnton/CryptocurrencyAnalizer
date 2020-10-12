//
//  GraphFixedValues.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 10/12/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#ifndef GraphFixedValues_h
#define GraphFixedValues_h

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

// Dividers (for confiduring graph)
#define DIVIDER_TEN_MINUTE 150
#define DIVIDER_ONE_HOUR 24
#define DIVIDER_ONE_DAY 1

#endif /* GraphFixedValues_h */
