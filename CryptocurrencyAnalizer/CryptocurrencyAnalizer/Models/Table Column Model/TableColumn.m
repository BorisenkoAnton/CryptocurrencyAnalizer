//
//  TableColumn.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/14/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "TableColumn.h"

@implementation TableColumn

- (id)initWithName:(NSString *)name andType:(NSString *)type {
    
    if (self = [super init]) {
        self.name = name;
        self.type = type;
    }
    return self;
}

@end
