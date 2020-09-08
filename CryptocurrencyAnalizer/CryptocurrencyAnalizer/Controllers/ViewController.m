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

@interface ViewController () <CPTPlotDataSource>

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

- (void)buildPlot {
    if (self.hostView) {
        [self.hostView.hostedGraph removePlot:self.hostView.hostedGraph.allPlots[0]];
        self.hostView = nil;
    }
    // We need a hostview, you can create one in IB (and create an outlet) or just do this:
    CPTGraphHostingView* hostView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(20, 20, self.view.frame.size.width - 40, 300)];
    [self.view addSubview: hostView];
    self.hostView = hostView;
    
    // Create a CPTGraph object and add to hostView
    CPTGraph* graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    self.hostView.hostedGraph = graph;
    
    // Get the (default) plotspace from the graph so we can set its x/y ranges
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    NSLog(@"%@", [[NSNumber numberWithUnsignedInteger:self.plotDots.count] stringValue]);
    // Note that these CPTPlotRange are defined by START and LENGTH (not START and END) !!]
    [plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:@0 length:[NSNumber numberWithUnsignedInteger:self.plotDots.count]]];
    [plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:@0 length:[self.plotDots valueForKeyPath:@"@max.self"]]];
    
    // Create the plot (we do not define actual x/y values yet, these will be supplied by the datasource...)
    CPTScatterPlot* plot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    
    // Let's keep it simple and let this class act as datasource (therefore we implemtn <CPTPlotDataSource>)
    plot.dataSource = self;
    
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
