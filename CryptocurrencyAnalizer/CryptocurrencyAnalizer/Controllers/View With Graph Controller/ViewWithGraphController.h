//
//  ViewWithGraphController.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/13/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "GraphModel.h"
#import "NetworkService.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewWithGraphController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *coinNameTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *periodChoosingSegmentedControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIPickerView *coinNamePickerView;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *graphView;

@property NSMutableArray<NSString *> *availableCoins;           // Full list of available coins
@property NSMutableArray<NSString *> *filteredAvailableCoins;   // List of available coins after searching with the help of text Field
@property (strong) GraphModel *graphModel;
@property NetworkService * networkService;

@end

NS_ASSUME_NONNULL_END
