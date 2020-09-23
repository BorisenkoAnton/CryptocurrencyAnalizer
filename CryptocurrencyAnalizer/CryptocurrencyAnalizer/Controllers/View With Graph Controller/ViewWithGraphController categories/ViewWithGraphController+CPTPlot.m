//
//  ViewWithGraphController+CPTPlot.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/23/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "ViewWithGraphController+CPTPlot.h"

@implementation ViewWithGraphController (CPTPlot)

- (void)configureGraphModel {
    
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

@end
