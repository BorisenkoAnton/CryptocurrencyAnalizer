//
//  ViewWithGraphController.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/13/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "ViewWithGraphController.h"

// Categories
#import "ViewWithGraphController+TextFieldDelegate.h"
#import "ViewWithGraphController+PickerView.h"
#import "ViewWithGraphController+CPTPlot.h"
#import "ViewWithGraphController+SegmentedControl.h"

@implementation ViewWithGraphController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [DBModel createTablesForModel];
    [self loadAvailableCoins];
    [self configureGraph];
    [self configureTextField];
    [self configureSegmentedControl];
    [self appointPickerViewDelegate:self andDataSource:self];
    
}

@end
