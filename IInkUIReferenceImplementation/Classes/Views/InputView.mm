// Copyright MyScript. All right reserved.

#import "InputView.h"
#import <iink/IINKEditor.h>
#import "CaptureTypes.h"
#import "CapturePointHelper.h"

@interface InputView ()

@property (nonatomic) BOOL trackPressure;
@property (nonatomic) BOOL cancelled;
@property (nonatomic) BOOL touchesBegan;

@end

@implementation InputView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self ownInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self ownInit];
    }
    return self;
}

- (void)ownInit
{
    self.multipleTouchEnabled = NO;
    self.trackPressure = self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    self.inputMode = InputMode::InputModeForcePen;
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = touches.anyObject;
    CapturePoint capturePoint = [CapturePointHelper capturePointFromTouch:touch inView:self inputMode:self.inputMode];
    if (capturePoint.pointerType == IINKPointerTypePen)
    {
        self.touchesBegan = YES;
    }
    
    [self.editor pointerDown:capturePoint.point at:(int64_t)-1 force:capturePoint.f type:capturePoint.pointerType pointerId:0 error:nil];
    
    self.cancelled = NO;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = touches.anyObject;
    
    NSArray *coalescedTouches = [event coalescedTouchesForTouch:touch];
    if (coalescedTouches)
    {
        NSUInteger n = [coalescedTouches count];
        IINKPointerEvent events[n+1];
        IINKPointerEvent *p = events;
        for (UITouch *coalescedTouch in coalescedTouches)
        {
            CapturePoint capturePoint = [CapturePointHelper capturePointFromTouch:coalescedTouch inView:self inputMode:self.inputMode];
            *p++ = IINKPointerEventMakeMove(capturePoint.point, -1, capturePoint.f, capturePoint.pointerType, 0);
        }
        CapturePoint capturePoint = [CapturePointHelper capturePointFromTouch:touch inView:self inputMode:self.inputMode];
        *p++ = IINKPointerEventMakeMove(capturePoint.point, -1, capturePoint.f, capturePoint.pointerType, 0);
        [self.editor pointerEvents:events count:n+1 doProcessGestures:YES error:nil];
    }
    else
    {
        CapturePoint capturePoint = [CapturePointHelper capturePointFromTouch:touch inView:self inputMode:self.inputMode];
        [self.editor pointerMove:capturePoint.point at:(int64_t)-1 force:capturePoint.f type:capturePoint.pointerType pointerId:0 error:nil];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    UITouch *touch = touches.anyObject;
    CapturePoint capturePoint = [CapturePointHelper capturePointFromTouch:touch inView:self inputMode:self.inputMode];
    [self.editor pointerUp:capturePoint.point at:(int64_t)-1 force:capturePoint.f type:capturePoint.pointerType pointerId:0 error:nil];
  
    self.touchesBegan = NO;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    [self.editor pointerCancel:0 error:nil];
    self.cancelled = YES;
    self.touchesBegan = NO;
}

@end
