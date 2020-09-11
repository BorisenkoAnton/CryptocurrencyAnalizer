//
//  GraphService.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/10/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GraphService.h"

@implementation GraphService

+ (CPTGraph *)createAndConfigureGraphWithFrame:(CGRect)frame backgroundColor:(CGColorRef)color bottomPadding:(CGFloat)paddingBottom leftPadding:(CGFloat)paddingLeft topPadding:(CGFloat)paddingTop andRightPadding:(CGFloat)paddingRight {
    
    CPTGraph* graph = [[CPTXYGraph alloc] initWithFrame:frame];
    // If YES, a sublayer mask is applied to clip sublayer content to the inside of the border
    graph.plotAreaFrame.masksToBorder = NO;
    graph.backgroundColor = color;
    // Padding from graph to its container
    graph.paddingBottom = paddingBottom;
    graph.paddingLeft = paddingLeft;
    graph.paddingTop = paddingTop;
    graph.paddingRight = paddingRight;
    
    return graph;
}

// Plot space defines the coordinate system of a plot
+ (void)configurePlotSpace:(CPTXYPlotSpace *)plotSpace forPlotwithMaxXValue:(NSNumber *)maxXValue andMaxYValue:(NSNumber *)maxYValue {
    
    [plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:@0 length:@([maxXValue intValue])]];
    if ([maxYValue doubleValue] > 1.0) {
        [plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:@0 length:@([maxYValue intValue])]];
    } else {
        [plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:@0 length:@([maxYValue doubleValue] * 2)]];
    }
}

+ (CPTMutableTextStyle *)createMutableTextStyleWithFontName:(NSString *)fontName fontSize:(CGFloat)fontSize color:(CPTColor *)color andTextAlignment:(CPTTextAlignment)textAlignment {
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle new];
    
    textStyle.color = color;
    textStyle.fontName = fontName;
    textStyle.fontSize = fontSize;
    textStyle.textAlignment = textAlignment;
    
    return textStyle;
}

// Mutable wrapper for various line drawing properties
+ (CPTMutableLineStyle *)createLineStyleWithWidth:(CGFloat)width andColor:(CPTColor *)color {
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle new];
    
    lineStyle.lineColor = color;
    lineStyle.lineWidth = width;
    
    return lineStyle;
}

// CPTXYAxisSet is a set of cartesian (X-Y) axes
+ (void)configureAxisSet:(CPTXYAxisSet **)axisSet withLabelTextStyle:(CPTTextStyle *)labelTextStyle minorGridLineStyle:(CPTLineStyle *)gridLineStyle axisLineStyle:(CPTLineStyle *)axisLineStyle xAxisConstraints:(CPTConstraints *)xAxisConstraints yAxisConstraints:(CPTConstraints *)yAxisConstraints xAxisDelegate:(id<CALayerDelegate>)xAxisDelegate andYAxisDelegate:(id<CALayerDelegate>)yAxisDelegate {
    
    CPTXYAxisSet *configuredAxisSet = *axisSet;
    
    configuredAxisSet.xAxis.labelTextStyle = labelTextStyle;
    configuredAxisSet.xAxis.minorGridLineStyle = gridLineStyle;
    configuredAxisSet.xAxis.axisLineStyle = axisLineStyle;
    configuredAxisSet.xAxis.axisConstraints = xAxisConstraints;
    configuredAxisSet.xAxis.delegate = xAxisDelegate;
    
    configuredAxisSet.yAxis.labelTextStyle = labelTextStyle;
    configuredAxisSet.yAxis.minorGridLineStyle = gridLineStyle;
    CPTFillArray *alternatingBF = [CPTFillArray arrayWithObjects:
                                   [CPTFill fillWithColor:[CPTColor colorWithComponentRed:255.0 green:255.0 blue:255.0 alpha:0.03]],
                                   [CPTFill fillWithColor:[CPTColor blackColor]],
                                   nil];
    configuredAxisSet.yAxis.alternatingBandFills = alternatingBF;
    configuredAxisSet.yAxis.axisLineStyle = axisLineStyle;
    configuredAxisSet.yAxis.axisConstraints = yAxisConstraints;
    configuredAxisSet.yAxis.delegate = yAxisDelegate;
}

+ (void)configureAxisSet:(CPTXYAxisSet **)axisSet withMaxXvalue:(NSNumber *)maxXValue maxYvalue:(NSNumber *)maxYValue numberOfXMajorIntervals:(int)numOfXMajorIntervals andNumberOfXMinorTicksPerInterval:(int)numOfXTicksPerInterval {
    
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

+ (CPTScatterPlot *)createScatterPlotWithLineWidth:(CGFloat)lineWidth lineColor:(CPTColor *)color dataSource:(id<CPTPlotDataSource>)dataSource andDelegate:(id<CALayerDelegate>)delegate {
    
    CPTScatterPlot* plot = [CPTScatterPlot new];
    
    CPTMutableLineStyle *plotLineStyle = [CPTMutableLineStyle new];
    // The style for the joins of connected lines in a graphics contex
    [plotLineStyle setLineJoin:kCGLineJoinRound];
    // The style for the endpoints of lines drawn in a graphics context
    [plotLineStyle setLineCap:kCGLineCapRound];
    plotLineStyle.lineWidth = lineWidth;
    plotLineStyle.lineColor = color;
    
    plot.dataLineStyle = plotLineStyle;
    // The interpolation method used to generate the curved plot line
    plot.curvedInterpolationOption = CPTScatterPlotCurvedInterpolationCatmullCustomAlpha; // Catmull-Rom Spline Interpolation with a custom alpha value
    plot.interpolation = CPTScatterPlotInterpolationCurved;

    plot.dataSource = dataSource;
    plot.delegate = delegate;
    
    return plot;
}

@end
