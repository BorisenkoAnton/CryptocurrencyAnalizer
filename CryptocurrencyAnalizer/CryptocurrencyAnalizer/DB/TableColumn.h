//
//  TableColumn.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/14/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Model of DB table column
@interface TableColumn : NSObject

@property NSString *name;
@property NSString *type;

- (id)initWithName:(NSString *)name andType:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
