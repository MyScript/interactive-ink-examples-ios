// Copyright MyScript. All right reserved.

#import "InputView.h"
#import <iink/IINKEditor.h>

@interface InputView ()

@property (nonatomic) BOOL trackPressure;
@property (nonatomic) BOOL cancelled;
@property (nonatomic) BOOL touchesBegan;
@property (nonatomic) NSTimeInterval eventTimeOffset;

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

    NSTimeInterval rel_t = [[NSProcessInfo processInfo] systemUptime];
    NSTimeInterval abs_t = [[NSDate date] timeIntervalSince1970];
    self.eventTimeOffset = abs_t - rel_t;
}

#pragma mark - Touches

- (IINKPointerEvent)pointerEventFromTouch:(UITouch *)touch withType:(IINKPointerEventType)eventType
{
    IINKPointerType pointerType;
    switch (self.inputMode)
    {
        case InputModeForcePen:
            pointerType = IINKPointerTypePen;
            break;
        case InputModeForceTouch:
            pointerType = IINKPointerTypeTouch;
            break;
        case InputModeAuto:
        default:
            pointerType = touch.type == UITouchTypeStylus ? IINKPointerTypePen : IINKPointerTypeTouch;
            break;
    }

    CGPoint point;
    float f;
    if (touch.type == UITouchTypeStylus)
    {
        point = [touch preciseLocationInView:self];
        f = (float)(touch.force / touch.maximumPossibleForce);
    }
    else
    {
        point = [touch locationInView:self];
        f = 0.0f;
    }

    int64_t t = (int64_t)(1000 * (touch.timestamp + self.eventTimeOffset));

    int pointerId = 0;

    return IINKPointerEventMake(eventType, point, t, f, pointerType, pointerId);
}

- (IINKPointerEvent)pointerDownEventFromTouch:(UITouch *)touch
{
    return [self pointerEventFromTouch:touch withType:IINKPointerEventTypeDown];
}

- (IINKPointerEvent)pointerMoveEventFromTouch:(UITouch *)touch
{
    return [self pointerEventFromTouch:touch withType:IINKPointerEventTypeMove];
}

- (IINKPointerEvent)pointerUpEventFromTouch:(UITouch *)touch
{
    return [self pointerEventFromTouch:touch withType:IINKPointerEventTypeUp];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = touches.anyObject;
    IINKPointerEvent e = [self pointerDownEventFromTouch:touch];
    if (e.pointerType == IINKPointerTypePen)
    {
        self.touchesBegan = YES;
    }
    
    [self.editor pointerDown:CGPointMake(e.x, e.y) at:e.t force:e.f type:e.pointerType pointerId:e.pointerId error:nil];
    
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
        IINKPointerEvent events[n];
        IINKPointerEvent *p = events;
        for (UITouch *coalescedTouch in coalescedTouches)
            *p++ = [self pointerMoveEventFromTouch:coalescedTouch];
        [self.editor pointerEvents:events count:n doProcessGestures:YES error:nil];
    }
    else
    {
        IINKPointerEvent e = [self pointerMoveEventFromTouch:touch];
        [self.editor pointerMove:CGPointMake(e.x, e.y) at:e.t force:e.f type:e.pointerType pointerId:e.pointerId error:nil];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    UITouch *touch = touches.anyObject;
    IINKPointerEvent e = [self pointerUpEventFromTouch:touch];
    [self.editor pointerUp:CGPointMake(e.x, e.y) at:e.t force:e.f type:e.pointerType pointerId:e.pointerId error:nil];
  
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
