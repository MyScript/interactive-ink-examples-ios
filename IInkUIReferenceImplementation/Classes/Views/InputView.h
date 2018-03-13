// Copyright MyScript. All right reserved.

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, InputMode) {
    InputModeForcePen,
    InputModeForceTouch,
    InputModeAuto,
};

@class IINKEditor;

@interface InputView : UIView

@property (weak, nonatomic) IINKEditor *editor;

@property (nonatomic) InputMode inputMode;

@end
