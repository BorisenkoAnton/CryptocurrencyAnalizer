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
    
    [self.graphView.hostedGraph.plotAreaFrame.plotArea removeAllAnnotations];
    
    // Removing previous plot on graph
    for (CPTScatterPlot *plot in self->graph.allPlots) {
        [self->graph removePlot:plot];
    }
    
    NSUInteger selectedRow;
    
    selectedRow = [self.coinNamePickerView selectedRowInComponent:0]; // A zero-indexed number identifying the selected row, or -1 if no row is selected
    
    if (selectedRow == -1) {
        [self.coinNamePickerView selectRow:0 inComponent:0 animated:NO];
        
        selectedRow = [self.coinNamePickerView selectedRowInComponent:0];
    }
    
    NSString *coinName = [[self.coinNamePickerView delegate] pickerView:self.coinNamePickerView titleForRow:selectedRow forComponent:0];
    
    // This components play role of the maximum separatiion between current time and the latest time of the cache
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    // There are four segments, based on the selected we need to get data with different limit (different number of data units)
    switch (self.periodChoosingSegmentedControl.selectedSegmentIndex) {
        case 0: {
            [components setMinute:10];
            [self configureLimitsForTable:DB_MINUTELY_TABLE dbLimit:DB_LIMIT_FOR_MINUTELY_TABLE apiLimit:API_LIMIT_FOR_MINUTELY_HISTORY];
            break;
        }
            
        case 1: {
            [components setHour:1];
            [self configureLimitsForTable:DB_HOURLY_TABLE dbLimit:DB_LIMIT_FOR_HOURLY_TABLE apiLimit:API_LIMIT_FOR_HOURLY_HISTORY];
            break;
        }
            
        case 2: {
            [components setDay:1];
            [self configureLimitsForTable:DB_DAILY_TABLE dbLimit:DB_LIMIT_FOR_DAILY_TABLE_M apiLimit:API_LIMIT_FOR_DAILY_HISTORY_M];
            break;
        }
        
        case 3: {
            [components setDay:1];
            [self configureLimitsForTable:DB_DAILY_TABLE dbLimit:DB_LIMIT_FOR_DAILY_TABLE_Y apiLimit:API_LIMIT_FOR_DAILY_HISTORY_Y];
            break;
        }
            
        default:
            break;
    }
    
    [CacheManager getCachedDataIfExists:self->table limit:self->dbLimit maxSeparation:components coinName:coinName completion:^(BOOL success, NSMutableArray<DBModel *> *cachedData) {
        if (!success) {
            [self->networkService getAndParseData:coinName withAPILimit:self->apiLimit completion:^(NSMutableArray<DBModel *> * _Nullable coinData) {
                [self->graph.plotDots removeAllObjects];
                
                for (DBModel *model in coinData) {
                   [self->graph.plotDots addObject:model];
                }
                
                [self configureAndAddPlot];
                
                [self.activityIndicator stopAnimating];

                [CacheManager clearCacheInTable:self->table forCoin:coinName completion:^(BOOL success) {
                   if (success) {
                       [CacheManager cacheArrayOfObjects:coinData toTable:self->table];
                   }
                }];
            }];
            
        } else {
            [self->graph.plotDots removeAllObjects];
            self->graph.plotDots = cachedData;
            
            [self configureAndAddPlot];
            
            [self.activityIndicator stopAnimating];
        }
    }];
}

// Configuring parameters for getting data from db or from server
- (void)configureLimitsForTable:(NSString *)table dbLimit:(NSString *)dbLimit apiLimit:(NSNumber *)apiLimit {
    
    self->table = table;
    self->dbLimit = dbLimit;
    self->apiLimit = apiLimit;
}

@end
