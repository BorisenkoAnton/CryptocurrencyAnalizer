//
//  ViewWithGraphController+CPTPlot.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/23/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "ViewWithGraphController.h"
#import "GraphService.h"
#import "GraphOptions.h"
#import "FixedValues.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewWithGraphController (CPTPlot) <CPTPlotDataSource, CPTPlotDelegate, CALayerDelegate>

- (void)configureGraphModel;
- (void)configureAndAddPlot;

@end

NS_ASSUME_NONNULL_END
