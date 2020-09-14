//
//  WhereCondition.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/14/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WhereCondition : NSObject

@property NSString *column;
@property NSString *value;

- (id)initWithColumn:(NSString *)column andValue:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
