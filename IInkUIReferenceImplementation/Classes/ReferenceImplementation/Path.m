// Copyright MyScript. All right reserved.

#import <UIKit/UIKit.h>
#import "Path.h"

@implementation Path

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.bezierPath = [[UIBezierPath alloc] init];
    }
    return self;
}

- (void)moveTo:(CGPoint)position
{
    [self.bezierPath moveToPoint:position];
}

- (void)lineTo:(CGPoint)position
{
    [self.bezierPath addLineToPoint:position];
}

- (void)closePath
{
    [self.bezierPath closePath];
}

- (void)curveTo:(CGPoint)to controlPoint1:(CGPoint)c1 controlPoint2:(CGPoint)c2
{
    [self.bezierPath addCurveToPoint:to controlPoint1:c1 controlPoint2:c2];
}

- (void)quadTo:(CGPoint)to controlPoint:(CGPoint)c
{
    [self.bezierPath addQuadCurveToPoint:to controlPoint:c];
}

// NOTE: arcTo:rx:ry:phi:fa:fs: is not supported by iOS. Thus it is deliberately
// not implemented so iink knows (using respondsToSelector: underneath) it has
// to use built-in approximation methods.

@end
