//
//  ViewWithGraphController+CPTPlot.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/23/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "ViewWithGraphController.h"

// Helpers
#import "GraphOptions.h"
#import "FixedValues.h"

// Services
#import "GraphService.h"



NS_ASSUME_NONNULL_BEGIN

@interface ViewWithGraphController (CPTPlot) <CPTPlotDataSource, CPTPlotDelegate, CPTPlotSpaceDelegate, CPTScatterPlotDelegate,CALayerDelegate>

- (void)configureGraphModel;
- (void)configureAndAddPlot;

@end

NS_ASSUME_NONNULL_END
