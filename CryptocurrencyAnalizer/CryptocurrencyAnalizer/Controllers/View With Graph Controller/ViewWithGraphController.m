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
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self configureGraph];
    
    [self configureTextField];
}


-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self loadAvailableCoins];
    
    [self appointPickerViewDelegate:self andDataSource:self];
    
    [self configureSegmentedControl];
}

@end
