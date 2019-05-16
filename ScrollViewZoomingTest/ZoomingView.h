//
//  ZoomingView.h
//  ScrollViewZoomingTest
//
//  Created by Alexander Kormanovsky on 14/05/2019.
//  Copyright © 2019 Mingli. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZoomingView : UIView

- (CGRect)shapesInnerRect;

- (CGFloat)shapesSize;

- (void)handleZoom:(CGFloat)zoom;

@end

NS_ASSUME_NONNULL_END
