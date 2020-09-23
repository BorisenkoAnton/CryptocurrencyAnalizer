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

- (void)appointPickerViewDelegate:(id)delegate andDataSource:(id)dataSource {
    
    self.coinNamePickerView.delegate = delegate;
    self.coinNamePickerView.dataSource = dataSource;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.filteredAvailableCoins.count;
}
// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
     return self.filteredAvailableCoins[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.coinNameTextField.text = self.filteredAvailableCoins[row];
}

@end
