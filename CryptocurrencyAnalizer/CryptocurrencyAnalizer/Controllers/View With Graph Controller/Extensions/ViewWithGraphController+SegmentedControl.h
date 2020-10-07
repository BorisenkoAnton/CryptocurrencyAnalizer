//
//  ViewWithGraphController+SegmentedControl.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/23/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "ViewWithGraphController.h"
#import "ViewWithGraphController+CPTPlot.h"

// Managers
#import "CacheManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewWithGraphController (SegmentedControl)

- (void)configureSegmentedControl;

@end

NS_ASSUME_NONNULL_END
