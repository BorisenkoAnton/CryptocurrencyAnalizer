//
//  ViewWithGraphController+PickerView.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/23/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "ViewWithGraphController+PickerView.h"
#import "ViewWithGraphController+TextFieldDelegate.h"

@implementation ViewWithGraphController (PickerView)

- (void)appointPickerViewDelegate:(id<UIPickerViewDelegate>)delegate andDataSource:(id<UIPickerViewDataSource>)dataSource {
    
    self.coinNamePickerView.delegate = delegate;
    self.coinNamePickerView.dataSource = dataSource;
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return self->filteredAvailableCoins.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
     return self->filteredAvailableCoins[row];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.coinNameTextField.text = self->filteredAvailableCoins[row];
}


- (void)loadAvailableCoins {
    
    self->availableCoins = [NSMutableArray<NSString *> new];
    self->networkService = [NetworkManager shared];
    
    // Getting list of all available coins, unreasonable to cache it because of the max-age=120
    [self->networkService getAndParseData:nil withAPILimit:nil completion:^(NSMutableArray<DBModel *> * _Nullable coinData) {
        for (NSString *coin in coinData) {
            [self->availableCoins addObject:coin];
        }
        
        [self->availableCoins sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        self->filteredAvailableCoins = [self->availableCoins mutableCopy];
        
        [self.coinNamePickerView reloadAllComponents];
        [self.coinNamePickerView selectRow:0 inComponent:0 animated:NO];
        
        [self.activityIndicator stopAnimating];
    }];
    
}

@end
