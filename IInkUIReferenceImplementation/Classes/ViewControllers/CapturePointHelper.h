// Copyright MyScript. All right reserved.

#import <UIKit/UIKit.h>
#import <iink/IINKEditor.h>
#import <IInkUIReferenceImplementation/CaptureTypes.h>

@interface CapturePointHelper : NSObject

+ (CapturePoint)capturePointFromTouch:(UITouch *)touch inView:(UIView *)inputView inputMode:(InputMode)inputMode;

@end
