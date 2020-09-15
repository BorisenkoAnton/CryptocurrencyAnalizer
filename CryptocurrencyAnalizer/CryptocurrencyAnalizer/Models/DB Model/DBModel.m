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

@end
