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
+ (void)configureAxisSet:(CPTXYAxisSet **)axisSet withOptions:(AxisSetOptions)options {
    
    CPTXYAxisSet *configuredAxisSet = *axisSet;
    
    configuredAxisSet.xAxis.labelTextStyle = options.labelTextStyle;
    configuredAxisSet.xAxis.minorGridLineStyle = options.gridLineStyle;
    configuredAxisSet.xAxis.axisLineStyle = options.axisLineStyle;
    configuredAxisSet.xAxis.axisConstraints = options.xAxisConstraints;
    configuredAxisSet.xAxis.delegate = options.xAxisDelegate;
    
    configuredAxisSet.yAxis.labelTextStyle = options.labelTextStyle;
    configuredAxisSet.yAxis.minorGridLineStyle = options.gridLineStyle;
    CPTFillArray *alternatingBF = [CPTFillArray arrayWithObjects:
                                   [CPTFill fillWithColor:[CPTColor colorWithComponentRed:255.0 green:255.0 blue:255.0 alpha:0.03]],
                                   [CPTFill fillWithColor:[CPTColor blackColor]],
                                   nil];
    configuredAxisSet.yAxis.alternatingBandFills = alternatingBF;
    configuredAxisSet.yAxis.axisLineStyle = options.axisLineStyle;
    configuredAxisSet.yAxis.axisConstraints = options.yAxisConstraints;
    configuredAxisSet.yAxis.delegate = options.yAxisDelegate;
    configuredAxisSet.xAxis.majorIntervalLength = @([options.maxXValue intValue] / options.numberOfXMajorIntervals);
    configuredAxisSet.xAxis.minorTicksPerInterval = options.numberOfXMinorTicksPerInterval;
       
    if ([options.maxYValue doubleValue] > 1.0) {
        configuredAxisSet.yAxis.majorIntervalLength = @([options.maxYValue doubleValue] / 10);
    } else {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        formatter.usesSignificantDigits = YES;
        configuredAxisSet.yAxis.labelFormatter = formatter;
        configuredAxisSet.yAxis.majorIntervalLength = @([options.maxYValue doubleValue]);
    }
       
    configuredAxisSet.yAxis.minorTicksPerInterval = 5;
    configuredAxisSet.xAxis.labelRotation = options.labelRotation;
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
