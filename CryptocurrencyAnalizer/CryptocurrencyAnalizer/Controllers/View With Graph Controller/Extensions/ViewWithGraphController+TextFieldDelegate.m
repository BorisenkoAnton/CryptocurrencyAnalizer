//
//  ViewWithGraphController+TextFieldDelegate.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/23/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "ViewWithGraphController+TextFieldDelegate.h"

@implementation ViewWithGraphController (TextFieldDelegate)

- (void)configureTextField {
    
    self.coinNameTextField.delegate = self;
    
    [self.coinNameTextField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    
    // Adding controller as observer to notifications, to know when keyboard appears and dissapears (to manage UI elements size)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // To hide keyboard when user tapped on the screen (outside keyboard)
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

// This method enables or disables the processing of return key
-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
   [textField resignFirstResponder];
    
   return YES;
}

// Searching in coins list when text is changed
-(void)textFieldValueChanged:(UITextField *)textField {
    
    if((textField.text.length) > 0) {
        self->filteredAvailableCoins = [self searchInArray:self->availableCoins withKey:@"key value" andCharacters:textField.text];
    }
    else {
        self->filteredAvailableCoins = [self->availableCoins mutableCopy];
    }

    [self.coinNamePickerView reloadAllComponents];

}

- (void)dismissKeyboard {
    
    [self.coinNameTextField resignFirstResponder];
}

-(NSMutableArray *)searchInArray:(NSMutableArray<NSString *> *)arrayToSearchInto withKey:(NSString *)key andCharacters:(NSString *)characters {

    NSMutableArray *resultArray= [NSMutableArray new];
    
    for (int index = 0 ; index < arrayToSearchInto.count; index++) {
        NSString *coinName  = arrayToSearchInto[index];
        
        if ([coinName localizedCaseInsensitiveContainsString:characters]) {
            [resultArray addObject:coinName];
        }

    }

    return resultArray;

}

#pragma mark - Configuring view size when keyboard appears

- (void) keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary* keyboardInfo = [notification userInfo];
    
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    CGSize keyboardSize = keyboardFrameBeginRect.size;
    
    if (self.view.frame.origin.y == 0) {
        CGRect frame = self.view.frame;
        
        frame.origin.y -= keyboardSize.height;
        
        self.view.frame = frame;
    }
    
}

- (void) keyboardWillHide:(NSNotification *)notification {
    
    if (self.view.frame.origin.y != 0) {
        CGRect frame = self.view.frame;
        
        frame.origin.y = 0;
        
        self.view.frame = frame;
    }
}

@end
