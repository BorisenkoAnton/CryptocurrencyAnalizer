//
//  ViewWithGraphController+TablesCreating.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/23/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "ViewWithGraphController.h"
#import "DBService.h"
#import "FixedValues.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewWithGraphController (TablesCreating)

- (void)createTablesInDB;

@end

NS_ASSUME_NONNULL_END
