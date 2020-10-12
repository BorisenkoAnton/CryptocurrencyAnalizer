//
//  ViewWithGraphController+CPTPlot.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/23/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "ViewWithGraphController.h"
#import "PlotSpaceAnnotationOptions.h"

// Helpers
#import "GraphOptions.h"
#import "DBFixedValues.h"
#import "GraphFixedValues.h"

// Services
#import "GraphManager.h"


NS_ASSUME_NONNULL_BEGIN

@interface ViewWithGraphController (CPTPlot) <CPTPlotDataSource, CPTPlotDelegate, CPTPlotSpaceDelegate, CPTScatterPlotDelegate,CALayerDelegate> 

- (void)configureGraph;
- (void)configureAndAddPlot;

@end

NS_ASSUME_NONNULL_END
