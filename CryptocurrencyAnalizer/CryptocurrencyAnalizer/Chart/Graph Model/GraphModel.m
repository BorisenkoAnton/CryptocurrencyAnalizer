//
//  GraphModel.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/10/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "GraphModel.h"

@implementation GraphModel

- (id)initModelWithOptions:(GraphOptions)options {
    
    self = [self initWithFrame:options.frame];
    
    // A layer drawn on top of the graph layer and behind all plot elements
    self.plotAreaFrame.masksToBorder = NO; // If YES, a sublayer mask is applied to clip sublayer content to the inside of the border
    self.backgroundColor = options.color;
    self.paddingBottom = options.paddingBottom;
    self.paddingLeft = options.paddingLeft;
    self.paddingTop = options.paddingTop;
    self.paddingRight = options.paddingRight;
    self.plotDots = [NSMutableArray<DBModel *> new];
    self.textStyles = [NSMutableArray<CPTMutableTextStyle *> new];
    self.lineStyles = [NSMutableArray<CPTMutableLineStyle *> new];
    self.gridLineStyles = [NSMutableArray<CPTMutableLineStyle *> new];
    
    return self;
}

@end
