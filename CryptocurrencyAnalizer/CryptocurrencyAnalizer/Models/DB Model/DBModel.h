//
//  DBModel.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/15/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBModel : NSObject

@property  NSNumber * _Nullable ID;
@property NSString *pairName;
@property NSDate *timestamp;
@property NSNumber *price;

- (id)initWithPairName:(NSString *)pairName timeStamp:(NSDate *)timestamp andPrice:(NSNumber *)price;

@end

NS_ASSUME_NONNULL_END
