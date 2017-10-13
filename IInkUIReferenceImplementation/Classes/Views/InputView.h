// Copyright MyScript. All right reserved.

#import <UIKit/UIKit.h>
#import <IInkUIReferenceImplementation/CaptureTypes.h>

@class IINKEditor;

@interface InputView : UIView

@property (weak, nonatomic) IINKEditor *editor;

@property (nonatomic) InputMode inputMode;

@end
