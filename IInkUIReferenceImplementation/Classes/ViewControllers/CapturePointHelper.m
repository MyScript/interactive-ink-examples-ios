// Copyright MyScript. All right reserved.

#import "CapturePointHelper.h"

@implementation CapturePointHelper

+ (CapturePoint)capturePointFromTouch:(UITouch *)touch inView:(UIView *)inputView inputMode:(InputMode)inputMode
{
    CGPoint point = CGPointZero;
    float f = 0.0f;
    IINKPointerType pointerType;
    if (inputMode == InputModeForcePen)
    {
        pointerType = IINKPointerTypePen;
    }
    else if (inputMode == InputModeForceTouch)
    {
        pointerType = IINKPointerTypeTouch;
    }
    else // if (_inputMode == InputMode::InputModeForceAuto)
    {
        pointerType = touch.type == UITouchTypeStylus ? IINKPointerTypePen : IINKPointerTypeTouch;
    }
    if (touch.type == UITouchTypeStylus)
    {
        point = [touch preciseLocationInView:inputView];
        f = (float)(touch.force / touch.maximumPossibleForce);
    }
    else
    {
        point = [touch locationInView:inputView];
    }
    return (CapturePoint){point, f, pointerType};
}

@end
