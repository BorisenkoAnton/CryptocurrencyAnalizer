//
//  ViewWithGraphController+SegmentedControl.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/23/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "ViewWithGraphController+SegmentedControl.h"

@implementation ViewWithGraphController (SegmentedControl)

- (void)configureSegmentedControl {
    
    // Adding action to perform needed manipulations with data according to selected time period
    [self.periodChoosingSegmentedControl addTarget:self action:@selector(neededPeriodSelected:) forControlEvents:UIControlEventValueChanged];
}

// All the graph classes desriptions are available at https://core-plot.github.io/iOS/annotated.html
- (void)neededPeriodSelected:(id)sender {
    
    [self.graphView addSubview:self.activityIndicator];
    
    [self.activityIndicator startAnimating];

    for (CPTScatterPlot *plot in self.graphModel.allPlots) {
        [self.graphModel removePlot:plot];
    }
    
    NSUInteger selectedRow;
    selectedRow = [self.coinNamePickerView selectedRowInComponent:0]; // A zero-indexed number identifying the selected row, or -1 if no row is selected
    if (selectedRow == -1) {
        [self.coinNamePickerView selectRow:0 inComponent:0 animated:NO];
        selectedRow = [self.coinNamePickerView selectedRowInComponent:0];
    }
    NSString *coinName = [[self.coinNamePickerView delegate] pickerView:self.coinNamePickerView titleForRow:selectedRow forComponent:0];
    
    // There are four segments, based on the selected we need to get data with different limit (different number of data units)
    switch (self.periodChoosingSegmentedControl.selectedSegmentIndex) {
        case 0: {
            // This components play role of the maximum separatiion between current time and the latest time of the cache
            NSDateComponents *components = [[NSDateComponents alloc] init];
            [components setMinute:10];
            
            [self getCachedDataIfExists:DB_MINUTELY_TABLE limit:DB_LIMIT_FOR_MINUTELY_TABLE maxSeparation:components coinName:coinName completion:^(BOOL success) {
                if (!success) {
                        [self.networkService getMinutelyHistoricalDataForCoin:coinName withLimit:API_LIMIT_FOR_MINUTELY_HISTORY completion:^(NSMutableArray<DBModel *> * _Nullable coinData) {
                        [self.graphModel.plotDots removeAllObjects];
                        for (DBModel *model in coinData) {
                            [self.graphModel.plotDots addObject:model.price];
                        }
                        [self configureAndAddPlot];
                        [self.activityIndicator stopAnimating];
                            
                        [CacheService clearCacheInTable:DB_MINUTELY_TABLE forCoin:coinName completion:^(BOOL success) {
                            if (success) {
                                [CacheService cacheArrayOfObjects:coinData toTable:DB_MINUTELY_TABLE];
                            }
                        }];
                            
                    }];
                } else {
                    [self.activityIndicator stopAnimating];
                }
            }];
            break;
        }
            
        case 1: {
            NSDateComponents *components = [[NSDateComponents alloc] init];
            [components setHour:1];
            [self getCachedDataIfExists:DB_HOURLY_TABLE limit:DB_LIMIT_FOR_HOURLY_TABLE maxSeparation:components coinName:coinName completion:^(BOOL success) {
                if (!success) {
                        [self.networkService getHourlyHistoricalDataForCoin:coinName withLimit:API_LIMIT_FOR_HOURLY_HISTORY completion:^(NSMutableArray<DBModel *> * _Nullable coinData) {
                        [self.graphModel.plotDots removeAllObjects];
                        for (DBModel *model in coinData) {
                            [self.graphModel.plotDots addObject:model.price];
                        }
                        [self configureAndAddPlot];
                        [self.activityIndicator stopAnimating];
                            
                        [CacheService clearCacheInTable:DB_HOURLY_TABLE forCoin:coinName completion:^(BOOL success) {
                            if (success) {
                                [CacheService cacheArrayOfObjects:coinData toTable:DB_HOURLY_TABLE];
                            }
                        }];

                    }];
                } else {
                    [self.activityIndicator stopAnimating];
                }
            }];
            break;
        }
            
        case 2: {
            NSDateComponents *components = [[NSDateComponents alloc] init];
            [components setDay:1];
            [self getCachedDataIfExists:DB_DAILY_TABLE limit:DB_LIMIT_FOR_DAILY_TABLE_M maxSeparation:components coinName:coinName completion:^(BOOL success) {
                if (!success) {
                        [self.networkService getDailyHistoricalDataForCoin:coinName withLimit:API_LIMIT_FOR_DAILY_HISTORY_M completion:^(NSMutableArray<DBModel *> * _Nullable coinData) {
                        [self.graphModel.plotDots removeAllObjects];
                        for (DBModel *model in coinData) {
                            [self.graphModel.plotDots addObject:model.price];
                        }
                        [self configureAndAddPlot];
                        [self.activityIndicator stopAnimating];
                            
                        [CacheService clearCacheInTable:DB_DAILY_TABLE forCoin:coinName completion:^(BOOL success) {
                            if (success) {
                                [CacheService cacheArrayOfObjects:coinData toTable:DB_DAILY_TABLE];
                            }
                        }];

                    }];
                } else {
                    [self.activityIndicator stopAnimating];
                }
            }];
            break;
        }
        
        case 3: {
            NSDateComponents *components = [[NSDateComponents alloc] init];
            [components setDay:1];
            [self getCachedDataIfExists:DB_DAILY_TABLE limit:DB_LIMIT_FOR_DAILY_TABLE_Y maxSeparation:components coinName:coinName completion:^(BOOL success) {
                if (!success) {
                    [self.networkService getDailyHistoricalDataForCoin:coinName withLimit:API_LIMIT_FOR_DAILY_HISTORY_Y completion:^(NSMutableArray<DBModel *> * _Nullable coinData) {
                        [self.graphModel.plotDots removeAllObjects];
                        for (DBModel *model in coinData) {
                            [self.graphModel.plotDots addObject:model.price];
                        }
                        [self configureAndAddPlot];
                        [self.activityIndicator stopAnimating];
                        
                        [CacheService clearCacheInTable:DB_DAILY_TABLE forCoin:coinName completion:^(BOOL success) {
                            if (success) {
                                [CacheService cacheArrayOfObjects:coinData toTable:DB_DAILY_TABLE];
                            }
                        }];

                    }];
                } else {
                    [self.activityIndicator stopAnimating];
                }
            }];
            break;
        }
            
        default:
            break;
    }
}

@end
