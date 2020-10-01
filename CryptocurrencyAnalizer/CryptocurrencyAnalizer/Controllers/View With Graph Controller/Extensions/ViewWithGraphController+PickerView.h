//
//  ViewWithGraphController+PickerView.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/23/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "ViewWithGraphController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewWithGraphController (PickerView) <UIPickerViewDelegate, UIPickerViewDataSource>

- (void)appointPickerViewDelegate:(id<UIPickerViewDelegate>)delegate andDataSource:(id<UIPickerViewDataSource>)dataSource;

@end

NS_ASSUME_NONNULL_END
