// Copyright MyScript. All right reserved.

#import <UIKit/UIKit.h>
#import <iink/IINKEngine.h>
#import <IInkUIReferenceImplementation/InputView.h>

@class DisplayViewController;

@interface EditorViewController : UIViewController

@property (strong, nonatomic) IINKEngine *engine;
@property (strong, nonatomic) IINKEditor *editor;

@property (strong, nonatomic, readonly) DisplayViewController *displayViewController;
@property (strong, nonatomic, readonly) InputView *inputView;

@property (nonatomic) InputMode inputMode;

@end
