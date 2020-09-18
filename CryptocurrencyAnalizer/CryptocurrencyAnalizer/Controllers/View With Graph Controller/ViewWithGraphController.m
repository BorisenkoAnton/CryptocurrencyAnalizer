//
//  ViewWithGraphController.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/13/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "ViewWithGraphController.h"
#import "CorePlot-CocoaTouch.h"
#import "GraphModel.h"
#import "NetworkService.h"
#import "GraphService.h"
#import "DBService.h"
#import "TableColumn.h"
#import "DBModel.h"
#import "CacheService.h"

@interface ViewWithGraphController ()

@property NetworkService * networkService;
@property NSMutableArray<NSString *> *availableCoins;           // Full list of available coins
@property NSMutableArray<NSString *> *filteredAvailableCoins;   // List of available coins after searching with the help of text Field
@property (weak, nonatomic) IBOutlet UISegmentedControl *periodChoosingSegmentedControl;

@end

@interface ViewWithGraphController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *coinNamePickerView;

@end

@interface ViewWithGraphController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *coinNameTextField;

@end

@interface ViewWithGraphController () <CPTPlotDataSource, CPTPlotDelegate, CALayerDelegate>

@property (strong) GraphModel *graphModel;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *graphView;


@end

@implementation ViewWithGraphController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Creating all needed for caching tables if they are not exist
    NSMutableArray<TableColumn *> *columnsForTablesWithPrices = [NSMutableArray<TableColumn *> arrayWithObjects:
                                              [[TableColumn alloc] initWithName:@"pairName" andType:@"TEXT"],
                                              [[TableColumn alloc] initWithName:@"price" andType:@"REAL"],
                                              [[TableColumn alloc] initWithName:@"timestamp" andType:@"INTEGER"],
                                              nil];
    [DBService createTable:@"minutelyHistoricalData" withColumns:columnsForTablesWithPrices completion:nil];
    [DBService createTable:@"hourlyHistoricalData" withColumns:columnsForTablesWithPrices completion:nil];
    [DBService createTable:@"dailyHistoricalData" withColumns:columnsForTablesWithPrices completion:nil];
    
    // Adding action to perform needed manipulations with data according to selected time period
    [self.periodChoosingSegmentedControl addTarget:self action:@selector(neededPeriodSelected:) forControlEvents:UIControlEventValueChanged];

    // To hide keyboard when user tapped on the screen (outside keyboard)
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    // Adding controller as observer to notifications, to know when keyboard appears and dissapears (to manage UI elements size)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.coinNamePickerView.delegate = self;
    self.coinNamePickerView.dataSource = self;
    self.coinNameTextField.delegate = self;
    
    self.graphModel = [[GraphModel alloc] initModelWithFrame:self.graphView.frame
                                             backgroundColor:[UIColor blackColor].CGColor
                                               bottomPadding:40.0
                                                 leftPadding:65.0
                                                  topPadding:30.0
                                             andRightPadding:15.0];
    
    self.graphModel.textStyles[0] = [GraphService createMutableTextStyleWithFontName:@"HelveticaNeue-Bold" fontSize:10.0 color:[CPTColor whiteColor] andTextAlignment:CPTTextAlignmentCenter];
    self.graphModel.lineStyles[0] = [GraphService createLineStyleWithWidth:5.0 andColor:[CPTColor whiteColor]];
    self.graphModel.gridLineStyles[0] = [GraphService createLineStyleWithWidth:0.5 andColor:[CPTColor grayColor]];
    
    self.availableCoins = [NSMutableArray<NSString *> new];
    self.networkService = [NetworkService shared];
    // Getting list of all available coins, unreasonable to cache it because of the max-age=120
    [self.networkService getAvailableCoins:^(NSArray * _Nonnull availableCoins) {
        
        for (NSString *coin in availableCoins) {
            [self.availableCoins addObject:coin];
        }
        [self.availableCoins sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        self.filteredAvailableCoins = [self.availableCoins mutableCopy];
        [self.coinNameTextField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
        
        [self.coinNamePickerView reloadAllComponents];
        [self.coinNamePickerView selectRow:0 inComponent:0 animated:NO];
    }];
}

#pragma mark - Picker View Delegate and Picker View Data Source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.filteredAvailableCoins.count;
}
// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
     return self.filteredAvailableCoins[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.coinNameTextField.text = self.filteredAvailableCoins[row];
}

#pragma mark - Text Field Delegate

// This method enables or disables the processing of return key
-(BOOL) textFieldShouldReturn:(UITextField *)textField {
   [textField resignFirstResponder];
   return YES;
}

#pragma mark - CPTPlotDataSource

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords {
    return self.graphModel.plotDots.count;
}
 
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{

    if(fieldEnum == CPTScatterPlotFieldX)
    {
        return [NSNumber numberWithUnsignedInteger:index];
    } else {
        return self.graphModel.plotDots[self.graphModel.plotDots.count - 1 - index];
    }
}

#pragma mark - Cache handling
- (void)getCachedDataIfExists:(NSString *)table limit:(NSString *)limit maxSeparation:(nonnull NSDateComponents *)components coinName:(NSString *)coinName completion:(void (^)(BOOL success))completion{
    
    WhereCondition *condition = [[WhereCondition alloc] initWithColumn:@"pairName" andValue:[NSString stringWithFormat:@"%@/USD", coinName]];
    [DBService countQueryOnTable:table whereConditions:condition limit:limit completion:^(BOOL success, NSError * _Nullable error) {

        if (success) {
            
            WhereCondition *condition = [[WhereCondition alloc] initWithColumn:@"pairName" andValue:[NSString stringWithFormat:@"%@/USD", coinName]];
            [CacheService checkCacheForNeedToBeUpdating:table whereConditions:[NSArray<WhereCondition *> arrayWithObject:condition] maxSeparation:components completion:^(BOOL needsToBeUpdated) {
                if (needsToBeUpdated) {
                    completion(NO);
                } else {
                    [DBService queryOnTable:table whereConditions:[NSArray<WhereCondition *> arrayWithObject:condition] limit:limit completion:^(BOOL success, FMResultSet * _Nullable result, NSError * _Nullable error) {
                                       if (success) {
                                           [self.graphModel.plotDots removeAllObjects];
                                           while ([result next]) {
                                               [self.graphModel.plotDots addObject:[NSNumber numberWithDouble:[result doubleForColumn:@"price"]]];
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



#pragma mark - actions to manipulate data and building plots

// All the graph classes desriptions are available at https://core-plot.github.io/iOS/annotated.html
- (void)neededPeriodSelected:(id)sender {
    
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
            
            [self getCachedDataIfExists:@"minutelyHistoricalData" limit:@"144" maxSeparation:components coinName:coinName completion:^(BOOL success) {
                if (!success) {
                        [self.networkService getMinutelyHistoricalDataForCoin:coinName withLimit:@1439 completion:^(NSMutableArray<DBModel *> * _Nullable coinData) {
                        [self.graphModel.plotDots removeAllObjects];
                        for (DBModel *model in coinData) {
                            [self.graphModel.plotDots addObject:model.price];
                        }
                        [self configureAndAddPlot];

                        [CacheService clearCacheInTable:@"minutelyHistoricalData" forCoin:coinName completion:^(BOOL success) {
                            if (success) {
                                [CacheService cacheArrayOfObjects:coinData toTable:@"minutelyHistoricalData"];
                            }
                        }];

                    }];
                }
            }];
            break;
        }
            
        case 1: {
            NSDateComponents *components = [[NSDateComponents alloc] init];
            [components setHour:1];
            [self getCachedDataIfExists:@"hourlyHistoricalData" limit:@"168" maxSeparation:components coinName:coinName completion:^(BOOL success) {
                if (!success) {
                        [self.networkService getHourlyHistoricalDataForCoin:coinName withLimit:@167 completion:^(NSMutableArray<DBModel *> * _Nullable coinData) {
                        [self.graphModel.plotDots removeAllObjects];
                        for (DBModel *model in coinData) {
                            [self.graphModel.plotDots addObject:model.price];
                        }
                        [self configureAndAddPlot];
                        
                        [CacheService clearCacheInTable:@"hourlyHistoricalData" forCoin:coinName completion:^(BOOL success) {
                            if (success) {
                                [CacheService cacheArrayOfObjects:coinData toTable:@"hourlyHistoricalData"];
                            }
                        }];

                    }];
                }
            }];
            break;
        }
            
        case 2: {
            NSDateComponents *components = [[NSDateComponents alloc] init];
            [components setDay:1];
            [self getCachedDataIfExists:@"dailyHistoricalData" limit:@"30" maxSeparation:components coinName:coinName completion:^(BOOL success) {
                if (!success) {
                        [self.networkService getDailyHistoricalDataForCoin:coinName withLimit:@29 completion:^(NSMutableArray<DBModel *> * _Nullable coinData) {
                        [self.graphModel.plotDots removeAllObjects];
                        for (DBModel *model in coinData) {
                            [self.graphModel.plotDots addObject:model.price];
                        }
                        [self configureAndAddPlot];
                        
                        [CacheService clearCacheInTable:@"dailyHistoricalData" forCoin:coinName completion:^(BOOL success) {
                            if (success) {
                                [CacheService cacheArrayOfObjects:coinData toTable:@"dailyHistoricalData"];
                            }
                        }];

                    }];
                }
            }];
            break;
        }
        
        case 3: {
            NSDateComponents *components = [[NSDateComponents alloc] init];
            [components setDay:1];
            [self getCachedDataIfExists:@"dailyHistoricalData" limit:@"365" maxSeparation:components coinName:coinName completion:^(BOOL success) {
                if (!success) {
                    [self.networkService getDailyHistoricalDataForCoin:coinName withLimit:@364 completion:^(NSMutableArray<DBModel *> * _Nullable coinData) {
                        [self.graphModel.plotDots removeAllObjects];
                        for (DBModel *model in coinData) {
                            [self.graphModel.plotDots addObject:model.price];
                        }
                        [self configureAndAddPlot];
                        
                        [CacheService clearCacheInTable:@"dailyHistoricalData" forCoin:coinName completion:^(BOOL success) {
                            if (success) {
                                [CacheService cacheArrayOfObjects:coinData toTable:@"dailyHistoricalData"];
                            }
                        }];

                    }];
                }
            }];
            break;
        }
            
        default:
            break;
    }
}


- (void)configureAndAddPlot{
    
    self.graphView.hostedGraph = self.graphModel;

    NSNumber *maxYValue = [NSNumber numberWithDouble:[(NSNumber *)[self.graphModel.plotDots valueForKeyPath:@"@max.self"] doubleValue] * 1.3];
    NSNumber *maxXValue = [NSNumber numberWithUnsignedInteger:self.graphModel.plotDots.count];
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graphModel.defaultPlotSpace;
    [GraphService configurePlotSpace:plotSpace forPlotwithMaxXValue:maxXValue andMaxYValue:maxYValue];

    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graphModel.axisSet;
    
    [GraphService configureAxisSet:&axisSet withLabelTextStyle:self.graphModel.textStyles[0] minorGridLineStyle:self.graphModel.gridLineStyles[0] axisLineStyle:self.graphModel.lineStyles[0] xAxisConstraints:[CPTConstraints constraintWithLowerOffset:0.0] yAxisConstraints:[CPTConstraints constraintWithLowerOffset:0.0] xAxisDelegate:self andYAxisDelegate:self];

    // Depending on the selected time period, we will get different number of dots
    switch (self.graphModel.plotDots.count) {
        // For one day history
        case 144: {
            [GraphService configureAxisSet:&axisSet withMaxXvalue:maxXValue maxYvalue:maxYValue numberOfXMajorIntervals:6 andNumberOfXMinorTicksPerInterval:3];
            ((CPTXYAxisSet *)self.graphModel.axisSet).xAxis.labelRotation = 0.0;
            break;
        }
        // For 7 days history
        case 168: {
            [GraphService configureAxisSet:&axisSet withMaxXvalue:maxXValue maxYvalue:maxYValue numberOfXMajorIntervals:7 andNumberOfXMinorTicksPerInterval:1];
            ((CPTXYAxisSet *)self.graphModel.axisSet).xAxis.labelRotation = 0.0;
            break;
        }
        // For month history
        case 30: {
            [GraphService configureAxisSet:&axisSet withMaxXvalue:maxXValue maxYvalue:maxYValue numberOfXMajorIntervals:30 andNumberOfXMinorTicksPerInterval:1];
            // We need to rotate labels on x axis, to see them all
            ((CPTXYAxisSet *)self.graphModel.axisSet).xAxis.labelRotation = 1.5708;
            break;
        }
            
        // For one year history
        case 365: {
            [GraphService configureAxisSet:&axisSet withMaxXvalue:maxXValue maxYvalue:maxYValue numberOfXMajorIntervals:12 andNumberOfXMinorTicksPerInterval:3];
            ((CPTXYAxisSet *)self.graphModel.axisSet).xAxis.labelRotation = 1.5708;
            break;
        }
        default:
            break;
    }

    CPTScatterPlot* plot = [GraphService createScatterPlotWithLineWidth:2.0 lineColor:[CPTColor whiteColor] dataSource:self andDelegate:self];

    [self.graphModel addPlot:plot toPlotSpace:self.graphModel.defaultPlotSpace];
}

#pragma mark - Configuring view size when keyboard appears

- (void) keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    CGSize keyboardSize = keyboardFrameBeginRect.size;
    
    if (self.view.frame.origin.y == 0) {
        CGRect frame = self.view.frame;
        frame.origin.y -= keyboardSize.height;
        self.view.frame = frame;
    }
    
}

- (void) keyboardWillHide:(NSNotification *)notification {
    
    if (self.view.frame.origin.y != 0) {
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        self.view.frame = frame;
    }
}

#pragma mark - Gesture Recognizers

- (void)dismissKeyboard {
    [self.coinNameTextField resignFirstResponder];
}

#pragma mark - Searching in Picker View when Text Field change value

-(void)textFieldValueChanged:(UITextField *)textField {
    
    if((textField.text.length) > 0) {
        self.filteredAvailableCoins = [self searchInArray:self.availableCoins withKey:@"key value" andCharacters:textField.text];
    }
    else {
        self.filteredAvailableCoins = [self.availableCoins mutableCopy];
    }

    [self.coinNamePickerView reloadAllComponents];

}

-(NSMutableArray *)searchInArray:(NSMutableArray<NSString *> *)arrayToSearchInto withKey:(NSString *)key andCharacters:(NSString *)charecters {

    NSMutableArray *resultArray= [NSMutableArray new];
    for (int index = 0 ; index < arrayToSearchInto.count; index++) {
        NSString *coinName  = arrayToSearchInto[index];
        if ([coinName localizedCaseInsensitiveContainsString:charecters]) {
            [resultArray addObject:coinName];
        }

    }

    return resultArray;

}

@end
