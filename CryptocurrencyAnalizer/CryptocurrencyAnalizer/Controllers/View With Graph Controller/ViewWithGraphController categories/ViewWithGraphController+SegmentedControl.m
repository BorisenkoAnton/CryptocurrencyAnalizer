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
    
    // move to .h {
    
    // This components play role of the maximum separatiion between current time and the latest time of the cache
    NSDateComponents *components = [[NSDateComponents alloc] init];
    // }
    
    // There are four segments, based on the selected we need to get data with different limit (different number of data units)
    switch (self.periodChoosingSegmentedControl.selectedSegmentIndex) {
        case 0: {
            [components setMinute:10];
            self.table = DB_MINUTELY_TABLE;
            self.dbLimit = DB_LIMIT_FOR_MINUTELY_TABLE;
            self.apiLimit = API_LIMIT_FOR_MINUTELY_HISTORY;
            break;
        }
            
        case 1: {
            [components setHour:1];
            self.table = DB_HOURLY_TABLE;
            self.dbLimit = DB_LIMIT_FOR_HOURLY_TABLE;
            self.apiLimit = API_LIMIT_FOR_HOURLY_HISTORY;
            break;
        }
            
        case 2: {
            [components setDay:1];
            self.table = DB_DAILY_TABLE;
            self.dbLimit = DB_LIMIT_FOR_DAILY_TABLE_M;
            self.apiLimit = API_LIMIT_FOR_DAILY_HISTORY_M;
            break;
        }
        
        case 3: {
            [components setDay:1];
            self.table = DB_DAILY_TABLE;
            self.dbLimit = DB_LIMIT_FOR_DAILY_TABLE_Y;
            self.apiLimit = API_LIMIT_FOR_DAILY_HISTORY_Y;
            break;
        }
            
        default:
            break;
    }
    
    [self getCachedDataIfExists:self.table limit:self.dbLimit maxSeparation:components coinName:coinName completion:^(BOOL success) {
        if (!success) {
            NSLog(@"wasnt cached");
//            NSLog(table);
//            NSLog(dbLimit);
//            NSLog([apiLimit stringValue]);
            [self.networkService getDailyHistoricalDataForCoin:coinName withLimit:self.apiLimit completion:^(NSMutableArray<DBModel *> * _Nullable coinData) {
                [self.graphModel.plotDots removeAllObjects];
                for (DBModel *model in coinData) {
                    [self.graphModel.plotDots addObject:model.price];
                }
                [self configureAndAddPlot];
                [self.activityIndicator stopAnimating];
                
//                NSNumber *count = [NSNumber numberWithUnsignedInteger:self.graphModel.plotDots.count];
//                NSLog([count stringValue]);
                
                [CacheService clearCacheInTable:self.table forCoin:coinName completion:^(BOOL success) {
                    if (success) {
                        NSNumber *count = [NSNumber numberWithUnsignedInteger:self.graphModel.plotDots.count];
                        NSLog([count stringValue]);
                        [CacheService cacheArrayOfObjects:coinData toTable:self.table];
                    }
                }];

            }];
        } else {
            [self.activityIndicator stopAnimating];
        }
    }];
}

@end
