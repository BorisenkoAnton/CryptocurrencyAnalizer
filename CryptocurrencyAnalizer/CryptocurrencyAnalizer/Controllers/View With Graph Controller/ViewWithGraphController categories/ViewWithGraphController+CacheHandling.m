//
//  ViewWithGraphController+CacheHandling.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/23/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "ViewWithGraphController+CacheHandling.h"

@implementation ViewWithGraphController (CacheHandling)

// Trying to get data from db
- (void)getCachedDataIfExists:(NSString *)table limit:(NSString *)limit maxSeparation:(nonnull NSDateComponents *)components coinName:(NSString *)coinName completion:(void (^)(BOOL success))completion{
    
    // First, check if cache exists with needed volume of data
    SQLStatementOptions options;
    NSDictionary *whereConditions = @{DB_PAIR_NAME_COLUMN:[NSString stringWithFormat:@"%@/USD", coinName]};
    options.limit = limit;
    options.count = YES;
    options.whereConditions = [DBService createWhereConditionsFromDictionary:whereConditions];
    [DBService queryOnTable:table sqlStatementOptions:options completion:^(BOOL success, FMResultSet * _Nullable result, NSError * _Nullable error) {
        // Then, if data is cached in needed volume, checking it for updating
        if (success) {
            [CacheService checkCacheForNeedToBeUpdating:table forCoin:coinName maxSeparation:components completion:^(BOOL needsToBeUpdated) {
                if (needsToBeUpdated) {
                    completion(NO);
                } else {
                    // If cache have not to be updating, get it from db
                    NSDictionary *whereConditions = @{DB_PAIR_NAME_COLUMN:[NSString stringWithFormat:@"%@/USD", coinName]};
                    SQLStatementOptions newOptions;
                    newOptions.limit = limit;
                    newOptions.count = NO;
                    newOptions.whereConditions = [DBService createWhereConditionsFromDictionary:whereConditions];
                    [DBService queryOnTable:table sqlStatementOptions:newOptions completion:^(BOOL success, FMResultSet * _Nullable result, NSError * _Nullable error) {
                        if (success) {
                            [self.graphModel.plotDots removeAllObjects];
                            while ([result next]) {
                                [self.graphModel.plotDots addObject:[NSNumber numberWithDouble:[result doubleForColumn:DB_PRICE_COLUMN]]];
                            }
                            [self configureAndAddPlot];
                            completion(YES);
                        } else {
                            completion(NO);
                        }
                    }];
                }
            }];
        } else {
            completion(NO);
        }
    }];
             
}

- (void)loadAvailableCoins {
    
    self.availableCoins = [NSMutableArray<NSString *> new];
    self.networkService = [NetworkService shared];
    // Getting list of all available coins, unreasonable to cache it because of the max-age=120
    [self.networkService getAndParseData:nil withAPILimit:nil completion:^(NSMutableArray<DBModel *> * _Nullable coinData) {
        for (NSString *coin in coinData) {
            [self.availableCoins addObject:coin];
        }
        
        [self.availableCoins sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        self.filteredAvailableCoins = [self.availableCoins mutableCopy];
        
        
        [self.coinNamePickerView reloadAllComponents];
        [self.coinNamePickerView selectRow:0 inComponent:0 animated:NO];
        
        [self.activityIndicator stopAnimating];
    }];
    
}

@end
