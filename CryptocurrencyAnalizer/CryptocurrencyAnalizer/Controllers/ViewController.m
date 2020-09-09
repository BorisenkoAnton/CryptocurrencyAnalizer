//
//  ViewController.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/7/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "ViewController.h"
#import "NetworkService.h"
#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface ViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property NSMutableArray<NSString *> *availableCoins;
@property (weak, nonatomic) IBOutlet UIPickerView *coinNamePickerView;
@property (weak, nonatomic) IBOutlet UITextField *coinNameTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *periodChoosingSegmentedControl;

@end

@interface ViewController () <CPTPlotDataSource, CPTPlotDataSource, CALayerDelegate>

@property CPTGraphHostingView *hostView;
@property NSMutableArray<NSNumber *> *plotDots;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.availableCoins = [NSMutableArray<NSString *> new];
    self.plotDots = [NSMutableArray<NSNumber *> new];
    
    self.networkService = [NetworkService shared];
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

- (IBAction)neededPeriodSelected:(id)sender {
    
    switch (self.periodChoosingSegmentedControl.selectedSegmentIndex) {
        case 0:
            [self loadCoinHistoryForPeriod:@1439];
            break;
            
        case 1:
            [self loadCoinHistoryForPeriod:@(167)];
            break;
            
        case 2:
            [self loadCoinHistoryForPeriod:@29];
            break;
            
        case 3:
            [self loadCoinHistoryForPeriod:@364];
            break;
            
        default:
            break;
    }
    
}

#pragma mark - CPTPlotDataSource

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords {
    return self.plotDots.count;
}
 
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{

    if(fieldEnum == CPTScatterPlotFieldX)
    {
        return [NSNumber numberWithUnsignedInteger:index];
    } else {
        return self.plotDots[self.plotDots.count - 1 - index];
    }
}

- (void)configureAxisSet:(CPTXYAxisSet **)axisSet withMaxXvalue:(NSNumber *)maxXValue maxYvalue:(NSNumber *)maxYValue numberOfXMajorIntervals:(int)numOfXMajorIntervals andNumberOfXMinorTicksPerInterval:(int)numOfXTicksPerInterval {
    
    CPTXYAxisSet *configuredAxisSet = *axisSet;
    
    configuredAxisSet.xAxis.majorIntervalLength = @([maxXValue intValue] / numOfXMajorIntervals);
    configuredAxisSet.xAxis.minorTicksPerInterval = numOfXTicksPerInterval;
    
    if ([maxYValue doubleValue] > 1.0) {
        configuredAxisSet.yAxis.majorIntervalLength = @([maxYValue doubleValue] / 10);
    } else {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        formatter.usesSignificantDigits = YES;
        configuredAxisSet.yAxis.labelFormatter = formatter;
        configuredAxisSet.yAxis.majorIntervalLength = @([maxYValue doubleValue]);
    }
    
    configuredAxisSet.yAxis.minorTicksPerInterval = 5;
}

- (void)buildPlot {
    
    if (self.hostView) {
        [self.hostView.hostedGraph removePlot:self.hostView.hostedGraph.allPlots[0]];
        self.hostView = nil;
    }
    // We need a hostview, you can create one in IB (and create an outlet) or just do this:
    CPTGraphHostingView* hostView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(20, 50, self.view.frame.size.width - 40, 350)];
    [self.view addSubview: hostView];
    self.hostView = hostView;
    self.hostView.allowPinchScaling = NO;
    
    // Create a CPTGraph object and add to hostView
    CPTGraph* graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    graph.plotAreaFrame.masksToBorder = NO;
    self.hostView.hostedGraph = graph;
    graph.backgroundColor = [UIColor blackColor].CGColor;
    graph.paddingBottom = 40.0;
    graph.paddingLeft = 65.0;
    graph.paddingTop = 30.0;
    graph.paddingRight = 15.0;
    
    // Get the (default) plotspace from the graph so we can set its x/y ranges
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    NSNumber *maxYValue = [NSNumber numberWithDouble:[(NSNumber *)[self.plotDots valueForKeyPath:@"@max.self"] doubleValue] * 1.3];
    NSNumber *maxXValue = [NSNumber numberWithUnsignedInteger:self.plotDots.count];
    
    [plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:@0 length:@([maxXValue intValue])]];
    if ([maxYValue doubleValue] > 1.0) {
        [plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:@0 length:@([maxYValue intValue])]];
    } else {
        [plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:@0 length:@([maxYValue doubleValue] * 2)]];
    }
    
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    
    CPTMutableTextStyle *axisTextStyle = [CPTMutableTextStyle new];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"HelveticaNeue-Bold";
    axisTextStyle.fontSize = 10.0;
    axisTextStyle.textAlignment = CPTTextAlignmentCenter;
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle new];
    lineStyle.lineColor = [CPTColor whiteColor];
    lineStyle.lineWidth = 5.0;
    
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle new];
    gridLineStyle.lineColor = [CPTColor grayColor];
    gridLineStyle.lineWidth = 0.5;
    
    axisSet.xAxis.labelTextStyle = axisTextStyle;
    axisSet.xAxis.minorGridLineStyle = gridLineStyle;
    axisSet.xAxis.axisLineStyle = lineStyle;
    axisSet.xAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    axisSet.xAxis.delegate = self;
    
    switch (self.plotDots.count) {
        case 144: {
            [self configureAxisSet:&axisSet withMaxXvalue:maxXValue maxYvalue:maxYValue numberOfXMajorIntervals:6 andNumberOfXMinorTicksPerInterval:3];
            break;
        }
        case 168: {
            [self configureAxisSet:&axisSet withMaxXvalue:maxXValue maxYvalue:maxYValue numberOfXMajorIntervals:7 andNumberOfXMinorTicksPerInterval:1];
            break;
        }
        case 30: {
            [self configureAxisSet:&axisSet withMaxXvalue:maxXValue maxYvalue:maxYValue numberOfXMajorIntervals:30 andNumberOfXMinorTicksPerInterval:1];
            axisSet.xAxis.labelRotation = 1.5708;
            break;
        }
        case 365: {
            [self configureAxisSet:&axisSet withMaxXvalue:maxXValue maxYvalue:maxYValue numberOfXMajorIntervals:12 andNumberOfXMinorTicksPerInterval:3];
            axisSet.xAxis.labelRotation = 1.5708;
            
            break;
        }
        default:
            break;
    }
    
    axisSet.yAxis.labelTextStyle = axisTextStyle;
    axisSet.yAxis.minorGridLineStyle = gridLineStyle;
    CPTFillArray *alternatingBF = [CPTFillArray arrayWithObjects:
                                   [CPTFill fillWithColor:[CPTColor colorWithComponentRed:255.0 green:255.0 blue:255.0 alpha:0.03]],
                                   [CPTFill fillWithColor:[CPTColor blackColor]],
                                   nil];
    axisSet.yAxis.alternatingBandFills = alternatingBF;
    axisSet.yAxis.axisLineStyle = lineStyle;
    axisSet.yAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    axisSet.yAxis.delegate = self;
    
    // Create the plot (we do not define actual x/y values yet, these will be supplied by the datasource...)
    CPTScatterPlot* plot = [CPTScatterPlot new];
    
    CPTMutableLineStyle *plotLineStyle = [CPTMutableLineStyle new];
    [plotLineStyle setLineJoin:kCGLineJoinRound];
    [plotLineStyle setLineCap:kCGLineCapRound];
    plotLineStyle.lineWidth = 2.0;
    plotLineStyle.lineColor = [CPTColor whiteColor];
    
    plot.dataLineStyle = plotLineStyle;
    plot.curvedInterpolationOption = CPTScatterPlotCurvedInterpolationCatmullCustomAlpha;
    plot.interpolation = CPTScatterPlotInterpolationCurved;

    plot.dataSource = self;
    plot.delegate = self;
    
    // Finally, add the created plot to the default plot space of the CPTGraph object we created before
    [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
    
}


- (void)loadCoinHistoryForPeriod:(NSNumber *)limit {
    
    if ([self.availableCoins containsObject:self.coinNameTextField.text]) {
        [self.plotDots removeAllObjects];
        
        switch (self.periodChoosingSegmentedControl.selectedSegmentIndex) {
            case 0: {
                [self.networkService getMinutelyHistoricalDataForCoin:self.coinNameTextField.text withLimit:limit completion:^(NSArray * _Nullable coinData) {
                    for (NSNumber *coindataItem in coinData) {
                        [self.plotDots addObject:coindataItem];
                    }
                    [self buildPlot];
                }];
                break;
            }
                
            case 1: {
                [self.networkService getHourlyHistoricalDataForCoin:self.coinNameTextField.text withLimit:limit completion:^(NSArray * _Nullable coinData) {
                    for (NSNumber *coindataItem in coinData) {
                        [self.plotDots addObject:coindataItem];
                    }
                    [self buildPlot];
                }];
                break;
            }
                
            default: {
                [self.networkService getDailyHistoricalDataForCoin:self.coinNameTextField.text withLimit:limit completion:^(NSArray * _Nullable coinData) {
                    for (NSNumber *coindataItem in coinData) {
                        [self.plotDots addObject:coindataItem];
                    }
                    [self buildPlot];
                }];
                break;
            }
        }
        
        
    }
    
}

@end
