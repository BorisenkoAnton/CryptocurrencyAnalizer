//
//  ViewController.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/7/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "ViewController.h"
#import "NetworkService.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NetworkService *networkService = [NetworkService shared];
    [networkService getAvailableCoins:^(NSArray * _Nonnull availableCoins) {
        for (NSString *coin in availableCoins) {
            NSLog(coin);
        }
    }];
    
    [networkService getHistoricalDataForCoin:@"BTC" withLimit:[NSNumber numberWithInt:10] completion:^(NSArray * _Nullable coinData) {
        for (NSNumber *coindataItem in coinData) {
            NSLog(@"%@",[coindataItem stringValue]);
        }
    }];
}


@end
