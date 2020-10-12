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
}


- (void)viewWillAppear:(BOOL)animated {
    
    [DBModel createTablesForModel];
    [self configureGraph];
    [self configureTextField];
}


-(void)viewDidAppear:(BOOL)animated {
    
    [self loadAvailableCoins];
    [self appointPickerViewDelegate:self andDataSource:self];
    [self configureSegmentedControl];
}

@end
