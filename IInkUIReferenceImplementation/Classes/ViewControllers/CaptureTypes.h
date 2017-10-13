// Copyright MyScript. All right reserved.

#import <iink/IINKEditor.h>

#ifndef CaptureTypes_h
#define CaptureTypes_h

typedef struct CapturePoint {
    CGPoint point;
    float f;
    IINKPointerType pointerType;
} CapturePoint;

typedef NS_ENUM(NSUInteger, InputMode) {
    InputModeForcePen,
    InputModeForceTouch,
    InputModeAuto,
};

#endif /* CaptureTypes_h */
