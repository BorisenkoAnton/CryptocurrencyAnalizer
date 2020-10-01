//
//  WhereCondition.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/14/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "WhereCondition.h"

@implementation WhereCondition

- (id)initWithColumn:(NSString *)column andValue:(NSString *)value {
    
    if (self = [super init]) {
        self.value = value;
        self.column = column;
    }
    
    return self;
}

@end
