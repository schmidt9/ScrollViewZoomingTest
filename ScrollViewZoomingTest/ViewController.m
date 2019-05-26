//
//  ViewController.m
//  ScrollViewZoomingTest
//
//  Created by Alexander Kormanovsky on 14/05/2019.
//  Copyright © 2019 Mingli. All rights reserved.
//

#import "ViewController.h"
#import "ZoomingView.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) ZoomingView *zoomingView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setup];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self adjustScrollPositionAndZoomToFrame:[self.zoomingView shapesInnerRect]];
}

- (void)viewDidLayoutSubviews
{
    const CGFloat kZoomingViewWidth = 120;
    const CGFloat kZoomingViewHeight = 100;
    
    [self.zoomingView removeFromSuperview];
    
    self.scrollView.contentSize = self.scrollView.frame.size;
    
    self.zoomingView = [[ZoomingView alloc] initWithFrame:CGRectMake((self.scrollView.frame.size.width - kZoomingViewWidth) / 2, (self.scrollView.frame.size.height - kZoomingViewHeight) / 2, kZoomingViewWidth, kZoomingViewHeight)];
    self.zoomingView.backgroundColor = [UIColor clearColor];
    self.zoomingView.layer.borderColor = [UIColor grayColor].CGColor;
    self.zoomingView.layer.borderWidth = 1;
    [self.scrollView addSubview:self.zoomingView];
}

- (void)setup
{
    self.scrollView.layer.borderColor = [UIColor redColor].CGColor;
    self.scrollView.layer.borderWidth = 1;
}

- (void)adjustScrollPositionAndZoomToFrame:(CGRect)frame
{
    CGFloat viewWidth = frame.size.width;
    CGFloat viewHeight = frame.size.height;
    
    CGFloat scrollViewWidth = self.scrollView.frame.size.width;
    CGFloat scrollViewHeight = self.scrollView.frame.size.height;
    
    CGSize newSize = [self scaleSize:frame.size toHeight:scrollViewHeight];
    
    if (newSize.width > scrollViewWidth) {
        newSize = [self scaleSize:frame.size toWidth:scrollViewWidth];
    }

    CGFloat scaleFactor = newSize.height == scrollViewHeight
        ? (scrollViewHeight - [self.zoomingView shapesSize] * 2) / viewHeight
        : (scrollViewWidth - [self.zoomingView shapesSize] * 2) / viewWidth;
    
    [self scrollRect:frame toCenterInScrollView:self.scrollView animated:NO];

    self.scrollView.zoomScale = scaleFactor;
}

#pragma mark - Helpers

- (CGSize)scaleSize:(CGSize)size toWidth:(double)width
{
    double minVal = MIN(size.width, width);
    double maxVal = MAX(size.width, width);
    
    return CGSizeMake(
        width,
        (width < size.width ? minVal / maxVal : maxVal / minVal) * size.height);
}

- (CGSize)scaleSize:(CGSize)size toHeight:(double)height
{
    double minVal = MIN(size.height, height);
    double maxVal = MAX(size.height, height);
    
    return CGSizeMake(
        (height < size.height ? minVal / maxVal : maxVal / minVal) * size.width,
        height);
}

- (void)scrollRect:(CGRect)rect toCenterInScrollView:(UIScrollView *)scrollView animated:(BOOL)animated
{
    CGPoint rectCenter = {CGRectGetMidX(rect), CGRectGetMidY(rect)};
    CGRect newRect = {
        rectCenter.x - scrollView.frame.size.width / 2,
        rectCenter.y - scrollView.frame.size.height / 2,
        scrollView.frame.size
    };
    [scrollView scrollRectToVisible:newRect animated:animated];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.zoomingView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *zoomView = [scrollView.delegate viewForZoomingInScrollView:scrollView];
    CGRect zvf = zoomView.frame;
    
    if (zvf.size.width < scrollView.bounds.size.width) {
        zvf.origin.x = (scrollView.bounds.size.width - zvf.size.width) / 2.0f;
    } else {
        zvf.origin.x = 0.0;
    }
    
    if (zvf.size.height < scrollView.bounds.size.height) {
        zvf.origin.y = (scrollView.bounds.size.height - zvf.size.height) / 2.0f;
    } else {
        zvf.origin.y = 0.0;
    }
    
    zoomView.frame = zvf;

    [self.zoomingView handleZoom:scrollView.zoomScale];

    NSLog(@"scroll view zoom %f views zoom %f", scrollView.zoomScale, 1 / scrollView.zoomScale);
}

@end
