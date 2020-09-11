//
//  GraphModel.h
//  CryptocurrencyAnalizer
//
//  Created by Anton Borisenko on 9/10/20.
//  Copyright © 2020 Anton Borisenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"

NS_ASSUME_NONNULL_BEGIN

@interface GraphModel : CPTXYGraph

@property NSMutableArray<NSNumber *> *plotDots;
@property NSMutableArray<CPTMutableTextStyle *> *textStyles;
@property NSMutableArray<CPTMutableLineStyle *> *lineStyles;
@property NSMutableArray<CPTMutableLineStyle *> *gridLineStyles;

- (id)initModelWithFrame:(CGRect)frame
            backgroundColor:(CGColorRef)color
            bottomPadding:(CGFloat)paddingBottom
            leftPadding:(CGFloat)paddingLeft
            topPadding:(CGFloat)paddingTop
            andRightPadding:(CGFloat)paddingRight;

@end

NS_ASSUME_NONNULL_END
