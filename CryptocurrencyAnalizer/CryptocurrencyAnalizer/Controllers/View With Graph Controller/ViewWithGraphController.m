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
#import "FixedValues.h"

@interface ViewWithGraphController ()

@property NetworkService * networkService;
@property NSMutableArray<NSString *> *availableCoins;           // Full list of available coins
@property NSMutableArray<NSString *> *filteredAvailableCoins;   // List of available coins after searching with the help of text Field
@property (weak, nonatomic) IBOutlet UISegmentedControl *periodChoosingSegmentedControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


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
    NSDictionary *columns = @{DB_PAIR_NAME_COLUMN:DB_TEXT_TYPE, DB_PRICE_COLUMN:DB_REAL_TYPE, DB_TIMESTAMP_COLUMN:DB_INTEGER_TYPE};
    NSArray<TableColumn *> *columnsForTablesWithPrices = [DBService createTableColumnsFromDictionary:columns];
    [DBService createTable:DB_MINUTELY_TABLE withColumns:columnsForTablesWithPrices completion:nil];
    [DBService createTable:DB_HOURLY_TABLE withColumns:columnsForTablesWithPrices completion:nil];
    [DBService createTable:DB_DAILY_TABLE withColumns:columnsForTablesWithPrices completion:nil];
    
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
    
    GraphOptions options;
    options.frame = self.graphView.frame;
    options.color = [UIColor blackColor].CGColor;
    options.paddingBottom = 40.0;
    options.paddingLeft = 65.0;
    options.paddingTop = 30.0;
    options.paddingRight = 15.0;
    self.graphModel = [[GraphModel alloc] initModelWithOptions:options];
    
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
        
        [self.activityIndicator stopAnimating];
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
    
    // First, check if cache exists with needed volume of data
    SQLStatementOptions options;
    NSDictionary *whereConditions = @{DB_PAIR_NAME_COLUMN:[NSString stringWithFormat:@"%@/USD", coinName]};
    options.limit = limit;
    options.count = YES;
    options.whereConditions = [DBService createWhereConditionsFromDictionary:whereConditions];
    [DBService queryOnTable:table sqlStatementOptions:options completion:^(BOOL success, FMResultSet * _Nullable result, NSError * _Nullable error) {
        if (success) {
            [CacheService checkCacheForNeedToBeUpdating:table forCoin:coinName maxSeparation:components completion:^(BOOL needsToBeUpdated) {
                if (needsToBeUpdated) {
                    completion(NO);
                } else {
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


#pragma mark - actions to manipulate data and building plots

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


- (void)configureAndAddPlot{
    
    self.graphView.hostedGraph = self.graphModel;

    NSNumber *maxYValue = [NSNumber numberWithDouble:[(NSNumber *)[self.graphModel.plotDots valueForKeyPath:@"@max.self"] doubleValue] * 1.3];
    NSNumber *maxXValue = [NSNumber numberWithUnsignedInteger:self.graphModel.plotDots.count];
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graphModel.defaultPlotSpace;
    [GraphService configurePlotSpace:plotSpace forPlotwithMaxXValue:maxXValue andMaxYValue:maxYValue];

    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graphModel.axisSet;
    AxisSetOptions options;
    options.labelTextStyle = self.graphModel.textStyles[0];
    options.gridLineStyle = self.graphModel.gridLineStyles[0];
    options.axisLineStyle = self.graphModel.lineStyles[0];
    options.xAxisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    options.yAxisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    options.xAxisDelegate = self;
    options.yAxisDelegate = self;
    options.maxXValue = maxXValue;
    options.maxYValue = maxYValue;
    
    // Depending on the selected time period, we will get different number of dots
    switch (self.graphModel.plotDots.count) {
        // For one day history
        case PLOT_DOTS_COUNT_DAY: {
            options.numberOfXMajorIntervals = 6;
            options.numberOfXMinorTicksPerInterval = 3;
            options.labelRotation = ROTATION_0_DEGREES;
            break;
        }
        // For 7 days history
        case PLOT_DOTS_COUNT_WEEK: {
            options.numberOfXMajorIntervals = 7;
            options.numberOfXMinorTicksPerInterval = 1;
            options.labelRotation = ROTATION_0_DEGREES;
            break;
        }
        // For month history
        case PLOT_DOTS_COUNT_MONTH: {
            options.numberOfXMajorIntervals = 30;
            options.numberOfXMinorTicksPerInterval = 1;
            options.labelRotation = ROTATION_90_DEGREES; // We need to rotate labels on x axis, to see them all
            break;
        }
            
        // For one year history
        case PLOT_DOTS_COUNT_YEAR: {
            options.numberOfXMajorIntervals = 12;
            options.numberOfXMinorTicksPerInterval = 3;
            options.labelRotation = ROTATION_90_DEGREES;
            break;
        }
        default:
            break;
    }

    [GraphService configureAxisSet:&axisSet withOptions:options];
    
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
