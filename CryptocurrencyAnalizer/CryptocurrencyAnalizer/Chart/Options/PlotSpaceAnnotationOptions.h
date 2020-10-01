//
//  PlotSpaceAnnotationOptions.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/29/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#ifndef PlotSpaceAnnotationOptions_h
#define PlotSpaceAnnotationOptions_h

typedef struct {
    NSArray *anchorPoint;
    CPTTextLayer *textLayer;
    CGPoint displacement;
    CGRect contentLayerFrame;
    UIColor *contentLayerBackgroundColor;
    CGPoint contentAnchorPoint;
    CPTPlotSpace *plotSpace;
} PlotSpaceAnnotationOptions;

#endif /* PlotSpaceAnnotationOptions_h */
