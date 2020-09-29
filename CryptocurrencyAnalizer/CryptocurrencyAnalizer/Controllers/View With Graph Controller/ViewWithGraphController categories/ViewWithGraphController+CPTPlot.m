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


- (void)addIndicatorLineWithConstraints:(CPTConstraints *)constraints {
    
    CPTXYAxis *indicatorLine = [CPTXYAxis new];
    indicatorLine.hidden = NO;
    indicatorLine.coordinate = CPTCoordinateY;
    indicatorLine.plotSpace = self.graphView.hostedGraph.defaultPlotSpace;
    indicatorLine.axisConstraints = constraints;
    indicatorLine.labelingPolicy = CPTAxisLabelingPolicyNone;
    indicatorLine.separateLayers = YES;
    indicatorLine.preferredNumberOfMajorTicks = 1;
    indicatorLine.minorTicksPerInterval = 0;
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth = 2;
    lineStyle.lineColor = [CPTColor redColor];
    indicatorLine.axisLineStyle = lineStyle;
    indicatorLine.majorTickLineStyle = nil;
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graphModel.axisSet;
    CPTXYAxis *xAxis = axisSet.xAxis;
    CPTXYAxis *yAxis = axisSet.yAxis;
    axisSet.axes = @[xAxis, yAxis, indicatorLine];
}


- (void)configureAndAddPlot{
    
    self.graphView.hostedGraph = self.graphModel;

    NSNumber *maxYValue = [NSNumber numberWithDouble:[(NSNumber *)[self.graphModel.plotDots valueForKeyPath:@"@max.self"] doubleValue] * 1.3];
    NSNumber *maxXValue = [NSNumber numberWithUnsignedInteger:self.graphModel.plotDots.count];
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graphModel.defaultPlotSpace;
    plotSpace.delegate = self;
    [GraphService configurePlotSpace:plotSpace forPlotwithMaxXValue:maxXValue andMaxYValue:maxYValue];
    plotSpace.allowsUserInteraction = NO;
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
            [self configureOptions:&options withXMajorIntervals:6 XMinorTicks:3 andLabelRotation:ROTATION_0_DEGREES];
            break;
        }
        // For 7 days history
        case PLOT_DOTS_COUNT_WEEK: {
            [self configureOptions:&options withXMajorIntervals:7 XMinorTicks:1 andLabelRotation:ROTATION_0_DEGREES];
            break;
        }
        // For month history
        case PLOT_DOTS_COUNT_MONTH: {
            [self configureOptions:&options withXMajorIntervals:30 XMinorTicks:1 andLabelRotation:ROTATION_90_DEGREES];
            break;
        }
            
        // For one year history
        case PLOT_DOTS_COUNT_YEAR: {
            [self configureOptions:&options withXMajorIntervals:12 XMinorTicks:3 andLabelRotation:ROTATION_90_DEGREES];
            break;
        }
        default:
            break;
    }

    [GraphService configureAxisSet:&axisSet withOptions:options];
    
    CPTScatterPlot* plot = [GraphService createScatterPlotWithLineWidth:2.0 lineColor:[CPTColor whiteColor] dataSource:self andDelegate:self];
    plot.delegate = self;
    plot.plotSymbolMarginForHitDetection = 10.0;
    
    [self.graphModel addPlot:plot toPlotSpace:self.graphModel.defaultPlotSpace];
}


- (void)configureOptions:(AxisSetOptions *)options withXMajorIntervals:(int)majorIntervals XMinorTicks:(int)XMinorTicks andLabelRotation:(CGFloat)labelRotation {
    
    (*options).numberOfXMajorIntervals = majorIntervals;
    (*options).numberOfXMinorTicksPerInterval = XMinorTicks;
    (*options).labelRotation = labelRotation;
}

#pragma mark - CPTPlotDataSource and CPTPlotDelegate

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords {
    return self.graphModel.plotDots.count;
}
 

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{

    if(fieldEnum == CPTScatterPlotFieldX) {
        if ([plot.identifier isEqual:self->trackerLine]) {
            return self->highlitedPoint[0];
        } else {
            return [NSNumber numberWithUnsignedInteger:index];
        }
    } else {
        if ([plot.identifier isEqual:self->trackerLine]) {
            return self->highlitedPoint[1];
        } else {
            return self.graphModel.plotDots[self.graphModel.plotDots.count - 1 - index];
        }
    }
}


- (BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)point {
    
    [self.graphView.hostedGraph.plotAreaFrame.plotArea removeAllAnnotations];
    
    if (self->trackerLine) {
        [self.graphModel removePlotWithIdentifier:self->trackerLine];
    }
    
    CGPoint plotAreaPoint = [self.graphView.hostedGraph convertPoint:point toLayer:self.graphView.hostedGraph.plotAreaFrame.plotArea];
    CPTNumberArray *plotPoint = [space plotPointForPlotAreaViewPoint:plotAreaPoint];
    NSNumber *x = plotPoint[0];
    NSNumber *count = [NSNumber numberWithUnsignedInteger:self.graphModel.plotDots.count];
    if ([x floatValue] <= 0) {
        x = @0;
    } else if (([x compare:count] == NSOrderedSame) || ([x compare:count] == NSOrderedDescending)){
        x = [NSNumber numberWithUnsignedInteger:self.graphModel.plotDots.count - 1];
    }
    unsigned long index = self.graphModel.plotDots.count - floorf([x floatValue]) - 1;

    NSNumber *y = self.graphModel.plotDots[index];

    PlotSpaceAnnotationOptions options;
    options.plotSpace = space;
    options.anchorPoint = @[x, y];
    options.textLayer = [[CPTTextLayer alloc] initWithText:[y stringValue] style:self.graphModel.textStyles[0]];
    options.displacement = CGPointMake(0.0, 30.0);
    options.contentLayerFrame = CGRectMake(30.0, 30.0, 50.0, 20.0);
    options.contentLayerBackgroundColor = [UIColor redColor];
    options.contentAnchorPoint = CGPointMake([x floatValue] <= 30.0 ? 0.0 : 1.0, 1.0);
    
    CPTPlotSpaceAnnotation *annotation = [GraphService createAnnotationWithOptions:options];

    [self.graphView.hostedGraph.plotAreaFrame.plotArea addAnnotation:annotation];
    
    [self addIndicatorLineWithConstraints:[CPTConstraints constraintWithLowerOffset: point.x - self.graphModel.paddingLeft]];
    
    CPTScatterPlot *indicatorPlot = [GraphService createScatterPlotWithLineWidth:2.0 lineColor:[CPTColor whiteColor] dataSource:self andDelegate:self];

    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    plotSymbol.size = CGSizeMake(10.0, 10.0);
    
    indicatorPlot.plotSymbol = plotSymbol;
    indicatorPlot.identifier = @"Tracker line";
    
    [self.graphModel addPlot:indicatorPlot toPlotSpace:self.graphModel.defaultPlotSpace];

    self->trackerLine = indicatorPlot.identifier;
    self->highlitedPoint = @[x, y];
    
    return NO;
}


- (BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)point {

    return NO;
}


- (BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)point {

    return NO;
}


- (BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceCancelledEvent:(nonnull CPTNativeEvent *)event {
    
    return NO;
}

@end
