//
//  ViewWithGraph.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/10/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewWithGraph : UIView

@property (weak, nonatomic) IBOutlet CPTGraphHostingView *graphView; // A container view for displaying a CPTGraph
@property (weak, nonatomic) IBOutlet UISegmentedControl *periodChoosingSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *coinNameTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *coinNamePickerView;
@end

NS_ASSUME_NONNULL_END
