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
    options.color = [UIColor whiteColor].CGColor;
    options.paddingBottom = 80.0;
    options.paddingLeft = 65.0;
    options.paddingTop = 30.0;
    options.paddingRight = 15.0;
    
    self->graphModel = [[GraphModel alloc] initModelWithOptions:options];
    
    self->graphModel.textStyles[0] = [GraphManager createMutableTextStyleWithFontName:@"HelveticaNeue-Bold" fontSize:10.0 color:[CPTColor grayColor] andTextAlignment:CPTTextAlignmentCenter];
    self->graphModel.lineStyles[0] = [GraphManager createLineStyleWithWidth:5.0 andColor:[CPTColor whiteColor]];
    self->graphModel.gridLineStyles[0] = [GraphManager createLineStyleWithWidth:0.5 andColor:[CPTColor grayColor]];
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
    
    lineStyle.lineWidth = 1;
    lineStyle.lineColor = [CPTColor colorWithComponentRed:70.0/255.0 green:88.0/255.0 blue:209.0/255.0 alpha:1.0];
    indicatorLine.axisLineStyle = lineStyle;
    indicatorLine.majorTickLineStyle = nil;
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self->graphModel.axisSet;
    
    CPTXYAxis *xAxis = axisSet.xAxis;
    CPTXYAxis *yAxis = axisSet.yAxis;
    axisSet.axes = @[xAxis, yAxis, indicatorLine];
}


- (void)configureAndAddPlot{
    
    self.graphView.hostedGraph = self->graphModel;

    NSMutableArray *prices = [NSMutableArray new];
    
    for (DBModel *model in self->graphModel.plotDots) {
        [prices addObject:model.price];
    }
    
    NSNumber *maxYValue = [NSNumber numberWithDouble:[(NSNumber *)[prices valueForKeyPath:@"@max.self"] doubleValue] * 1.3];
    NSNumber *maxXValue;
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self->graphModel.axisSet;
    
    AxisSetOptions options;
    
    options.labelTextStyle = self->graphModel.textStyles[0];
    options.gridLineStyle = self->graphModel.gridLineStyles[0];
    options.axisLineStyle = self->graphModel.lineStyles[0];
    options.xAxisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    options.yAxisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    options.xAxisDelegate = self;
    options.yAxisDelegate = self;
    options.maxYValue = maxYValue;
    options.referenceDate = self->graphModel.plotDots[0].timestamp;
    
    // Depending on the selected time period, we will get different number of dots
    switch (self->graphModel.plotDots.count) {
        // For one day history
        case PLOT_DOTS_COUNT_DAY: {
            self->divider = DIVIDER_TEN_MINUTE;
            maxXValue = [NSNumber numberWithInt:(DATE_ONE_DAY * [DB_LIMIT_FOR_MINUTELY_TABLE intValue] / self->divider)];
            options.maxXValue = maxXValue;
            [self configureOptions:&options withXMajorIntervals:6 XMinorTicks:0 xAxisDateFotmat:DATE_FORMAT_DAILY andLabelRotation:ROTATION_90_DEGREES];
            break;
        }
            
        // For 7 days history
        case PLOT_DOTS_COUNT_WEEK: {
            self->divider = DIVIDER_ONE_HOUR;
            maxXValue = [NSNumber numberWithInt:(DATE_ONE_DAY * 7)];
            options.maxXValue = maxXValue;
            [self configureOptions:&options withXMajorIntervals:7 XMinorTicks:0 xAxisDateFotmat:DATE_FORMAT_WEEKLY andLabelRotation:ROTATION_90_DEGREES];
            break;
        }
            
        // For month history
        case PLOT_DOTS_COUNT_MONTH: {
            self->divider = DIVIDER_ONE_DAY;
            maxXValue = [NSNumber numberWithInt:(DATE_ONE_DAY * 30)];
            options.maxXValue = maxXValue;
            [self configureOptions:&options withXMajorIntervals:30 XMinorTicks:0 xAxisDateFotmat:DATE_FORMAT_MONTHLY andLabelRotation:ROTATION_90_DEGREES];
            break;
        }
            
        // For one year history
        case PLOT_DOTS_COUNT_YEAR: {
            self->divider = DIVIDER_ONE_DAY;
            maxXValue = [NSNumber numberWithInt:(DATE_ONE_DAY * 365)];
            options.maxXValue = maxXValue;
            [self configureOptions:&options withXMajorIntervals:12 XMinorTicks:0 xAxisDateFotmat:DATE_FORMAT_YEARLY andLabelRotation:ROTATION_90_DEGREES];
            break;
        }
            
        default:
            break;
    }

    [GraphManager configureAxisSet:&axisSet withOptions:options];
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self->graphModel.defaultPlotSpace;
    
    plotSpace.delegate = self;
    plotSpace.allowsUserInteraction = NO;
    
    [GraphManager configurePlotSpace:plotSpace forPlotwithMaxXValue:maxXValue andMaxYValue:maxYValue];
    
    CPTColor *plotLineColor = [CPTColor colorWithComponentRed:70.0/255.0 green:88.0/255.0 blue:209.0/255.0 alpha:1.0];
    CPTScatterPlot* plot = [GraphManager createScatterPlotWithLineWidth:3.0 lineColor:plotLineColor dataSource:self andDelegate:self];
    
    plot.delegate = self;
    plot.plotSymbolMarginForHitDetection = 10.0;
    
    [self->graphModel addPlot:plot toPlotSpace:self->graphModel.defaultPlotSpace];
}


- (void)configureOptions:(AxisSetOptions *)options
                        withXMajorIntervals:(int)majorIntervals
                        XMinorTicks:(int)XMinorTicks
                        xAxisDateFotmat:(NSString *)xAxisDateFormat
                        andLabelRotation:(CGFloat)labelRotation {
    
    (*options).numberOfXMajorIntervals = majorIntervals;
    (*options).numberOfXMinorTicksPerInterval = XMinorTicks;
    (*options).labelRotation = labelRotation;
    (*options).xAxisDateFormatString = xAxisDateFormat;
}

#pragma mark - CPTPlotDataSource and CPTPlotDelegate

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords {
    
    return self->graphModel.plotDots.count;
}
 

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {

    if(fieldEnum == CPTScatterPlotFieldX) {
        if ([plot.identifier isEqual:self->trackerLine]) {
            return self->highlitedPoint[0];
        } else {
            unsigned long numberForPlot = DATE_ONE_DAY * index / self->divider;
            
            return [NSNumber numberWithUnsignedLong:numberForPlot];
        }
    } else {
        if ([plot.identifier isEqual:self->trackerLine]) {
            return self->highlitedPoint[1];
        } else {
            return self->graphModel.plotDots[index].price;
        }
    }
}


- (BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)point {
    
    [self.graphView.hostedGraph.plotAreaFrame.plotArea removeAllAnnotations];
    
    if (self->trackerLine) {
        [self->graphModel removePlotWithIdentifier:self->trackerLine];
    }
    
    CGPoint plotAreaPoint = [self.graphView.hostedGraph convertPoint:point toLayer:self.graphView.hostedGraph.plotAreaFrame.plotArea];
    
    CPTNumberArray *plotPoint = [space plotPointForPlotAreaViewPoint:plotAreaPoint];
    
    NSNumber *x = plotPoint[0];
    
    unsigned long count = self->graphModel.plotDots.count;
    
    if ([x floatValue] <= 0) {
        x = @0;
    } else if (([x compare:@(count * DATE_ONE_DAY / self->divider)] == NSOrderedSame) || ([x compare:@(count * DATE_ONE_DAY / self->divider)] == NSOrderedDescending)) {
        x = [NSNumber numberWithUnsignedInteger:(self->graphModel.plotDots.count - 1) * DATE_ONE_DAY / self->divider];
    }
        
    unsigned long index = floorf([x floatValue]) * self->divider / DATE_ONE_DAY;

    NSNumber *y = self->graphModel.plotDots[index].price;
    
    NSDate *dateForAnnotation = [NSDate dateWithTimeIntervalSince1970:[(NSNumber *)(self->graphModel.plotDots[index].timestamp) doubleValue]];
    NSDateFormatter *annotationDateFormatter = [NSDateFormatter new];
    
    annotationDateFormatter.dateFormat = DATE_FORMAT_FOR_ANNOTATION;
    
    NSString *dateForAnnotationString = [annotationDateFormatter stringFromDate:dateForAnnotation];
    
    NSNumberFormatter *numberFormatterForAnnotation = [NSNumberFormatter new];
    
    numberFormatterForAnnotation.numberStyle = DECIMAL_DIG;
    numberFormatterForAnnotation.maximumFractionDigits = 8;
    
    NSString *annotationText = [NSString stringWithFormat:@"%@\n%@", [numberFormatterForAnnotation stringFromNumber:y], dateForAnnotationString];
    
    unsigned long middleValueOfXAxis = (self->graphModel.plotDots.count / 2) * DATE_ONE_DAY / self->divider;
    
    PlotSpaceAnnotationOptions options;
    
    CPTTextStyle *annotationTextStyle = [GraphManager createMutableTextStyleWithFontName:@"HelveticaNeue-Bold" fontSize:14.0 color:[CPTColor blackColor] andTextAlignment:CPTTextAlignmentCenter];
    
    options.textLayer = [[CPTTextLayer alloc] initWithText:annotationText style:annotationTextStyle];
    options.plotSpace = space;
    options.anchorPoint = @[x, y];
    options.displacement = CGPointMake(0.0, 30.0);
    options.contentLayerFrame = CGRectMake(50.0, 30.0, 100.0, 40.0);
    options.contentLayerBackgroundColor = [UIColor whiteColor];
    options.contentAnchorPoint = CGPointMake([x floatValue] <= middleValueOfXAxis ? -0.1 : 1.1, 0.3);

    CPTPlotSpaceAnnotation *annotation = [GraphManager createAnnotationWithOptions:options];
    
    [self.graphView.hostedGraph.plotAreaFrame.plotArea addAnnotation:annotation];
    
    [self addIndicatorLineWithConstraints:[CPTConstraints constraintWithLowerOffset: point.x - self->graphModel.paddingLeft]];
    
    CPTScatterPlot *indicatorPlot = [GraphManager createScatterPlotWithLineWidth:2.0 lineColor:[CPTColor whiteColor] dataSource:self andDelegate:self];

    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    
    CPTMutableLineStyle *plotSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    
    plotSymbolLineStyle.lineWidth = 3.0;
    
    plotSymbol.lineStyle = plotSymbolLineStyle;
    plotSymbol.fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:70.0/255.0 green:88.0/255.0 blue:209.0/255.0 alpha:1.0]];
    plotSymbol.size = CGSizeMake(15.0, 15.0);

    indicatorPlot.plotSymbol = plotSymbol;
    indicatorPlot.identifier = @"Tracker line";
    
    [self->graphModel addPlot:indicatorPlot toPlotSpace:self->graphModel.defaultPlotSpace];

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
