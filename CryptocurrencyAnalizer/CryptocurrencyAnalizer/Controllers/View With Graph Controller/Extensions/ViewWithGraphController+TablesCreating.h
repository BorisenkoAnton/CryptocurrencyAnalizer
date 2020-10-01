//
//  ViewWithGraphController+TablesCreating.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/23/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "ViewWithGraphController.h"

// Helpers
#import "FixedValues.h"

// Services
#import "DBService.h"


NS_ASSUME_NONNULL_BEGIN

@interface ViewWithGraphController (TablesCreating)

- (void)createTablesInDB;

@end

NS_ASSUME_NONNULL_END
