//
//  SQLStatementOptions.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/22/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "WhereCondition.h"

#ifndef SQLStatement_h
#define SQLStatement_h

typedef struct {
    NSArray<WhereCondition *> * _Nullable whereConditions;
    BOOL count;
    NSString * _Nullable orderBy;
    BOOL desc;
    NSString * _Nullable limit;
} SQLStatementOptions;

#endif /* SQLStatement_h */
