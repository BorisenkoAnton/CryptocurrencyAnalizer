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

@interface ViewWithGraphController ()

@property NetworkService * networkService;
@property NSMutableArray<NSString *> *availableCoins;
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
    
    // Adding action to perform needed manipulations with data according to selected time period
    [self.periodChoosingSegmentedControl addTarget:self action:@selector(neededPeriodSelected:) forControlEvents:UIControlEventValueChanged];
    self.coinNamePickerView.delegate = self;
    self.coinNamePickerView.dataSource = self;
    self.coinNameTextField.delegate = self;
    
    self.graphModel = [[GraphModel alloc] initModelWithFrame:self.graphView.frame
                                             backgroundColor:[UIColor blackColor].CGColor
                                               bottomPadding:40.0
                                                 leftPadding:65.0
                                                  topPadding:30.0
                                             andRightPadding:15.0];
    
    self.availableCoins = [NSMutableArray<NSString *> new];
    
    self.graphModel.textStyles[0] = [GraphService createMutableTextStyleWithFontName:@"HelveticaNeue-Bold" fontSize:10.0 color:[CPTColor whiteColor] andTextAlignment:CPTTextAlignmentCenter];
    self.graphModel.lineStyles[0] = [GraphService createLineStyleWithWidth:5.0 andColor:[CPTColor whiteColor]];
    self.graphModel.gridLineStyles[0] = [GraphService createLineStyleWithWidth:0.5 andColor:[CPTColor grayColor]];
    
    self.networkService = [NetworkService shared];
    // Getting list of all available coins, in future it will be cached
    [self.networkService getAvailableCoins:^(NSArray * _Nonnull availableCoins) {
        
        for (NSString *coin in availableCoins) {
            [self.availableCoins addObject:coin];
        }
        [self.availableCoins sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [self.coinNamePickerView reloadAllComponents];
    }];
}

#pragma mark - Picker View Delegate and Picker View Data Source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.availableCoins.count;
}
// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
     return self.availableCoins[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.coinNameTextField.text = self.availableCoins[row];
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

#pragma mark - actions to manipulate data
// All the classes desriptions are available at https://core-plot.github.io/iOS/annotated.html
- (void)neededPeriodSelected:(id)sender {
    
    for (CPTScatterPlot *plot in self.graphModel.allPlots) {
        [self.graphModel removePlot:plot];
    }
    
    // Checking if the needed coin is in the list of available coins
    if ([self.availableCoins containsObject:self.coinNameTextField.text]) {
        // There are four segments, based on the selected we need to get data with different limit (different number of data units)
        switch (self.periodChoosingSegmentedControl.selectedSegmentIndex) {
            case 0: {
                [self.networkService getMinutelyHistoricalDataForCoin:self.coinNameTextField.text withLimit:@1439 completion:^(NSMutableArray<NSNumber *> * _Nullable coinData) {
                    self.graphModel.plotDots = coinData;
                    [self configureAndAddPlot];
                }];
                break;
            }
                
            case 1: {
                [self.networkService getHourlyHistoricalDataForCoin:self.coinNameTextField.text withLimit:@167 completion:^(NSMutableArray<NSNumber *> * _Nullable coinData) {
                    self.graphModel.plotDots = coinData;
                    [self configureAndAddPlot];
                }];
                break;
            }
                
            case 2: {
                [self.networkService getDailyHistoricalDataForCoin:self.coinNameTextField.text withLimit:@29 completion:^(NSMutableArray<NSNumber *> * _Nullable coinData) {
                    self.graphModel.plotDots = coinData;
                    [self configureAndAddPlot];
                }];
                break;
            }
                
            case 3: {
                [self.networkService getDailyHistoricalDataForCoin:self.coinNameTextField.text withLimit:@364 completion:^(NSMutableArray<NSNumber *> * _Nullable coinData) {
                    self.graphModel.plotDots = coinData;
                    [self configureAndAddPlot];
                }];
                break;
            }
                
            default:
                break;
        }
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

@end