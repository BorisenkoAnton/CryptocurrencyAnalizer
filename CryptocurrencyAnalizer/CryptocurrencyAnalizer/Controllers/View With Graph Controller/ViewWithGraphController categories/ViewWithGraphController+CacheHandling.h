//
//  ViewWithGraphController+CacheHandling.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/23/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "ViewWithGraphController.h"
#import "ViewWithGraphController+CPTPlot.h"

// Helpers
#import "SQLStatementOptions.h"
#import "FixedValues.h"

// Services
#import "DBService.h"
#import "CacheService.h"



NS_ASSUME_NONNULL_BEGIN

@interface ViewWithGraphController (CacheHandling)

- (void)getCachedDataIfExists:(NSString *)table
                        limit:(NSString *)limit
                        maxSeparation:(nonnull NSDateComponents *)components
                        coinName:(NSString *)coinName
                        completion:(void (^)(BOOL success))completion;

- (void)loadAvailableCoins;

@end

NS_ASSUME_NONNULL_END
