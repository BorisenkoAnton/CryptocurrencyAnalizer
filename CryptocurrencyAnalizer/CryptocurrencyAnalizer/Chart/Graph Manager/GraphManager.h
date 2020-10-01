//
//  GraphService.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/10/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

// Frameworks
#import "CorePlot-CocoaTouch.h"

// Helpers
#import "GraphOptions.h"
#import "AxisSetOptions.h"
#import "PlotSpaceAnnotationOptions.h"

// Modules
#import "GraphModel.h"

// Module to manage actions directed to graphs, plots, their options
@interface GraphManager : NSObject

+ (void)configurePlotSpace:(CPTXYPlotSpace *)plotSpace forPlotwithMaxXValue:(NSNumber *)maxXValue andMaxYValue:(NSNumber *)maxYValue;

+ (CPTMutableTextStyle *)createMutableTextStyleWithFontName:(NSString *)fontName
                                                   fontSize:(CGFloat)fontSize
                                                   color:(CPTColor *)color
                                                   andTextAlignment:(CPTTextAlignment)textAlignment;

+ (CPTMutableLineStyle *)createLineStyleWithWidth:(CGFloat)width andColor:(CPTColor *)color;

+ (void)configureAxisSet:(CPTXYAxisSet **)axisSet withOptions:(AxisSetOptions)options;

+ (CPTScatterPlot *)createScatterPlotWithLineWidth:(CGFloat)lineWidth
                                         lineColor:(CPTColor *)color
                                         dataSource:(id<CPTPlotDataSource>)dataSource
                                         andDelegate:(id<CALayerDelegate>)delegate;

+ (CPTPlotSpaceAnnotation *)createAnnotationWithOptions:(PlotSpaceAnnotationOptions)options;

@end
