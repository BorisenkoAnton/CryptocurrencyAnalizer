//
//  ViewWithGraphController+TextFieldDelegate.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/23/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "ViewWithGraphController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewWithGraphController (TextFieldDelegate) <UITextFieldDelegate>

- (void)configureTextField;
- (NSMutableArray *)searchInArray:(NSMutableArray<NSString *> *)arrayToSearchInto withKey:(NSString *)key andCharacters:(NSString *)charecters;

@end

NS_ASSUME_NONNULL_END
