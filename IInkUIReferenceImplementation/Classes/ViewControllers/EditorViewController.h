// Copyright MyScript. All right reserved.

#import <UIKit/UIKit.h>
#import <iink/IINKEngine.h>
#import <IInkUIReferenceImplementation/InputView.h>
#import "SmartGuideViewController.h"

@class DisplayViewController;

@interface EditorViewController : UIViewController

@property (strong, nonatomic) IINKEngine *engine;
@property (strong, nonatomic) IINKEditor *editor;

@property (nonatomic, assign) BOOL smartGuideDisabled;

@property (strong, nonatomic, readonly) DisplayViewController *displayViewController;
@property (strong, nonatomic, readonly) InputView *inputView;
@property (strong, nonatomic, readonly) SmartGuideViewController *smartGuideViewController;

@property (nonatomic) InputMode inputMode;

@end
