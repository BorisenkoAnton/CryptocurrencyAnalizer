//
//  AxisSetOptions.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/22/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//
//#import "CorePlot-CocoaTouch.h"

#ifndef AxisSetOptions_h
#define AxisSetOptions_h

typedef struct {
    CPTTextStyle *labelTextStyle;
    CPTLineStyle *gridLineStyle;
    CPTLineStyle *axisLineStyle;
    CPTConstraints *xAxisConstraints;
    CPTConstraints *yAxisConstraints;
    id<CALayerDelegate> xAxisDelegate;
    id<CALayerDelegate> yAxisDelegate;
} AxisSetOptions;

#endif /* AxisSetOptions_h */


