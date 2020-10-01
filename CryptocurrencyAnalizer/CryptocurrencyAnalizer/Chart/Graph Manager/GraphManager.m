//
//  GraphService.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/10/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GraphManager.h"

@implementation GraphManager

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
    configuredAxisSet.xAxis.majorIntervalLength = @([options.maxXValue intValue] / options.numberOfXMajorIntervals);
    configuredAxisSet.xAxis.minorTicksPerInterval = options.numberOfXMinorTicksPerInterval;
    
    NSTimeInterval referenceTimeInterval = [(NSNumber *)options.referenceDate doubleValue];
    
    NSDate *referenceDate = [NSDate dateWithTimeIntervalSince1970:referenceTimeInterval];
    
    NSDateFormatter *labelDateFormatter = [NSDateFormatter new];
    
    labelDateFormatter.dateStyle = kCFDateFormatterLongStyle;
    labelDateFormatter.dateFormat = options.xAxisDateFormatString;
    
    CPTTimeFormatter *labelTimeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:labelDateFormatter];
    
    labelTimeFormatter.referenceDate = referenceDate;
    
    configuredAxisSet.xAxis.labelFormatter = labelTimeFormatter;
    
    CPTFillArray *alternatingBF = @[
    [CPTFill fillWithColor:[CPTColor colorWithComponentRed:255.0 green:255.0 blue:255.0 alpha:0.03]],
    [CPTFill fillWithColor:[CPTColor blackColor]],
    ];
    
    configuredAxisSet.yAxis.alternatingBandFills = alternatingBF;
    configuredAxisSet.yAxis.labelTextStyle = options.labelTextStyle;
    configuredAxisSet.yAxis.minorGridLineStyle = options.gridLineStyle;
    configuredAxisSet.yAxis.axisLineStyle = options.axisLineStyle;
    configuredAxisSet.yAxis.axisConstraints = options.yAxisConstraints;
    configuredAxisSet.yAxis.delegate = options.yAxisDelegate;
    configuredAxisSet.yAxis.minorTicksPerInterval = 5;
    configuredAxisSet.xAxis.labelRotation = options.labelRotation;
       
    if ([options.maxYValue doubleValue] > 1.0) {
        configuredAxisSet.yAxis.majorIntervalLength = @([options.maxYValue doubleValue] / 10);
    } else {
        NSNumberFormatter *numberFormatterforYAxis = [NSNumberFormatter new];
        
        numberFormatterforYAxis.usesSignificantDigits = YES;
        
        configuredAxisSet.yAxis.labelFormatter = numberFormatterforYAxis;
        configuredAxisSet.yAxis.majorIntervalLength = options.maxYValue;
    }
}


+ (CPTScatterPlot *)createScatterPlotWithLineWidth:(CGFloat)lineWidth lineColor:(CPTColor *)color dataSource:(id<CPTPlotDataSource>)dataSource andDelegate:(id<CALayerDelegate>)delegate {
    
    CPTScatterPlot* plot = [CPTScatterPlot new];
    
    CPTMutableLineStyle *plotLineStyle = [CPTMutableLineStyle new];
    
    plotLineStyle.lineJoin = kCGLineJoinRound; // The style for the joins of connected lines in a graphics contex
    plotLineStyle.lineCap = kCGLineCapRound;  // The style for the endpoints of lines drawn in a graphics context
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


+ (CPTPlotSpaceAnnotation *)createAnnotationWithOptions:(PlotSpaceAnnotationOptions)options {
    
    CPTPlotSpaceAnnotation *annotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:options.plotSpace anchorPlotPoint:options.anchorPoint];
    
    annotation.contentLayer = options.textLayer;
    annotation.displacement = options.displacement;
    annotation.contentLayer.frame = options.contentLayerFrame;
    annotation.contentLayer.backgroundColor = options.contentLayerBackgroundColor.CGColor;
    annotation.contentAnchorPoint = options.contentAnchorPoint;
    
    return annotation;
}

@end
