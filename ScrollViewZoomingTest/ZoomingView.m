//
//  ZoomingView.m
//  ScrollViewZoomingTest
//
//  Created by Alexander Kormanovsky on 14/05/2019.
//  Copyright © 2019 Mingli. All rights reserved.
//

#import "ZoomingView.h"

const CGFloat kShapesSize = 30;
const CGFloat kShapesCenterSize = 3;
const NSUInteger kShapesCount = 9;

@implementation ZoomingView
{
    NSMutableArray *_views;
    CGFloat _zoom;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addViews];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor greenColor] setStroke];
    CGContextSetLineWidth(context, 1);
    CGContextStrokeRect(context, [self shapesInnerRect]);
    CGContextStrokeRect(context, [self shapesOuterRect]);
}

- (CGRect)shapesInnerRect
{
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat shapesHorizontalSpacing = (width - kShapesSize * 3) / 2;
    CGFloat shapesVerticalSpacing = (height - kShapesSize * 3) / 2;
    return CGRectMake(kShapesSize,
                      kShapesSize,
                      shapesHorizontalSpacing * 2 + kShapesSize,
                      shapesVerticalSpacing * 2 + kShapesSize);
}

- (CGRect)shapesOuterRect
{
    CGFloat insetSize = kShapesSize * (1 / _zoom);

    return CGRectInset([self shapesInnerRect], -insetSize, -insetSize);
}

- (CGFloat)shapesSize
{
    return kShapesSize;
}

- (void)addViews
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat x = 0, y = 0;
    CGFloat shapesHorizontalSpacing = (width - kShapesSize * 3) / 2;
    CGFloat shapesVerticalSpacing = (height - kShapesSize * 3) / 2;
    
    // shapes
    
    _views = [NSMutableArray new];
    
    for (int i = 0; i < 3; i++) { // columns
        y = (shapesVerticalSpacing + kShapesSize) * i;
        
        for (int j = 0; j < 3; j++) { // rows
            x = (shapesHorizontalSpacing + kShapesSize) * j;
            
            UIView *label = [[UIView alloc] initWithFrame:CGRectMake(x, y, kShapesSize, kShapesSize)];
            label.layer.borderWidth = 2;
            label.layer.borderColor = [UIColor redColor].CGColor;
            
            [self addSubview:label];
            [_views addObject:label];
        }
        
    }
}

- (void)handleZoom:(CGFloat)zoom
{
    _zoom = zoom;
    
//    NSArray *anchorPoints = @[[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
//                              [NSValue valueWithCGPoint:CGPointMake(0.5, 0.0)],
//                              [NSValue valueWithCGPoint:CGPointMake(1.0, 0.0)],
//
//                              [NSValue valueWithCGPoint:CGPointMake(0.0, 0.5)],
//                              [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)],
//                              [NSValue valueWithCGPoint:CGPointMake(1.0, 0.5)],
//
//                              [NSValue valueWithCGPoint:CGPointMake(0.0, 1.0)],
//                              [NSValue valueWithCGPoint:CGPointMake(0.5, 1.0)],
//                              [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
//                              ];

    NSArray *anchorPoints = @[[NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                              [NSValue valueWithCGPoint:CGPointMake(0.5, 1.0)],
                              [NSValue valueWithCGPoint:CGPointMake(0.0, 1.0)],
                              
                              [NSValue valueWithCGPoint:CGPointMake(1.0, 0.5)],
                              [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)],
                              [NSValue valueWithCGPoint:CGPointMake(0.0, 0.5)],
                              
                              [NSValue valueWithCGPoint:CGPointMake(1.0, 0.0)],
                              [NSValue valueWithCGPoint:CGPointMake(0.5, 0.0)],
                              [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)]
                              ];
    
    for (UIView *view in _views) {
        [self setViewAnchorPoint:view value:[anchorPoints[[_views indexOfObject:view]] CGPointValue]];
        view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1 / zoom, 1 / zoom);
    }

    [self setNeedsDisplay];
}

/**
 * @see https://stackoverflow.com/a/9649399/3004003
 * @param value See view.layer.anchorPoint
 */
- (void)setViewAnchorPoint:(UIView *)view value:(CGPoint)value
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * value.x,
                                   view.bounds.size.height * value.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x,
                                   view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = value;
}

@end
