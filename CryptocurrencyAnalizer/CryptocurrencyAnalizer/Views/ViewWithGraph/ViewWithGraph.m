//
//  ViewWithGraph.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/10/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "ViewWithGraph.h"
#import "CorePlot-CocoaTouch.h"
#import "ViewController.h"

@interface ViewWithGraph ()

@property (strong, nonatomic) IBOutlet UIView *view;

@end

@implementation ViewWithGraph

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    [self initView];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    [self initView];
    return self;
}

- (void)initView {
    [[NSBundle mainBundle] loadNibNamed:@"ViewWithGraph" owner:self options:nil];
    
    [self addSubview:self.view];
    [self.view addSubview:self.graphView];
    self.view.frame = self.bounds;
    // Whether a pinch will trigger plot space scaling. Default is YES. This causes gesture recognizers to be added to identify pinches
    self.graphView.allowPinchScaling = NO;
    
}

@end
