//
//  GraphService.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/10/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "CorePlot-CocoaTouch.h"
#import "GraphOptions.h"
#import "AxisSetOptions.h"
#import "GraphModel.h"

// Module to manage actions directed to graphs, plots, their options
@interface GraphService : NSObject

+ (void)configurePlotSpace:(CPTXYPlotSpace *)plotSpace forPlotwithMaxXValue:(NSNumber *)maxXValue andMaxYValue:(NSNumber *)maxYValue;

+ (CPTMutableTextStyle *)createMutableTextStyleWithFontName:(NSString *)fontName
                                                   fontSize:(CGFloat)fontSize
                                                   color:(CPTColor *)color
                                                   andTextAlignment:(CPTTextAlignment)textAlignment;

+ (CPTMutableLineStyle *)createLineStyleWithWidth:(CGFloat)width andColor:(CPTColor *)color;

+ (void)configureAxisSet:(CPTXYAxisSet **)axisSet withOptions:(AxisSetOptions)options;

+ (void)configureAxisSet:(CPTXYAxisSet **)axisSet
           withMaxXvalue:(NSNumber *)maxXValue
           maxYvalue:(NSNumber *)maxYValue
           numberOfXMajorIntervals:(int)numOfXMajorIntervals
           andNumberOfXMinorTicksPerInterval:(int)numOfXTicksPerInterval;

+ (CPTScatterPlot *)createScatterPlotWithLineWidth:(CGFloat)lineWidth
                                         lineColor:(CPTColor *)color
                                         dataSource:(id<CPTPlotDataSource>)dataSource
                                         andDelegate:(id<CALayerDelegate>)delegate;
@end
