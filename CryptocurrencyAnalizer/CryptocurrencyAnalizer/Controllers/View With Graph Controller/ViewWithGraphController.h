//
//  ViewWithGraphController.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/13/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import <UIKit/UIKit.h>

// Frameworks
#import "CorePlot-CocoaTouch.h"

// Models
#import "Graph.h"

// Services
#import "NetworkManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewWithGraphController : UIViewController {
    
    Graph *graph;
    NetworkManager * networkService;
    
    NSMutableArray<NSString *> *availableCoins;           // Full list of available coins
    NSMutableArray<NSString *> *filteredAvailableCoins;   // List of available coins after searching with the help of text Field
    
    id<NSCopying, NSCoding, NSObject> trackerLine;
    NSArray<NSNumber *> *highlitedPoint;
    
    unsigned long divider;
    
    NSString *table;
    NSString *dbLimit;
    NSNumber *apiLimit;
}

@property (weak, nonatomic) IBOutlet UITextField *coinNameTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *periodChoosingSegmentedControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIPickerView *coinNamePickerView;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *graphView;

@end

NS_ASSUME_NONNULL_END
