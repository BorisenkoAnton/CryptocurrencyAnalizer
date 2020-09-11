//
//  GraphModel.m
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/10/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import "GraphModel.h"
#import "GraphService.h"

@implementation GraphModel

- (id)initModelWithFrame:(CGRect)frame backgroundColor:(CGColorRef)color bottomPadding:(CGFloat)paddingBottom leftPadding:(CGFloat)paddingLeft topPadding:(CGFloat)paddingTop andRightPadding:(CGFloat)paddingRight {
    
    self = [self initWithFrame:frame];
    
    // A layer drawn on top of the graph layer and behind all plot elements
    self.plotAreaFrame.masksToBorder = NO; // If YES, a sublayer mask is applied to clip sublayer content to the inside of the border
    self.backgroundColor = color;
    self.paddingBottom = paddingBottom;
    self.paddingLeft = paddingLeft;
    self.paddingTop = paddingTop;
    self.paddingRight = paddingRight;
    
    self.plotDots = [NSMutableArray<NSNumber *> new];
    self.textStyles = [NSMutableArray<CPTMutableTextStyle *> new];
    self.lineStyles = [NSMutableArray<CPTMutableLineStyle *> new];
    self.gridLineStyles = [NSMutableArray<CPTMutableLineStyle *> new];
    
    return self;
}

@end
